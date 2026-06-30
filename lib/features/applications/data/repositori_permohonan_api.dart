import 'dart:io';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/endpoints.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/network/klien_jaringan.dart';
import '../../../core/storage/berkas_sementara.dart';
import '../../../core/upload/layanan_unggah.dart';
import '../../../shared/models/halaman_data.dart';
import '../../../shared/models/permohonan.dart';
import '../domain/repositori_permohonan.dart';

class RepositoriPermohonanApi implements RepositoriPermohonan {
  RepositoriPermohonanApi({Dio? dio, LayananUnggah? unggah})
      : _dio = dio ?? KlienJaringan.instance.dio,
        _unggah = unggah ?? LayananUnggah.instance;

  final Dio _dio;
  final LayananUnggah _unggah;

  @override
  Future<HalamanData<Permohonan>> mintaDaftar({
    int halaman = 1,
    int ukuran = 15,
    String? status,
    String? cari,
  }) async {
    try {
      final res = await _dio.get(
        Endpoints.permohonan,
        queryParameters: {
          'halaman': halaman,
          'per_halaman': ukuran,
          if (status != null && status.isNotEmpty) 'status': status,
          if (cari != null && cari.isNotEmpty) 'cari': cari,
        },
      );
      final daftar =
          _bacaDaftar(res.data).map(Permohonan.dariJson).toList();
      final meta = _bacaMeta(res);
      return HalamanData(
        daftar: daftar,
        halaman: _metaInt(meta, const ['halaman', 'current_page'], halaman),
        totalHalaman:
            _metaInt(meta, const ['total_halaman', 'total_pages'], 1),
        totalItem:
            _metaInt(meta, const ['total', 'total_count'], daftar.length),
      );
    } on DioException catch (e) {
      throw _kesalahan(e);
    }
  }

  @override
  Future<List<Permohonan>> mintaGabunganTerbaru({int ukuran = 20}) async {
    final halaman = await mintaDaftar(halaman: 1, ukuran: ukuran);
    return halaman.daftar;
  }

  @override
  Future<Permohonan> mintaDetail(String id) async {
    try {
      final res = await _dio.get(Endpoints.permohonanDetail(id));
      return Permohonan.dariJson(_bacaObjek(res.data));
    } on DioException catch (e) {
      throw _kesalahan(e);
    }
  }

  @override
  Future<HasilAjukan> ajukan({
    required String kodeLayanan,
    required Map<String, String> dataFormulir,
    required Map<String, File> berkas,
    Map<String, bool> wajibBerkas = const <String, bool>{},
    Map<String, String> labelBerkas = const <String, String>{},
  }) async {
    final dokumen = <Map<String, dynamic>>[];
    for (final masuk in berkas.entries) {
      final kunciStorage = await _unggah.unggah(
        berkas: masuk.value,
        jenis: JenisUnggah.dokumenPermohonan,
      );
      dokumen.add({
        'jenis': masuk.key,
        'label': labelBerkas[masuk.key] ?? masuk.key,
        'kunci_storage': kunciStorage,
        'nama_file': masuk.value.uri.pathSegments.last,
        'wajib': wajibBerkas[masuk.key] ?? false,
      });
    }
    try {
      final res = await _dio.post(
        Endpoints.layananAjukan(kodeLayanan),
        data: {
          'data_formulir': dataFormulir,
          'dokumen': dokumen,
        },
        options: Options(
          headers: {'X-Idempotency-Key': const Uuid().v4()},
          sendTimeout: const Duration(minutes: 3),
          receiveTimeout: const Duration(minutes: 3),
        ),
      );
      final data = _bacaObjek(res.data);
      return HasilAjukan(
        id: data['id']?.toString() ?? '',
        nomorPermohonan: data['kode_referensi']?.toString() ??
            data['nomor_permohonan']?.toString() ??
            '',
        slugLayanan: data['jenis_layanan']?.toString() ?? kodeLayanan,
      );
    } on DioException catch (e) {
      throw _kesalahan(e);
    }
  }

  @override
  Future<void> batalkan(String id) async {
    try {
      await _dio.delete(Endpoints.permohonanDetail(id));
    } on DioException catch (e) {
      throw _kesalahan(e);
    }
  }

  @override
  Future<void> lampirkanDokumen({
    required String id,
    required File berkas,
    required String jenis,
    bool wajib = false,
  }) async {
    final kunciStorage = await _unggah.unggah(
      berkas: berkas,
      jenis: JenisUnggah.dokumenPermohonan,
    );
    try {
      await _dio.post(
        Endpoints.permohonanDokumen(id),
        data: {
          'kunci_storage': kunciStorage,
          'jenis': jenis,
          'nama_file': berkas.uri.pathSegments.last,
          'wajib': wajib,
        },
      );
    } on DioException catch (e) {
      throw _kesalahan(e);
    }
  }

  @override
  Future<List<DokumenHasil>> mintaDokumenHasil(String id) async {
    try {
      final res = await _dio.get(Endpoints.permohonanDokumenHasil(id));
      return _bacaDaftar(res.data).map(DokumenHasil.dariJson).toList();
    } on DioException catch (e) {
      throw _kesalahan(e);
    }
  }

  @override
  Future<String> unduhDokumenHasil(String id, DokumenHasil dokumen) async {
    try {
      final namaDasar = (dokumen.namaBerkas?.isNotEmpty ?? false)
          ? dokumen.namaBerkas!
          : 'dokumen_hasil_${dokumen.id}.pdf';
      final aman = namaDasar.replaceAll(RegExp(r'[^\w.\- ]'), '_');
      final tujuan = await BerkasSementara.instance.jalurBaru(aman);
      await _dio.download(
        Endpoints.permohonanDokumenHasilDetail(id, dokumen.id),
        tujuan,
        options: Options(
          receiveTimeout: const Duration(minutes: 2),
          validateStatus: (s) => s == 200,
        ),
      );
      return tujuan;
    } on DioException catch (e) {
      throw _kesalahan(e);
    }
  }

  Kesalahan _kesalahan(DioException e) =>
      e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();

  List<Map<String, dynamic>> _bacaDaftar(dynamic body) {
    dynamic isi = body;
    if (isi is Map) {
      isi = isi['permohonan'] ??
          isi['dokumen'] ??
          isi['data'] ??
          isi['items'] ??
          isi['list'] ??
          isi.values.firstWhere((v) => v is List, orElse: () => null);
    }
    if (isi is List) {
      return isi
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  Map<String, dynamic> _bacaObjek(dynamic body) {
    if (body is Map) {
      final inner = body['permohonan'] ?? body['data'];
      if (inner is Map) return Map<String, dynamic>.from(inner);
      return Map<String, dynamic>.from(body);
    }
    return const {};
  }

  Map<String, dynamic> _bacaMeta(Response res) {
    final ekstra = res.extra['meta'];
    if (ekstra is Map) return Map<String, dynamic>.from(ekstra);
    final body = res.data;
    if (body is Map && body['meta'] is Map) {
      return Map<String, dynamic>.from(body['meta'] as Map);
    }
    return const {};
  }

  int _metaInt(Map<String, dynamic> meta, List<String> kunci, int bawaan) {
    for (final k in kunci) {
      final nilai = meta[k];
      if (nilai is int) return nilai;
      if (nilai is num) return nilai.toInt();
      if (nilai is String) {
        final parsed = int.tryParse(nilai);
        if (parsed != null) return parsed;
      }
    }
    return bawaan;
  }
}
