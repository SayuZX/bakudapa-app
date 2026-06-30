enum LangkahRegistrasi {
  identitas('identitas', 1, 'Data Identitas'),
  fotoDokumen('foto_dokumen', 2, 'Foto Dokumen'),
  fotoWajah('foto_wajah', 3, 'Foto Wajah'),
  liveness('liveness', 4, 'Liveness'),
  kebijakan('kebijakan', 5, 'Persetujuan Kebijakan'),
  selesai('selesai', 5, 'Selesai');

  const LangkahRegistrasi(this.value, this.urutan, this.labelId);
  final String value;
  final int urutan;
  final String labelId;

  static LangkahRegistrasi fromString(String? raw) =>
      values.firstWhere((e) => e.value == raw, orElse: () => identitas);

  static const int total = 5;
}
