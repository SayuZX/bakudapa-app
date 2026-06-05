import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/biometric/model_hasil_biometrik.dart';
import '../../../core/config/endpoints.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/network/klien_jaringan.dart';
import 'model/data_registrasi.dart';

class TantanganSuaraDariApi {
  const TantanganSuaraDariApi({
    required this.kalimat,
    this.kalimatId,
    this.kalimatEn,
    this.kode,
  });
  final String kalimat;
  final String? kalimatId;
  final String? kalimatEn;
  final String? kode;
}

abstract class RepositoriRegistrasi {
  Future<String> mulaiSesi();
  Future<TantanganSuaraDariApi> tantanganSuara();
  Future<void> kirimIdentitas({
    required String token,
    required IdentitasRegistrasi identitas,
  });
  Future<void> unggahFotoDokumen({required String token, required File berkas});
  Future<void> unggahFotoWajah({required String token, required File berkas});
  Future<void> unggahVideoLiveness({
    required String token,
    required File berkas,
    required List<String> kodeTantangan,
    List<TangkapTantangan> tangkapan = const [],
  });
  Future<void> unggahSuara({
    required String token,
    required File berkas,
    required String kalimat,
  });
  Future<void> kirimVerifikasiSidikJari({
    required String token,
    required String idSesi,
    required HasilBiometrikSidikJari hasil,
    required Map<String, Object?> metadataPerangkat,
  });
  Future<void> kirimPersetujuan({
    required String token,
    required PersetujuanKebijakan persetujuan,
  });
  Future<void> submitFinal({required String token});
}

class RepositoriRegistrasiApi implements RepositoriRegistrasi {
  RepositoriRegistrasiApi({Dio? dio})
    : _dio = dio ?? KlienJaringan.instance.dio;
  final Dio _dio;

  Kesalahan _bungkus(DioException e) => e.error is Kesalahan
      ? e.error! as Kesalahan
      : const KesalahanTakDikenal();

  Map<String, dynamic>? _bacaData(dynamic body) {
    if (body is! Map) return null;
    final map = Map<String, dynamic>.from(body);
    final inner = map['data'];
    if (inner is Map) return Map<String, dynamic>.from(inner);
    return map;
  }

  @override
  Future<String> mulaiSesi() async {
    try {
      final res = await _dio.post(
        '/auth/register/start',
        options: Options(extra: const {'anonim': true}),
      );
      final data = _bacaData(res.data);
      return data?['token']?.toString() ??
          data?['session_token']?.toString() ??
          '';
    } on DioException catch (e) {
      throw _bungkus(e);
    }
  }

  @override
  Future<TantanganSuaraDariApi> tantanganSuara() async {
    try {
      final res = await _dio.get(Endpoints.registrasiTantanganSuara);
      final data = _bacaData(res.data);
      final id = data?['kalimat_id']?.toString();
      final en = data?['kalimat_en']?.toString();
      final bahasa =
          _dio.options.headers['Accept-Language']?.toString() ?? 'id';
      final kalimat = bahasa.startsWith('en')
          ? (en ?? id ?? data?['sentence']?.toString() ?? '')
          : (id ?? en ?? data?['sentence']?.toString() ?? '');
      return TantanganSuaraDariApi(
        kalimat: kalimat,
        kalimatId: id,
        kalimatEn: en,
        kode: data?['kode_unik']?.toString() ?? data?['code']?.toString(),
      );
    } on DioException catch (e) {
      throw _bungkus(e);
    }
  }

  @override
  Future<void> kirimIdentitas({
    required String token,
    required IdentitasRegistrasi identitas,
  }) async {
    try {
      await _dio.post(
        '/auth/register/identity',
        data: identitas.toJson(),
        options: Options(headers: _header(token)),
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
    await _unggah('/auth/register/document-photo', token, berkas, 'document');
  }

  @override
  Future<void> unggahFotoWajah({
    required String token,
    required File berkas,
  }) async {
    await _unggah('/auth/register/face-photo', token, berkas, 'face');
  }

  @override
  Future<void> unggahVideoLiveness({
    required String token,
    required File berkas,
    required List<String> kodeTantangan,
    List<TangkapTantangan> tangkapan = const [],
  }) async {
    try {
      final segmen = tangkapan.map((e) => e.toJson()).toList();
      final mapForm = <String, dynamic>{
        'video': await MultipartFile.fromFile(
          berkas.path,
          filename: 'liveness.mp4',
        ),
        'challenges': kodeTantangan.join(','),
        'segmen_tantangan': jsonEncode(segmen),
      };
      for (var i = 0; i < tangkapan.length; i++) {
        final t = tangkapan[i];
        mapForm['tangkapan[$i]'] = await MultipartFile.fromFile(
          t.jalurFoto,
          filename: 'tangkapan-${t.kodeTantangan}.png',
        );
      }
      final form = FormData.fromMap(mapForm);
      await _dio.post(
        Endpoints.registrasiLiveness,
        data: form,
        options: Options(headers: _header(token)),
      );
    } on DioException catch (e) {
      throw _bungkus(e);
    }
  }

  @override
  Future<void> unggahSuara({
    required String token,
    required File berkas,
    required String kalimat,
  }) async {
    try {
      final form = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          berkas.path,
          filename: 'voice.m4a',
        ),
        'sentence': kalimat,
      });
      await _dio.post(
        '/auth/register/voice-verification',
        data: form,
        options: Options(headers: _header(token)),
      );
    } on DioException catch (e) {
      throw _bungkus(e);
    }
  }

  @override
  Future<void> kirimVerifikasiSidikJari({
    required String token,
    required String idSesi,
    required HasilBiometrikSidikJari hasil,
    required Map<String, Object?> metadataPerangkat,
  }) async {
    try {
      if (hasil.sumber == SumberBiometrik.scannerEksternal) {
        throw const KesalahanUnggah(
          'Verifikasi sidik jari via scanner eksternal belum tersedia.',
        );
      }
      final jalur = '/auth/register/fingerprint-verification';
      final body = hasil.toJsonPerangkat(
        idSesi: idSesi,
        metadataPerangkat: metadataPerangkat,
      );
      await _dio.post(
        jalur,
        data: body,
        options: Options(
          headers: {
            ..._header(token),
            'X-Idempotency-Key':
                'fp-$idSesi-${hasil.diverifikasiPada?.millisecondsSinceEpoch ?? 0}',
          },
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
        '/auth/register/policy-acceptance',
        data: persetujuan.toJson(),
        options: Options(headers: _header(token)),
      );
    } on DioException catch (e) {
      throw _bungkus(e);
    }
  }

  @override
  Future<void> submitFinal({required String token}) async {
    try {
      await _dio.post(
        '/auth/register/submit',
        options: Options(headers: _header(token)),
      );
    } on DioException catch (e) {
      throw _bungkus(e);
    }
  }

  Future<void> _unggah(
    String jalur,
    String token,
    File berkas,
    String namaField,
  ) async {
    try {
      final form = FormData.fromMap({
        namaField: await MultipartFile.fromFile(berkas.path),
      });
      await _dio.post(
        jalur,
        data: form,
        options: Options(headers: _header(token)),
      );
    } on DioException catch (e) {
      throw _bungkus(e);
    }
  }

  Map<String, String> _header(String token) => {'X-Registration-Token': token};
}
