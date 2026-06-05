enum JenisKelamin {
  lakiLaki('L', 'Laki-laki', 'Male'),
  perempuan('P', 'Perempuan', 'Female');

  const JenisKelamin(this.value, this.labelId, this.labelEn);
  final String value;
  final String labelId;
  final String labelEn;

  static JenisKelamin? fromString(String? raw) =>
      switch (raw) { 'L' => lakiLaki, 'P' => perempuan, _ => null };
}
