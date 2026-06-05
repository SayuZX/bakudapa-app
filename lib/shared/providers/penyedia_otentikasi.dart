import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/storage_keys.dart';
import '../../core/location/layanan_jejak_lokasi.dart';
import '../../core/network/klien_jaringan.dart';
import '../../core/security/penjaga_keamanan.dart';
import '../../core/services/penyimpanan_aman.dart';
import '../models/pengguna.dart';
import 'penyedia_repositori.dart';

enum StatusOtentikasi {
  memuat,
  masuk,
  belumMasuk,
  vpnTerdeteksi,
  perangkatTidakAman,
  gagalCekKeamanan,
}

class KondisiOtentikasi {
  const KondisiOtentikasi({
    required this.status,
    this.pengguna,
    this.pesan,
    this.laporanKeamanan,
    this.jejakLokasi,
  });

  final StatusOtentikasi status;
  final Pengguna? pengguna;
  final String? pesan;
  final LaporanKeamanan? laporanKeamanan;
  final JejakLokasi? jejakLokasi;

  bool get terblokirOlehKeamanan =>
      status == StatusOtentikasi.vpnTerdeteksi ||
      status == StatusOtentikasi.perangkatTidakAman ||
      status == StatusOtentikasi.gagalCekKeamanan;

  KondisiOtentikasi salin({
    StatusOtentikasi? status,
    Pengguna? pengguna,
    String? pesan,
    LaporanKeamanan? laporanKeamanan,
    JejakLokasi? jejakLokasi,
    bool bersihkanPengguna = false,
    bool bersihkanPesan = false,
  }) {
    return KondisiOtentikasi(
      status: status ?? this.status,
      pengguna: bersihkanPengguna ? null : (pengguna ?? this.pengguna),
      pesan: bersihkanPesan ? null : (pesan ?? this.pesan),
      laporanKeamanan: laporanKeamanan ?? this.laporanKeamanan,
      jejakLokasi: jejakLokasi ?? this.jejakLokasi,
    );
  }
}

class PengaturOtentikasi extends StateNotifier<KondisiOtentikasi> {
  PengaturOtentikasi(this._ref)
      : super(const KondisiOtentikasi(status: StatusOtentikasi.memuat)) {
    _mulai();
  }

  final Ref _ref;

  static const Duration _splashMinimum = Duration(milliseconds: 1400);

  static const String _tokenDemo = 'demo-token-dev';
  static const Pengguna _penggunaDemo = Pengguna(
    id: 'demo',
    nik: '8201010101010001',
    namaLengkap: 'Pengguna Demo',
    surel: 'demo@bakudapa.test',
    noHp: '081234567890',
    kabupatenKota: 'Kota Ternate',
    kecamatan: 'Ternate Tengah',
    terverifikasi: true,
  );
  bool _demo = false;

  Future<void> masukDemo() async {
    if (!kDebugMode) return;
    _demo = true;
    final penyimpanan = PenyimpananAman.instance;
    await penyimpanan.tulis(StorageKeys.accessToken, _tokenDemo);
    await penyimpanan.tulis(
      StorageKeys.kedaluwarsa,
      DateTime.now().add(const Duration(days: 365)).toIso8601String(),
    );
    state = state.salin(
      status: StatusOtentikasi.masuk,
      pengguna: _penggunaDemo,
      bersihkanPesan: true,
    );
  }

  Future<void> _mulai() async {
    final mulai = DateTime.now();

    final laporan = await PenjagaKeamanan.instance.periksa();

    if (laporan.terblokir) {
      await _tundaSisa(mulai);
      state = KondisiOtentikasi(
        status: _statusDariAlasan(laporan.alasan),
        laporanKeamanan: laporan,
      );
      return;
    }

    final lokasiFuture = LayananJejakLokasi.instance.rekamSekali();
    final hasilAuth = await _periksaSesi();
    final jejak = await lokasiFuture;

    await _tundaSisa(mulai);
    state = hasilAuth.salin(
      laporanKeamanan: laporan,
      jejakLokasi: jejak,
    );
  }

  StatusOtentikasi _statusDariAlasan(AlasanBlokir a) {
    switch (a) {
      case AlasanBlokir.vpn:
        return StatusOtentikasi.vpnTerdeteksi;
      case AlasanBlokir.perangkatTidakAman:
        return StatusOtentikasi.perangkatTidakAman;
      case AlasanBlokir.gagalCek:
        return StatusOtentikasi.gagalCekKeamanan;
      case AlasanBlokir.tidakAda:
        return StatusOtentikasi.memuat;
    }
  }

