import 'package:dio/dio.dart';

import '../../../core/config/endpoints.dart';
import '../../../core/config/storage_keys.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/network/klien_jaringan.dart';
import '../../../core/services/layanan_sidik_perangkat.dart';
import '../../../core/services/penyimpanan_aman.dart';
import '../../../core/utils/token_jwt.dart';
import '../../../shared/models/pengguna.dart';
import '../../../shared/models/perangkat_aktif.dart';
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
  }) async {
    try {
      final perangkat = await LayananSidikPerangkat.instance.identitas();
      final res = await _dio.post(
        Endpoints.authMasuk,
        data: {
          'identitas': identitas,
          'kata_sandi': kataSandi,
          ...perangkat.keJsonLogin(),
        },
        options: Options(extra: const {'anonim': true}),
      );
      return _simpanSesi(_bacaData(res.data));
    } on DioException catch (e) {
      final kesalahan = e.error;
      if (kesalahan is KesalahanTidakBerwenang ||
          kesalahan is KesalahanKredensialSalah) {
        throw const KesalahanKredensialSalah();
      }
      throw kesalahan is Kesalahan ? kesalahan : const KesalahanTakDikenal();
    }
  }

  @override
  Future<HasilLogin> cabutDanMasuk({
    required String identitas,
    required String kataSandi,
    required String idSesiDicabut,
  }) async {
    try {
      final perangkat = await LayananSidikPerangkat.instance.identitas();
      final res = await _dio.post(
        Endpoints.authCabutDanMasuk,
        data: {
          'identitas': identitas,
          'kata_sandi': kataSandi,
          'id_sesi_dicabut': idSesiDicabut,
          'perangkat': perangkat.keBlokPerangkat(),
        },
        options: Options(extra: const {'anonim': true}),
      );
      return _simpanSesi(_bacaData(res.data));
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
      return HasilKirimUlangOtp.dariJson(_bacaData(res.data));
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
      final perangkat = await LayananSidikPerangkat.instance.identitas();
      final res = await _dio.post(
        Endpoints.authOtpVerifikasi,
        data: {
          'identitas': identitas,
          'kode': kode,
          'tipe': tipe.kode,
          if (kanal != null) 'kanal': kanal.kode,
          'device_fingerprint': perangkat.sidikJari,
          'perangkat': perangkat.keBlokPerangkat(),
        },
        options: Options(extra: const {'anonim': true}),
      );
      final hasil = HasilVerifikasiOtp.dariJson(tipe, _bacaData(res.data));
      if (hasil is HasilVerifikasiOtpLogin) {
        await _simpanToken(
          tokenAkses: hasil.tokenAkses,
          tokenRefresh: hasil.tokenSegar,
          kedaluwarsa: hasil.kedaluwarsaPada,
          userId: hasil.pengguna.id,
        );
      }
      return hasil;
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    }
  }

  @override
  Future<bool> cekUsername(String username) async {
    try {
      final res = await _dio.get(
        Endpoints.profilCekUsername,
        queryParameters: {'username': username},
      );
      return _bacaData(res.data)['tersedia'] == true;
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    }
  }

  @override
  Future<HasilKredensial> aturKredensial({
    required String username,
    required String kataSandiBaru,
  }) async {
    try {
      final res = await _dio.put(
        Endpoints.profilKredensial,
        data: {
          'username': username,
          'kata_sandi_baru': kataSandiBaru,
        },
      );
      final data = _bacaData(res.data);
      return HasilKredensial(
        diatur: data['kredensial_diatur'] == true,
        username: data['username']?.toString(),
      );
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    }
  }

  @override
  Future<Pengguna> mintaProfilSaya() async {
    try {
      final res = await _dio.get(Endpoints.authSaya);
      final data = _bacaData(res.data);
      final pengguna = data['pengguna'];
      return Pengguna.dariJson(
        pengguna is Map<String, dynamic> ? pengguna : data,
      );
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    }
  }

  @override
  Future<Pengguna> perbaruiProfil({
    String? namaLengkap,
    String? telepon,
    String? alamat,
    String? tempatLahir,
    String? tanggalLahir,
    String? jenisKelamin,
  }) async {
    try {
      await _dio.put(
        Endpoints.profil,
        data: {
          'pengguna': {
            'nama_lengkap': ?namaLengkap,
            'tempat_lahir': ?tempatLahir,
            'tanggal_lahir': ?tanggalLahir,
            'jenis_kelamin': ?jenisKelamin,
          },
        },
      );
      return mintaProfilSaya();
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    }
  }

  @override
  Future<void> gantiKataSandi({
    required String kataSandiLama,
    required String kataSandiBaru,
  }) async {
    try {
      await _dio.put(
        Endpoints.profilKataSandi,
        data: {
          'kata_sandi_lama': kataSandiLama,
          'kata_sandi_baru': kataSandiBaru,
        },
      );
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

  Future<HasilLogin> _simpanSesi(Map<String, dynamic> data) async {
    final pengguna = Pengguna.dariJson(
      data['pengguna'] is Map<String, dynamic>
          ? data['pengguna'] as Map<String, dynamic>
          : const {},
    );
    final tokenAkses = data['token_akses']?.toString() ?? '';
    final tokenRefresh = data['token_refresh']?.toString();
    final perluOtp = data['perlu_otp'] == true;
    final wajibGanti = data['wajib_ganti_kata_sandi'] == true;
    final kedaluwarsa =
        DateTime.tryParse(data['kedaluwarsa_pada']?.toString() ?? '') ??
            TokenJwt.bacaKedaluwarsa(tokenAkses) ??
            DateTime.now().add(const Duration(hours: 1));

    await _simpanToken(
      tokenAkses: tokenAkses,
      tokenRefresh: tokenRefresh,
      kedaluwarsa: kedaluwarsa,
      userId: pengguna.id,
    );

    final kelolaRaw = data['kelola_perangkat'];
    final kelola = kelolaRaw is Map<String, dynamic>
        ? KelolaPerangkat.dariJson(kelolaRaw)
        : null;

    return HasilLogin(
      pengguna: pengguna,
      tokenAkses: tokenAkses,
      tokenRefresh: tokenRefresh,
      kedaluwarsaPada: kedaluwarsa,
      perluOtp: perluOtp,
      wajibGantiKataSandi: wajibGanti,
      kelolaPerangkat: kelola,
    );
  }

  Future<void> _simpanToken({
    required String tokenAkses,
    String? tokenRefresh,
    required DateTime kedaluwarsa,
    required String userId,
  }) async {
    if (tokenAkses.isNotEmpty) {
      await _penyimpanan.tulis(StorageKeys.accessToken, tokenAkses);
    }
    if (tokenRefresh != null && tokenRefresh.isNotEmpty) {
      await _penyimpanan.tulis(StorageKeys.refreshToken, tokenRefresh);
    }
    await _penyimpanan.tulis(
      StorageKeys.kedaluwarsa,
      kedaluwarsa.toIso8601String(),
    );
    if (userId.isNotEmpty) {
      await _penyimpanan.tulis(StorageKeys.userId, userId);
    }
  }

  Map<String, dynamic> _bacaData(dynamic body) {
    if (body is Map<String, dynamic>) {
      final inner = body['data'];
      if (inner is Map<String, dynamic>) return inner;
      return body;
    }
    return const {};
  }
}
