import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

import '../config/endpoints.dart';
import '../errors/kesalahan.dart';
import '../network/klien_jaringan.dart';

enum JenisUnggah {
  fotoDokumen('foto_dokumen'),
  fotoWajah('foto_wajah'),
  videoLiveness('video_liveness'),
  audioSuara('audio_suara'),
  dokumenPermohonan('dokumen_permohonan');

  const JenisUnggah(this.kode);
  final String kode;
}

class HasilInisiasiUnggah {
  const HasilInisiasiUnggah({
    required this.urlPresigned,
    required this.kunciStorage,
    this.metode = 'PUT',
    this.header = const {},
  });

  final String urlPresigned;
  final String kunciStorage;
  final String metode;
  final Map<String, String> header;
}

class LayananUnggah {
  LayananUnggah._({Dio? dio, Dio? dioLuar})
      : _dio = dio ?? KlienJaringan.instance.dio,
        _dioLuar = dioLuar ?? Dio();

  static final LayananUnggah instance = LayananUnggah._();

  factory LayananUnggah.uji({required Dio dio, required Dio dioLuar}) =>
      LayananUnggah._(dio: dio, dioLuar: dioLuar);

  final Dio _dio;
  final Dio _dioLuar;
  
  final Map<String, Future<String>> _inFlightUploads = {};

  static const Set<JenisUnggah> jenisRegistrasi = {
    JenisUnggah.fotoDokumen,
    JenisUnggah.fotoWajah,
    JenisUnggah.videoLiveness,
  };

  Future<String> unggah({
    required File berkas,
    required JenisUnggah jenis,
    String? mimeType,
    String? tokenRegistrasi,
    void Function(int sent, int total)? onProgress,
  }) async {
    final kunciDeduplikasi = '${berkas.path}_${jenis.kode}_$tokenRegistrasi';
    if (_inFlightUploads.containsKey(kunciDeduplikasi)) {
      return await _inFlightUploads[kunciDeduplikasi]!;
    }
    
    final masaDepan = _eksekusiDenganRetry(
      berkas: berkas,
      jenis: jenis,
      mimeType: mimeType,
      tokenRegistrasi: tokenRegistrasi,
      onProgress: onProgress,
    );
    
    _inFlightUploads[kunciDeduplikasi] = masaDepan;
    try {
      return await masaDepan;
    } finally {
      _inFlightUploads.remove(kunciDeduplikasi);
    }
  }

  Future<String> _eksekusiDenganRetry({
    required File berkas,
    required JenisUnggah jenis,
    String? mimeType,
    String? tokenRegistrasi,
    void Function(int sent, int total)? onProgress,
  }) async {
    const int maxCoba = 3;
    int coba = 0;
    
    while (true) {
      coba++;
      try {
        if (tokenRegistrasi != null && !jenisRegistrasi.contains(jenis)) {
          throw const KesalahanUnggah(
            'Jenis berkas ini tidak diizinkan diunggah saat pendaftaran.',
          );
        }
        
        final mime = mimeType ?? lookupMimeType(berkas.path) ?? _tebakMime(berkas.path);
        final ukuran = await berkas.length();
        
        final inisiasi = await _inisiasi(
          jenis: jenis,
          mimeType: mime,
          ukuran: ukuran,
          tokenRegistrasi: tokenRegistrasi,
        );
        
        await _unggahKeStorage(inisiasi, berkas, mime, ukuran, onProgress);
        await _konfirmasi(inisiasi.kunciStorage, tokenRegistrasi: tokenRegistrasi);
        
        return inisiasi.kunciStorage;
      } catch (e) {
        if (e is KesalahanUnggah && !e.pesan.toLowerCase().contains('jaringan') && !e.pesan.toLowerCase().contains('timeout')) {
          rethrow;
        }
        if (coba >= maxCoba) {
          if (e is Kesalahan) rethrow;
          throw const KesalahanUnggah('Gagal mengunggah berkas setelah beberapa kali percobaan karena gangguan jaringan.');
        }
        await Future.delayed(Duration(milliseconds: 1000 * coba));
      }
    }
  }

  Options _opsi(String? tokenRegistrasi) {
    if (tokenRegistrasi == null) {
      return Options(extra: const {'anonim': false});
    }
    return Options(
      extra: const {'anonim': true},
      headers: {'X-Registration-Token': tokenRegistrasi},
    );
  }

  Future<HasilInisiasiUnggah> _inisiasi({
    required JenisUnggah jenis,
    required String mimeType,
    required int ukuran,
    String? tokenRegistrasi,
  }) async {
    try {
      final res = await _dio.post(
        Endpoints.uploadInisiasi,
        data: {
          'jenis': jenis.kode,
          'mime_type': mimeType,
          'ukuran': ukuran,
          if (tokenRegistrasi != null) 'token_registrasi': tokenRegistrasi,
        },
        options: _opsi(tokenRegistrasi),
      );
      final body = res.data;
      if (body is Map && body['success'] == false) {
        final galat = body['error'];
        final pesan = galat is Map ? galat['message']?.toString() : null;
        throw KesalahanUnggah(pesan ?? 'Gagal memulai unggahan berkas.');
      }
      final peta = _ratakan(res.data);
      final url = _cariUrl(peta);
      final kunci = _cariKunci(peta);
      if (url.isEmpty || kunci.isEmpty) {
        throw const KesalahanUnggah('Gagal memulai unggahan berkas.');
      }
      return HasilInisiasiUnggah(
        urlPresigned: url,
        kunciStorage: kunci,
        metode: (peta['metode'] ?? peta['method'] ?? 'PUT').toString(),
        header: _cariHeader(res.data),
      );
    } on DioException catch (e) {
      throw e.error is Kesalahan
          ? e.error! as Kesalahan
          : const KesalahanUnggah('Tidak dapat memproses unggahan berkas akibat gangguan jaringan.');
    }
  }

