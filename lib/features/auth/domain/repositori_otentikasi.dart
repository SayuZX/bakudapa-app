import '../../../shared/models/pengguna.dart';
import '../../../shared/models/perangkat_aktif.dart';
import '../data/model_otp.dart';

class HasilLogin {
  const HasilLogin({
    required this.pengguna,
    required this.tokenAkses,
    required this.kedaluwarsaPada,
    this.tokenRefresh,
    this.perluOtp = false,
    this.wajibGantiKataSandi = false,
    this.kelolaPerangkat,
  });

  final Pengguna pengguna;
  final String tokenAkses;
  final DateTime kedaluwarsaPada;
  final String? tokenRefresh;
  final bool perluOtp;
  final bool wajibGantiKataSandi;
  final KelolaPerangkat? kelolaPerangkat;

  bool get perluKelolaPerangkat => kelolaPerangkat?.diperlukan == true;
}

class HasilKredensial {
  const HasilKredensial({required this.diatur, this.username});

  final bool diatur;
  final String? username;
}

abstract class RepositoriOtentikasi {
  Future<HasilLogin> masuk({
    required String identitas,
    required String kataSandi,
  });

  Future<HasilLogin> cabutDanMasuk({
    required String identitas,
    required String kataSandi,
    required String idSesiDicabut,
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

  Future<Pengguna> perbaruiProfil({
    String? namaLengkap,
    String? telepon,
    String? alamat,
    String? tempatLahir,
    String? tanggalLahir,
    String? jenisKelamin,
  });

  Future<void> gantiKataSandi({
    required String kataSandiLama,
    required String kataSandiBaru,
  });

  Future<bool> cekUsername(String username);

  Future<HasilKredensial> aturKredensial({
    required String username,
    required String kataSandiBaru,
  });

  Future<void> mintaResetKataSandi({required String identitas});

  Future<void> setKataSandiBaru({
    required String tokenReset,
    required String kataSandiBaru,
  });

  Future<void> keluar();
}
