import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/config/endpoints.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/network/klien_jaringan.dart';
import '../../../core/upload/layanan_unggah.dart';
import 'model/data_registrasi.dart';

class HasilMulaiSesi {
  const HasilMulaiSesi({
    required this.token,
    this.kodeReferensi,
    this.userId,
    this.kodeTantanganLiveness,
  });

  final String token;
  final String? kodeReferensi;
  final String? userId;
  final String? kodeTantanganLiveness;
}

abstract class RepositoriRegistrasi {
  Future<HasilMulaiSesi> mulaiSesi({required IdentitasRegistrasi identitas});
  Future<void> unggahFotoDokumen({required String token, required File berkas});
  Future<void> unggahFotoWajah({required String token, required File berkas});
  Future<void> unggahVideoLiveness({
    required String token,
    required File berkas,
    required List<String> kodeTantangan,
    List<TangkapTantangan> tangkapan = const [],
  });
  Future<void> kirimPersetujuan({
    required String token,
    required PersetujuanKebijakan persetujuan,
  });
  Future<void> submitFinal({
    required String token,
    required PersetujuanKebijakan persetujuan,
  });
  Future<Map<String, dynamic>?> ambilProgres({required String token});
}

class RepositoriRegistrasiApi implements RepositoriRegistrasi {
  RepositoriRegistrasiApi({Dio? dio, LayananUnggah? unggah})
      : _dio = dio ?? KlienJaringan.instance.dio,
        _unggah = unggah ?? LayananUnggah.instance;

  final Dio _dio;
  final LayananUnggah _unggah;

  Kesalahan _bungkus(DioException e) =>
      e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();

  Map<String, dynamic>? _bacaData(dynamic body) {
    if (body is Map) return Map<String, dynamic>.from(body);
    return null;
  }

  Options get _opsiAnonim => Options(extra: const {'anonim': true});

  static const String _pesanUploadRegistrasi =
      'Unggah berkas pendaftaran belum dapat diproses server saat ini. '
      'Silakan coba lagi nanti atau hubungi petugas Disdukcapil.';

  Future<String> _unggahBerkasRegistrasi({
    required File berkas,
    required JenisUnggah jenis,
    required String token,
  }) async {
    try {
      return await _unggah.unggah(
        berkas: berkas,
        jenis: jenis,
        tokenRegistrasi: token,
      );
    } on KesalahanTidakBerwenang {
      throw const KesalahanUnggah(_pesanUploadRegistrasi);
    } on KesalahanDilarang {
      throw const KesalahanUnggah(_pesanUploadRegistrasi);
    }
  }

  @override
  Future<HasilMulaiSesi> mulaiSesi({
    required IdentitasRegistrasi identitas,
  }) async {
    try {
      final res = await _dio.post(
        Endpoints.registrasiMulai,
        data: identitas.toJson(),
        options: _opsiAnonim,
      );
      final data = _bacaData(res.data);
      final token = data?['token_registrasi']?.toString() ??
          data?['token']?.toString() ??
          '';
      return HasilMulaiSesi(
        token: token,
        kodeReferensi: data?['kode_referensi']?.toString(),
        userId: data?['user_id']?.toString(),
      );
    } on DioException catch (e) {
      throw _bungkus(e);
    }
  }

  @override
  Future<void> unggahFotoDokumen({
    required String token,
    required File berkas,
  }) async {
    final kunci = await _unggahBerkasRegistrasi(
      berkas: berkas,
      jenis: JenisUnggah.fotoDokumen,
      token: token,
    );
    await _kirimLangkahBerkas(
      Endpoints.registrasiFotoDokumen,
      token: token,
      kunciStorage: kunci,
    );
  }

  @override
  Future<void> unggahFotoWajah({
    required String token,
    required File berkas,
  }) async {
    final kunci = await _unggahBerkasRegistrasi(
      berkas: berkas,
      jenis: JenisUnggah.fotoWajah,
      token: token,
    );
    await _kirimLangkahBerkas(
      Endpoints.registrasiFotoWajah,
      token: token,
      kunciStorage: kunci,
    );
  }

  @override
  Future<void> unggahVideoLiveness({
    required String token,
    required File berkas,
    required List<String> kodeTantangan,
    List<TangkapTantangan> tangkapan = const [],
  }) async {
    final kunci = await _unggahBerkasRegistrasi(
      berkas: berkas,
      jenis: JenisUnggah.videoLiveness,
      token: token,
    );
    final tantangan = tangkapan.isNotEmpty
        ? tangkapan
            .map((t) => {
                  'kode': t.kodeTantangan,
                  'mulai_ms': t.dimulaiMs,
                  'selesai_ms': t.selesaiMs,
                  'filter': t.namaFilter,
                })
            .toList()
        : kodeTantangan.map((k) => {'kode': k}).toList();
    try {
      await _dio.post(
        Endpoints.registrasiLiveness,
        data: {
          'token_registrasi': token,
          'kunci_storage': kunci,
          'tantangan': tantangan,
        },
        options: Options(
          extra: const {'anonim': true},
          headers: {'X-Idempotency-Key': 'lv-$token-$kunci'},
        ),
      );
    } on DioException catch (e) {
      throw _bungkus(e);
    }
  }

  @override
  Future<void> kirimPersetujuan({
    required String token,
    required PersetujuanKebijakan persetujuan,
  }) async {
    try {
      await _dio.post(
        Endpoints.registrasiPersetujuan,
        data: {
          'token_registrasi': token,
          'persetujuan': persetujuan.toJson(),
        },
        options: _opsiAnonim,
      );
    } on DioException catch (e) {
      throw _bungkus(e);
    }
  }

  @override
  Future<void> submitFinal({
    required String token,
    required PersetujuanKebijakan persetujuan,
  }) async {
    try {
      await _dio.post(
        Endpoints.registrasiFinalkan,
        data: {
          'token_registrasi': token,
          'persetujuan': persetujuan.toJson(),
          if (persetujuan.versi.isNotEmpty) 'versi_kebijakan': persetujuan.versi,
        },
        options: _opsiAnonim,
      );
    } on DioException catch (e) {
      throw _bungkus(e);
    }
  }

  @override
  Future<Map<String, dynamic>?> ambilProgres({required String token}) async {
    try {
      final res = await _dio.get(
        Endpoints.registrasiProgres,
        queryParameters: {'token_registrasi': token},
        options: _opsiAnonim,
      );
      return _bacaData(res.data);
    } on DioException catch (e) {
      throw _bungkus(e);
    }
  }

  Future<void> _kirimLangkahBerkas(
    String jalur, {
    required String token,
    required String kunciStorage,
  }) async {
    try {
      await _dio.post(
        jalur,
        data: {
          'token_registrasi': token,
          'kunci_storage': kunciStorage,
        },
        options: _opsiAnonim,
      );
    } on DioException catch (e) {
      throw _bungkus(e);
    }
  }
}
