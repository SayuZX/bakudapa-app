import 'dart:async';

import 'package:dio/dio.dart';

import '../config/endpoints.dart';
import '../config/session_config.dart';
import '../config/storage_keys.dart';
import '../services/layanan_sidik_perangkat.dart';
import '../services/penyimpanan_aman.dart';
import '../utils/token_jwt.dart';

class PencegatOtentikasi extends Interceptor {
  PencegatOtentikasi({
    required this.penyimpanan,
    required this.saatTidakBerwenang,
    required this.dioPenyegar,
  });

  final PenyimpananAman penyimpanan;
  final Future<void> Function() saatTidakBerwenang;
  final Dio dioPenyegar;

  static Completer<bool>? _penyegarBerjalan;
  static const _kunciDitukar = '_otentikasi_ditukar';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['anonim'] == true) {
      handler.next(options);
      return;
    }
    if (await _perluSegarPreemtif()) {
      await _segarkan();
    }
    final token = await penyimpanan.baca(StorageKeys.accessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final kode = err.response?.statusCode;
    final sudahDitukar = err.requestOptions.extra[_kunciDitukar] == true;
    final anonim = err.requestOptions.extra['anonim'] == true;
    if (kode != 401 || sudahDitukar || anonim) {
      handler.next(err);
      return;
    }
    final berhasil = await _segarkan();
    if (!berhasil) {
      await saatTidakBerwenang();
      handler.next(err);
      return;
    }
    try {
      final tokenBaru = await penyimpanan.baca(StorageKeys.accessToken);
      final permintaanUlang = err.requestOptions
        ..extra[_kunciDitukar] = true
        ..headers['Authorization'] =
            tokenBaru != null && tokenBaru.isNotEmpty ? 'Bearer $tokenBaru' : null;
      final data = permintaanUlang.data;
      if (data is FormData) {
        permintaanUlang.data = data.clone();
      }
      final tanggapan = await dioPenyegar.fetch(permintaanUlang);
      final body = tanggapan.data;
      if (body is Map && body['success'] == true && body.containsKey('data')) {
        tanggapan.data = body['data'];
        if (body['meta'] != null) tanggapan.extra['meta'] = body['meta'];
      }
      handler.resolve(tanggapan);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await saatTidakBerwenang();
      }
      handler.next(e);
    }
  }

  Future<bool> _perluSegarPreemtif() async {
    final teks = await penyimpanan.baca(StorageKeys.kedaluwarsa);
    if (teks == null || teks.isEmpty) return false;
    final kedaluwarsa = DateTime.tryParse(teks);
    if (kedaluwarsa == null) return false;
    final sekarang = DateTime.now();
    final ambang = kedaluwarsa.subtract(SessionConfig.kelonggaranSegarToken);
    return sekarang.isAfter(ambang);
  }

  Future<bool> _segarkan() async {
    final berjalan = _penyegarBerjalan;
    if (berjalan != null) {
      return berjalan.future;
    }
    final penyelesai = Completer<bool>();
    _penyegarBerjalan = penyelesai;
    try {
      final tokenRefresh = await penyimpanan.baca(StorageKeys.refreshToken);
      if (tokenRefresh == null || tokenRefresh.isEmpty) {
        penyelesai.complete(false);
        return false;
      }
      final sidik = await LayananSidikPerangkat.instance.sidikJari();
      final hasil = await dioPenyegar.post(
        Endpoints.authSegarkanToken,
        data: {
          'token_refresh': tokenRefresh,
          'device_fingerprint': sidik,
        },
        options: Options(extra: const {'anonim': true}),
      );
      final isi = _baca(hasil.data);
      final tokenAkses = isi?['token_akses'];
      if (tokenAkses is String && tokenAkses.isNotEmpty) {
        await penyimpanan.tulis(StorageKeys.accessToken, tokenAkses);
        final refreshBaru = isi?['token_refresh'];
        if (refreshBaru is String && refreshBaru.isNotEmpty) {
          await penyimpanan.tulis(StorageKeys.refreshToken, refreshBaru);
        }
        final kedaluwarsaRaw = isi?['kedaluwarsa_pada'];
        final kedaluwarsa = kedaluwarsaRaw is String
            ? DateTime.tryParse(kedaluwarsaRaw)
            : TokenJwt.bacaKedaluwarsa(tokenAkses);
        if (kedaluwarsa != null) {
          await penyimpanan.tulis(
            StorageKeys.kedaluwarsa,
            kedaluwarsa.toIso8601String(),
          );
        }
        penyelesai.complete(true);
        return true;
      }
      penyelesai.complete(false);
      return false;
    } catch (_) {
      penyelesai.complete(false);
      return false;
    } finally {
      _penyegarBerjalan = null;
    }
  }

  Map<String, dynamic>? _baca(dynamic body) {
    if (body is Map<String, dynamic>) {
      if (body['data'] is Map<String, dynamic>) {
        return body['data'] as Map<String, dynamic>;
      }
      return body;
    }
    return null;
  }
}
