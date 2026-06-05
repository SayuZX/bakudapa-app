import 'package:dio/dio.dart';

import '../../../core/config/endpoints.dart';
import '../../../core/config/storage_keys.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/network/klien_jaringan.dart';
import '../../../core/services/penyimpanan_aman.dart';
import '../../../shared/models/pengguna.dart';
import '../domain/repositori_otentikasi.dart';
import 'model_otp.dart';

class RepositoriOtentikasiApi implements RepositoriOtentikasi {
  RepositoriOtentikasiApi({Dio? dio, PenyimpananAman? penyimpanan})
      : _dio = dio ?? KlienJaringan.instance.dio,
        _penyimpanan = penyimpanan ?? PenyimpananAman.instance;

  final Dio _dio;
  final PenyimpananAman _penyimpanan;

  @override
  Future<HasilLogin> masuk({
    required String identitas,
    required String kataSandi,
    Map<String, dynamic>? perangkat,
  }) async {
    try {
      final res = await _dio.post(
        Endpoints.authMasuk,
        data: {
          'identitas': identitas,
          'kata_sandi': kataSandi,
          'perangkat': perangkat ?? const <String, dynamic>{},
        },
        options: Options(extra: const {'anonim': true}),
      );
      final body = res.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? body;
      if (data['perlu_otp'] == true) {
        final penggunaJson =
            (data['pengguna'] ?? data['user']) as Map<String, dynamic>? ??
                const {};
        return HasilLogin(
          pengguna: Pengguna.dariJson(penggunaJson),
          tokenAkses: '',
          tokenSegar: '',
          kedaluwarsaPada: DateTime.now(),
          perluOtp: true,
        );
      }
      return _bacaHasilLogin(body);
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    }
  }

  @override
  Future<HasilLogin> daftar({
    required String nik,
    required String namaLengkap,
    required String surel,
    required String noHp,
    required String kataSandi,
  }) async {
    try {
      final res = await _dio.post(
        Endpoints.registrasiMulai,
        data: {
          'nik': nik,
          'nama_lengkap': namaLengkap,
          'email': surel,
          'no_hp': noHp,
          'kata_sandi': kataSandi,
        },
        options: Options(extra: const {'anonim': true}),
      );
      return _bacaHasilLogin(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    }
  }

  @override
  Future<HasilKirimUlangOtp> kirimUlangOtp({
    required String identitas,
    required TipeOtp tipe,
    KanalOtp? kanal,
  }) async {
    try {
      final res = await _dio.post(
        Endpoints.authOtpKirimUlang,
        data: {
          'identitas': identitas,
          'tipe': tipe.kode,
          if (kanal != null) 'kanal': kanal.kode,
        },
        options: Options(extra: const {'anonim': true}),
      );
      final body = res.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? body;
      return HasilKirimUlangOtp.dariJson(data);
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    }
  }

  @override
  Future<HasilVerifikasiOtp> verifikasiOtp({
    required String identitas,
    required String kode,
    required TipeOtp tipe,
    KanalOtp? kanal,
  }) async {
    try {
      final res = await _dio.post(
        Endpoints.authOtpVerifikasi,
        data: {
          'identitas': identitas,
          'kode': kode,
          'tipe': tipe.kode,
          if (kanal != null) 'kanal': kanal.kode,
        },
        options: Options(extra: const {'anonim': true}),
      );
      final body = res.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? body;
      final hasil = HasilVerifikasiOtp.dariJson(tipe, data);
      if (hasil is HasilVerifikasiOtpLogin) {
        await _simpanTokenLogin(hasil);
      }
      return hasil;
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    }
  }

  @override
  Future<Pengguna> mintaProfilSaya() async {
    try {
      final res = await _dio.get(Endpoints.authSaya);
      final data = res.data as Map<String, dynamic>;
      return Pengguna.dariJson(data['data'] as Map<String, dynamic>? ?? data);
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    }
  }

  @override
  Future<void> mintaResetKataSandi({required String identitas}) async {
    try {
      await _dio.post(
        Endpoints.authLupaKataSandi,
        data: {'identitas': identitas},
        options: Options(extra: const {'anonim': true}),
      );
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    }
  }

  @override
  Future<void> setKataSandiBaru({
    required String tokenReset,
    required String kataSandiBaru,
  }) async {
    try {
      await _dio.post(
        Endpoints.authResetKataSandi,
        data: {
          'token': tokenReset,
          'kata_sandi_baru': kataSandiBaru,
        },
        options: Options(extra: const {'anonim': true}),
      );
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    }
  }

  @override
  Future<void> keluar() async {
    try {
      await _dio.post(Endpoints.authKeluar);
    } catch (_) {}
    await KlienJaringan.instance.bersihkanOtentikasi();
    await _penyimpanan.hapus(StorageKeys.profilPengguna);
    await _penyimpanan.hapus(StorageKeys.userId);
  }

  Future<HasilLogin> _bacaHasilLogin(Map<String, dynamic> body) async {
    final data = body['data'] as Map<String, dynamic>? ?? body;
    final tokenAkses = data['token_akses']?.toString() ?? data['access_token']?.toString() ?? '';
    final tokenSegar = data['token_segar']?.toString() ?? data['refresh_token']?.toString() ?? '';
    final kedaluwarsa = data['kedaluwarsa_pada']?.toString() ?? data['expires_at']?.toString();
    final penggunaJson = (data['pengguna'] ?? data['user']) as Map<String, dynamic>? ?? const {};
    final pengguna = Pengguna.dariJson(penggunaJson);
    final waktuKedaluwarsa = DateTime.tryParse(kedaluwarsa ?? '') ??
        DateTime.now().add(const Duration(hours: 1));

    await _penyimpanan.tulis(StorageKeys.accessToken, tokenAkses);
    await _penyimpanan.tulis(StorageKeys.refreshToken, tokenSegar);
    await _penyimpanan.tulis(StorageKeys.kedaluwarsa, waktuKedaluwarsa.toIso8601String());
    await _penyimpanan.tulis(StorageKeys.userId, pengguna.id);

    return HasilLogin(
      pengguna: pengguna,
      tokenAkses: tokenAkses,
      tokenSegar: tokenSegar,
      kedaluwarsaPada: waktuKedaluwarsa,
    );
  }

  Future<void> _simpanTokenLogin(HasilVerifikasiOtpLogin hasil) async {
    await _penyimpanan.tulis(StorageKeys.accessToken, hasil.tokenAkses);
    await _penyimpanan.tulis(StorageKeys.refreshToken, hasil.tokenSegar);
    await _penyimpanan.tulis(
      StorageKeys.kedaluwarsa,
      hasil.kedaluwarsaPada.toIso8601String(),
    );
    await _penyimpanan.tulis(StorageKeys.userId, hasil.pengguna.id);
  }
}
