import '../../../shared/models/pengguna.dart';
import '../data/model_otp.dart';

class HasilLogin {
  const HasilLogin({
    required this.pengguna,
    required this.tokenAkses,
    required this.tokenSegar,
    required this.kedaluwarsaPada,
    this.perluOtp = false,
  });

  final Pengguna pengguna;
  final String tokenAkses;
  final String tokenSegar;
  final DateTime kedaluwarsaPada;
  final bool perluOtp;
}

abstract class RepositoriOtentikasi {
  Future<HasilLogin> masuk({
    required String identitas,
    required String kataSandi,
    Map<String, dynamic>? perangkat,
  });

  Future<HasilLogin> daftar({
    required String nik,
    required String namaLengkap,
    required String surel,
    required String noHp,
    required String kataSandi,
  });

  Future<HasilKirimUlangOtp> kirimUlangOtp({
    required String identitas,
    required TipeOtp tipe,
    KanalOtp? kanal,
  });

  Future<HasilVerifikasiOtp> verifikasiOtp({
    required String identitas,
    required String kode,
    required TipeOtp tipe,
    KanalOtp? kanal,
  });

  Future<Pengguna> mintaProfilSaya();

  Future<void> mintaResetKataSandi({required String identitas});

  Future<void> setKataSandiBaru({
    required String tokenReset,
    required String kataSandiBaru,
  });

  Future<void> keluar();
}
