import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/activity/jenis_aktivitas.dart';
import '../../core/activity/layanan_pencatat_aktivitas.dart';
import '../../core/config/storage_keys.dart';
import '../../core/location/layanan_jejak_lokasi.dart';
import '../../core/network/klien_jaringan.dart';
import '../../core/security/penjaga_keamanan.dart';
import '../../core/services/penyimpanan_aman.dart';
import '../../features/auth/domain/repositori_otentikasi.dart';
import '../models/pengguna.dart';
import 'penyedia_repositori.dart';

enum StatusOtentikasi {
  memuat,
  masuk,
  belumMasuk,
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
    this.wajibAturKredensial = false,
    this.peringatanVpn = false,
  });

  final StatusOtentikasi status;
  final Pengguna? pengguna;
  final String? pesan;
  final LaporanKeamanan? laporanKeamanan;
  final JejakLokasi? jejakLokasi;
  final bool wajibAturKredensial;
  final bool peringatanVpn;

  bool get terblokirOlehKeamanan =>
      status == StatusOtentikasi.perangkatTidakAman ||
      status == StatusOtentikasi.gagalCekKeamanan;

  KondisiOtentikasi salin({
    StatusOtentikasi? status,
    Pengguna? pengguna,
    String? pesan,
    LaporanKeamanan? laporanKeamanan,
    JejakLokasi? jejakLokasi,
    bool? wajibAturKredensial,
    bool? peringatanVpn,
    bool bersihkanPengguna = false,
    bool bersihkanPesan = false,
  }) {
    return KondisiOtentikasi(
      status: status ?? this.status,
      pengguna: bersihkanPengguna ? null : (pengguna ?? this.pengguna),
      pesan: bersihkanPesan ? null : (pesan ?? this.pesan),
      laporanKeamanan: laporanKeamanan ?? this.laporanKeamanan,
      jejakLokasi: jejakLokasi ?? this.jejakLokasi,
      wajibAturKredensial: wajibAturKredensial ?? this.wajibAturKredensial,
      peringatanVpn: peringatanVpn ?? this.peringatanVpn,
    );
  }
}

class PengaturOtentikasi extends StateNotifier<KondisiOtentikasi> {
  PengaturOtentikasi(this._ref, {bool mulaiOtomatis = true})
    : super(const KondisiOtentikasi(status: StatusOtentikasi.memuat)) {
    if (mulaiOtomatis) {
      _mulai();
    }
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
      peringatanVpn: laporan.vpnAktif,
    );
  }

  void tandaiPeringatanVpnDitampilkan() {
    if (!state.peringatanVpn) return;
    state = state.salin(peringatanVpn: false);
  }

  StatusOtentikasi _statusDariAlasan(AlasanBlokir a) {
    switch (a) {
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
      final pengguna = await _ref
          .read(penyediaRepositoriOtentikasi)
          .mintaProfilSaya();
      return KondisiOtentikasi(
        status: StatusOtentikasi.masuk,
        pengguna: pengguna,
        wajibAturKredensial: pengguna.wajibGantiKataSandi,
      );
    } catch (_) {
      await KlienJaringan.instance.bersihkanOtentikasi();
      return const KondisiOtentikasi(status: StatusOtentikasi.belumMasuk);
    }
  }

  Future<void> cobaUlangPemeriksaan() async {
    state = const KondisiOtentikasi(status: StatusOtentikasi.memuat);
    await _mulai();
  }

  Future<HasilLogin> masuk({
    required String identitas,
    required String kataSandi,
  }) async {
    final repo = _ref.read(penyediaRepositoriOtentikasi);
    final hasil = await repo.masuk(identitas: identitas, kataSandi: kataSandi);
    return _finalkanLogin(hasil);
  }

  Future<HasilLogin> cabutDanMasuk({
    required String identitas,
    required String kataSandi,
    required String idSesiDicabut,
  }) async {
    final repo = _ref.read(penyediaRepositoriOtentikasi);
    final hasil = await repo.cabutDanMasuk(
      identitas: identitas,
      kataSandi: kataSandi,
      idSesiDicabut: idSesiDicabut,
    );
    return _finalkanLogin(hasil);
  }

  Future<HasilLogin> _finalkanLogin(HasilLogin hasil) async {
    if (hasil.perluOtp) {
      return hasil;
    }

    if (hasil.perluKelolaPerangkat) {
      state = state.salin(pengguna: hasil.pengguna, bersihkanPesan: true);
      return hasil;
    }

    if (hasil.wajibGantiKataSandi) {
      state = state.salin(
        status: StatusOtentikasi.masuk,
        pengguna: hasil.pengguna,
        wajibAturKredensial: true,
        bersihkanPesan: true,
      );
      return hasil;
    }

    final repo = _ref.read(penyediaRepositoriOtentikasi);
    var pengguna = hasil.pengguna;
    try {
      pengguna = await repo.mintaProfilSaya();
    } catch (_) {}
    state = state.salin(
      status: StatusOtentikasi.masuk,
      pengguna: pengguna,
      wajibAturKredensial: false,
      bersihkanPesan: true,
    );
    unawaited(LayananPencatatAktivitas.instance.catat(JenisAktivitas.masuk));
    return hasil;
  }

  Future<void> lanjutkanSetelahKelola() async {
    final repo = _ref.read(penyediaRepositoriOtentikasi);
    var pengguna = state.pengguna;
    try {
      pengguna = await repo.mintaProfilSaya();
    } catch (_) {}
    state = state.salin(
      status: StatusOtentikasi.masuk,
      pengguna: pengguna,
      bersihkanPesan: true,
    );
    unawaited(LayananPencatatAktivitas.instance.catat(JenisAktivitas.masuk));
  }

  void tandaiSudahMasukDariOtp(
    Pengguna pengguna, {
    bool wajibAturKredensial = false,
  }) {
    state = state.salin(
      status: StatusOtentikasi.masuk,
      pengguna: pengguna,
      wajibAturKredensial: wajibAturKredensial,
      bersihkanPesan: true,
    );
    if (!wajibAturKredensial) {
      unawaited(LayananPencatatAktivitas.instance.catat(JenisAktivitas.masuk));
    }
  }

  void selesaiAturKredensial({String? username}) {
    final pengguna = state.pengguna;
    state = state.salin(
      pengguna: pengguna != null && username != null && username.isNotEmpty
          ? pengguna.salin(username: username)
          : pengguna,
      wajibAturKredensial: false,
      bersihkanPesan: true,
    );
    unawaited(LayananPencatatAktivitas.instance.catat(JenisAktivitas.masuk));
  }

  Future<void> keluar() async {
    await LayananPencatatAktivitas.instance.catat(JenisAktivitas.keluar);
    await LayananPencatatAktivitas.instance.flush();
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
