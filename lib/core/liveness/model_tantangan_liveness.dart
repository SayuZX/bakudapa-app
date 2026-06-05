enum JenisTantanganLiveness {
  kedipMata,
  bukaMulut,
  senyum,
  hadapKiri,
  hadapKanan,
  anggukKepala,
}

enum ArahTantangan { tidakAda, kiri, kanan, atas, bawah, pusat }

class TantanganLiveness {
  const TantanganLiveness({
    required this.jenis,
    required this.instruksi,
    this.detikSelesai = 8,
  });

  final JenisTantanganLiveness jenis;
  final String instruksi;
  final int detikSelesai;

  String get kode {
    switch (jenis) {
      case JenisTantanganLiveness.kedipMata:
        return 'BLINK';
      case JenisTantanganLiveness.bukaMulut:
        return 'OPEN_MOUTH';
      case JenisTantanganLiveness.senyum:
        return 'SMILE';
      case JenisTantanganLiveness.hadapKiri:
        return 'TURN_LEFT';
      case JenisTantanganLiveness.hadapKanan:
        return 'TURN_RIGHT';
      case JenisTantanganLiveness.anggukKepala:
        return 'NOD';
    }
  }

  ArahTantangan get arahUtama {
    switch (jenis) {
      case JenisTantanganLiveness.hadapKiri:
        return ArahTantangan.kiri;
      case JenisTantanganLiveness.hadapKanan:
        return ArahTantangan.kanan;
      case JenisTantanganLiveness.anggukKepala:
        return ArahTantangan.bawah;
      case JenisTantanganLiveness.kedipMata:
      case JenisTantanganLiveness.bukaMulut:
      case JenisTantanganLiveness.senyum:
        return ArahTantangan.pusat;
    }
  }

  String pesanSalah(ArahTantangan arahSalah) {
    switch (jenis) {
      case JenisTantanganLiveness.hadapKiri:
        return 'Hadapkan wajah sedikit ke kiri.';
      case JenisTantanganLiveness.hadapKanan:
        return 'Hadapkan wajah sedikit ke kanan.';
      case JenisTantanganLiveness.anggukKepala:
        return 'Anggukkan kepala perlahan ke bawah lalu kembali.';
      case JenisTantanganLiveness.kedipMata:
        return 'Tahan wajah stabil, lalu kedipkan kedua mata.';
      case JenisTantanganLiveness.bukaMulut:
        return 'Buka mulut perlahan tanpa menutupinya.';
      case JenisTantanganLiveness.senyum:
        return 'Tersenyumlah dengan wajar.';
    }
  }
}

class HasilLiveness {
  const HasilLiveness({
    required this.jalurVideo,
    required this.tantangan,
    required this.diambilPada,
  });

  final String jalurVideo;
  final List<TantanganLiveness> tantangan;
  final DateTime diambilPada;
}
