enum StatusPermohonan {
  menunggu('menunggu', 'Menunggu'),
  diverifikasi('diverifikasi', 'Diverifikasi'),
  diproses('diproses', 'Diproses'),
  tertunda('tertunda', 'Tertunda'),
  ditolak('ditolak', 'Ditolak'),
  selesai('selesai', 'Selesai');

  const StatusPermohonan(this.kode, this.label);

  final String kode;
  final String label;

  static StatusPermohonan dariKode(String? kode) {
    if (kode == null) return StatusPermohonan.menunggu;
    return StatusPermohonan.values.firstWhere(
      (e) => e.kode == kode.toLowerCase(),
      orElse: () => StatusPermohonan.menunggu,
    );
  }

  int get langkahLini {
    switch (this) {
      case StatusPermohonan.menunggu:
        return 0;
      case StatusPermohonan.diverifikasi:
        return 1;
      case StatusPermohonan.diproses:
        return 2;
      case StatusPermohonan.selesai:
        return 3;
      case StatusPermohonan.tertunda:
      case StatusPermohonan.ditolak:
        return -1;
    }
  }

  bool get adalahFinal =>
      this == StatusPermohonan.selesai || this == StatusPermohonan.ditolak;
}
