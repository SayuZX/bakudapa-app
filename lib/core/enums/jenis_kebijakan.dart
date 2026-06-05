enum JenisKebijakan {
  privasi('privasi', 'Kebijakan Privasi'),
  layanan('layanan', 'Kebijakan Layanan'),
  syaratKetentuan('syarat_ketentuan', 'Syarat & Ketentuan'),
  penafian('penafian', 'Penafian'),
  biometrik('biometrik', 'Persetujuan Biometrik'),
  kebenaranData('kebenaran_data', 'Pernyataan Kebenaran Data');

  const JenisKebijakan(this.value, this.labelId);
  final String value;
  final String labelId;

  String get pathSegment => value.replaceAll('_', '-');

  static JenisKebijakan fromString(String? raw) {
    final normalized = raw?.replaceAll('-', '_');
    return values.firstWhere(
      (e) => e.value == normalized,
      orElse: () => privasi,
    );
  }
}