  Future<void> _unggahKeStorage(
    HasilInisiasiUnggah inisiasi,
    File berkas,
    String mime,
    int ukuran,
    void Function(int sent, int total)? onProgress,
  ) async {
    try {
      final metode = inisiasi.metode.toUpperCase();
      
      if (metode == 'POST') {
        final namaBerkas = p.basename(berkas.path);
        final mediaType = MediaType.parse(mime);
        
        final formDataMap = <String, dynamic>{};
        inisiasi.header.forEach((k, v) => formDataMap[k] = v);
        
        formDataMap['file'] = await MultipartFile.fromFile(
          berkas.path,
          filename: namaBerkas,
          contentType: mediaType,
        );
        
        final formData = FormData.fromMap(formDataMap);
        
        await _dioLuar.post(
          inisiasi.urlPresigned,
          data: formData,
          options: Options(
            sendTimeout: const Duration(minutes: 5),
            receiveTimeout: const Duration(minutes: 5),
          ),
          onSendProgress: onProgress,
        );
      } else {
        await _dioLuar.requestUri(
          Uri.parse(inisiasi.urlPresigned),
          data: berkas.openRead(),
          options: Options(
            method: metode,
            headers: {
              Headers.contentTypeHeader: mime,
              Headers.contentLengthHeader: ukuran,
              ...inisiasi.header,
            },
            sendTimeout: const Duration(minutes: 5),
            receiveTimeout: const Duration(minutes: 5),
          ),
          onSendProgress: onProgress,
        );
      }
    } on DioException {
      throw const KesalahanUnggah('Gagal mengunggah berkas ke penyimpanan karena koneksi terputus (timeout).');
    }
  }

  Future<void> _konfirmasi(
    String kunciStorage, {
    String? tokenRegistrasi,
  }) async {
    try {
      await _dio.post(
        Endpoints.uploadKonfirmasi,
        data: {
          'kunci_storage': kunciStorage,
          if (tokenRegistrasi != null) 'token_registrasi': tokenRegistrasi,
        },
        options: _opsi(tokenRegistrasi),
      );
    } on DioException catch (e) {
      throw e.error is Kesalahan
          ? e.error! as Kesalahan
          : const KesalahanUnggah('Tidak dapat memproses unggahan berkas akibat gangguan jaringan.');
    }
  }

  Map<String, dynamic> _ratakan(dynamic body) {
    final hasil = <String, dynamic>{};
    void jelajah(dynamic node) {
      if (node is! Map) return;
      node.forEach((k, v) {
        if (v is Map) {
          jelajah(v);
        } else if (v is! List) {
          final kunci = k.toString().toLowerCase();
          final adaIsi = hasil[kunci]?.toString().isNotEmpty ?? false;
          if (!adaIsi) hasil[kunci] = v;
        }
      });
    }

    jelajah(body);
    return hasil;
  }

  String _cariUrl(Map<String, dynamic> peta) {
    const kandidat = [
      'url_presigned',
      'presigned_url',
      'signed_url',
      'upload_url',
      'put_url',
      'url',
    ];
    for (final k in kandidat) {
      final v = peta[k];
      if (v is String && v.startsWith('http')) return v;
    }
    for (final v in peta.values) {
      if (v is String && v.startsWith('http')) return v;
    }
    return '';
  }

  String _cariKunci(Map<String, dynamic> peta) {
    const kandidat = [
      'kunci_storage',
      'storage_key',
      'object_key',
      'file_key',
      'kunci_berkas',
      'kunci',
      'key',
      'path',
    ];
    for (final k in kandidat) {
      final v = peta[k];
      if (v is String && v.isNotEmpty && !v.startsWith('http')) return v;
    }
    for (final e in peta.entries) {
      final v = e.value;
      if (v is String &&
          v.isNotEmpty &&
          !v.startsWith('http') &&
          (e.key.contains('kunci') ||
              e.key.contains('key') ||
              e.key.contains('storage') ||
              e.key.contains('object') ||
              e.key.contains('path'))) {
        return v;
      }
    }
    return '';
  }

  Map<String, String> _cariHeader(dynamic body) {
    final hasil = <String, String>{};
    if (body is Map) {
      final raw = body['header'] ?? body['headers'];
      if (raw is Map) {
        raw.forEach((k, v) => hasil[k.toString()] = v.toString());
      }
    }
    return hasil;
  }

  String _tebakMime(String jalur) {
    final titik = jalur.lastIndexOf('.');
    final ext = titik >= 0 ? jalur.substring(titik + 1).toLowerCase() : '';
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'm4a':
      case 'aac':
        return 'audio/aac';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}