  Future<void> _tundaSisa(DateTime mulai) async {
    final berlalu = DateTime.now().difference(mulai);
    final sisa = _splashMinimum - berlalu;
    if (sisa > Duration.zero) {
      await Future<void>.delayed(sisa);
    }
  }

  Future<KondisiOtentikasi> _periksaSesi() async {
    final penyimpanan = PenyimpananAman.instance;
    final token = await penyimpanan.baca(StorageKeys.accessToken);
    if (kDebugMode && token == _tokenDemo) {
      _demo = true;
      return const KondisiOtentikasi(
        status: StatusOtentikasi.masuk,
        pengguna: _penggunaDemo,
      );
    }
    final tanggal = await penyimpanan.baca(StorageKeys.kedaluwarsa);
    if (token == null || token.isEmpty) {
      return const KondisiOtentikasi(status: StatusOtentikasi.belumMasuk);
    }
    final kedaluwarsa = DateTime.tryParse(tanggal ?? '');
    if (kedaluwarsa != null && kedaluwarsa.isBefore(DateTime.now())) {
      await KlienJaringan.instance.bersihkanOtentikasi();
      return const KondisiOtentikasi(status: StatusOtentikasi.belumMasuk);
    }
    try {
      final pengguna = await _ref.read(penyediaRepositoriOtentikasi).mintaProfilSaya();
      return KondisiOtentikasi(status: StatusOtentikasi.masuk, pengguna: pengguna);
    } catch (_) {
      await KlienJaringan.instance.bersihkanOtentikasi();
      return const KondisiOtentikasi(status: StatusOtentikasi.belumMasuk);
    }
  }

  Future<void> cobaUlangPemeriksaan() async {
    state = const KondisiOtentikasi(status: StatusOtentikasi.memuat);
    await _mulai();
  }

  Future<bool> masuk({required String identitas, required String kataSandi}) async {
    final repo = _ref.read(penyediaRepositoriOtentikasi);
    final hasil = await repo.masuk(identitas: identitas, kataSandi: kataSandi);
    if (hasil.perluOtp) {
      return true;
    }
    state = state.salin(
      status: StatusOtentikasi.masuk,
      pengguna: hasil.pengguna,
      bersihkanPesan: true,
    );
    return false;
  }

  void tandaiSudahMasukDariOtp(Pengguna pengguna) {
    state = state.salin(
      status: StatusOtentikasi.masuk,
      pengguna: pengguna,
      bersihkanPesan: true,
    );
  }

  Future<void> daftar({
    required String nik,
    required String namaLengkap,
    required String surel,
    required String noHp,
    required String kataSandi,
  }) async {
    final repo = _ref.read(penyediaRepositoriOtentikasi);
    final hasil = await repo.daftar(
      nik: nik,
      namaLengkap: namaLengkap,
      surel: surel,
      noHp: noHp,
      kataSandi: kataSandi,
    );
    state = state.salin(
      status: StatusOtentikasi.masuk,
      pengguna: hasil.pengguna,
      bersihkanPesan: true,
    );
  }

  Future<void> keluar() async {
    if (_demo) {
      _demo = false;
      await KlienJaringan.instance.bersihkanOtentikasi();
      LayananJejakLokasi.instance.bersihkan();
      state = state.salin(
        status: StatusOtentikasi.belumMasuk,
        bersihkanPengguna: true,
        bersihkanPesan: true,
      );
      return;
    }
    await _ref.read(penyediaRepositoriOtentikasi).keluar();
    LayananJejakLokasi.instance.bersihkan();
    state = state.salin(
      status: StatusOtentikasi.belumMasuk,
      bersihkanPengguna: true,
      bersihkanPesan: true,
    );
  }

  void paksaKeluar() {
    if (_demo) return;
    LayananJejakLokasi.instance.bersihkan();
    state = state.salin(
      status: StatusOtentikasi.belumMasuk,
      bersihkanPengguna: true,
      pesan: 'Sesi Anda telah berakhir. Silakan masuk kembali.',
    );
  }

  Future<void> perbaruiProfil(Pengguna pengguna) async {
    state = state.salin(pengguna: pengguna);
  }
}

final penyediaOtentikasi =
    StateNotifierProvider<PengaturOtentikasi, KondisiOtentikasi>((ref) {
  return PengaturOtentikasi(ref);
});
