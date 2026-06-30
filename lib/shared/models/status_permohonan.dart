enum StatusPermohonan {
  menunggu('menunggu', 'Menunggu'),
  diverifikasi('verified', 'Diverifikasi'),
  diproses('diproses', 'Diproses'),
  menungguSiak('waiting_siak', 'Menunggu SIAK'),
  tertunda('constrained', 'Tertunda'),
  perluPerbaikan('perlu_perbaikan', 'Perlu Perbaikan'),
  ditolak('ditolak', 'Ditolak'),
  selesai('selesai', 'Selesai'),
  dibatalkan('dibatalkan', 'Dibatalkan');

  const StatusPermohonan(this.kode, this.label);

  final String kode;
  final String label;

  static StatusPermohonan dariKode(String? kode) {
    if (kode == null) return StatusPermohonan.menunggu;
    final bersih = kode.toLowerCase().trim();
    for (final status in StatusPermohonan.values) {
      if (status.kode == bersih) return status;
    }
    switch (bersih) {
      case 'pending':
        return StatusPermohonan.tertunda;
      case 'approved':
        return StatusPermohonan.diproses;
      default:
        return StatusPermohonan.menunggu;
    }
  }

  int get langkahLini {
    switch (this) {
      case StatusPermohonan.menunggu:
        return 0;
      case StatusPermohonan.diverifikasi:
        return 1;
      case StatusPermohonan.diproses:
      case StatusPermohonan.menungguSiak:
        return 2;
      case StatusPermohonan.selesai:
        return 3;
      case StatusPermohonan.tertunda:
      case StatusPermohonan.perluPerbaikan:
      case StatusPermohonan.ditolak:
      case StatusPermohonan.dibatalkan:
        return -1;
    }
  }

  bool get adalahFinal =>
      this == StatusPermohonan.selesai ||
      this == StatusPermohonan.ditolak ||
      this == StatusPermohonan.dibatalkan;

  bool get sedangBerjalan =>
      this == StatusPermohonan.diverifikasi ||
      this == StatusPermohonan.diproses ||
      this == StatusPermohonan.menungguSiak;

  bool get bisaDibatalkan =>
      this == StatusPermohonan.menunggu || this == StatusPermohonan.tertunda;
}
