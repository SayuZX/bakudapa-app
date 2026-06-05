import 'dart:async';

import 'package:dio/dio.dart';

import '../config/session_config.dart';
import '../config/storage_keys.dart';
import '../services/penyimpanan_aman.dart';

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
    if (kode != 401 || sudahDitukar) {
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
      final refresh = await penyimpanan.baca(StorageKeys.refreshToken);
      if (refresh == null || refresh.isEmpty) {
        penyelesai.complete(false);
        return false;
      }
      final hasil = await dioPenyegar.post(
        '/auth/segarkan-token',
        data: {'token_refresh': refresh},
        options: Options(extra: const {'anonim': true}),
      );
      final isi = _baca(hasil.data);
      final akses = isi?['token_akses'];
      final segar = isi?['token_refresh'];
      final kedaluwarsa = isi?['kedaluwarsa_pada'];
      if (akses is String && akses.isNotEmpty) {
        await penyimpanan.tulis(StorageKeys.accessToken, akses);
        if (segar is String && segar.isNotEmpty) {
          await penyimpanan.tulis(StorageKeys.refreshToken, segar);
        }
        if (kedaluwarsa is String && kedaluwarsa.isNotEmpty) {
          await penyimpanan.tulis(StorageKeys.kedaluwarsa, kedaluwarsa);
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
