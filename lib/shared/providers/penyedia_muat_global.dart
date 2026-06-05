import 'package:flutter_riverpod/flutter_riverpod.dart';

class KondisiMuatGlobal {
  const KondisiMuatGlobal({
    this.aktif = false,
    this.judul,
    this.pesan,
    this.kemajuan,
  });

  final bool aktif;
  final String? judul;
  final String? pesan;
  final double? kemajuan;

  KondisiMuatGlobal salin({
    bool? aktif,
    String? judul,
    String? pesan,
    double? kemajuan,
    bool kosongkanKemajuan = false,
  }) {
    return KondisiMuatGlobal(
      aktif: aktif ?? this.aktif,
      judul: judul ?? this.judul,
      pesan: pesan ?? this.pesan,
      kemajuan: kosongkanKemajuan ? null : (kemajuan ?? this.kemajuan),
    );
  }

  static const mati = KondisiMuatGlobal();
}

class PengaturMuatGlobal extends StateNotifier<KondisiMuatGlobal> {
  PengaturMuatGlobal() : super(KondisiMuatGlobal.mati);

  void tampilkan({String? judul, String? pesan, double? kemajuan}) {
    state = KondisiMuatGlobal(
      aktif: true,
      judul: judul,
      pesan: pesan,
      kemajuan: kemajuan,
    );
  }

  void perbaruiPesan({String? judul, String? pesan, double? kemajuan}) {
    if (!state.aktif) return;
    state = state.salin(judul: judul, pesan: pesan, kemajuan: kemajuan);
  }

  void perbaruiKemajuan(double nilai) {
    if (!state.aktif) return;
    state = state.salin(kemajuan: nilai.clamp(0.0, 1.0));
  }

  void sembunyikan() {
    state = KondisiMuatGlobal.mati;
  }

  Future<T> jalankan<T>(
    Future<T> Function() tugas, {
    String? judul,
    String? pesan,
  }) async {
    tampilkan(judul: judul, pesan: pesan);
    try {
      return await tugas();
    } finally {
      sembunyikan();
    }
  }
}

final penyediaMuatGlobal =
    StateNotifierProvider<PengaturMuatGlobal, KondisiMuatGlobal>(
        (ref) => PengaturMuatGlobal());
