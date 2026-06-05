class Penyamaran {
  const Penyamaran._();

  static String nik(String nilai) {
    final s = nilai.replaceAll(RegExp(r'\s'), '');
    if (s.length < 8) return '*' * s.length;
    return '${s.substring(0, 4)}${'*' * (s.length - 6)}${s.substring(s.length - 2)}';
  }

  static String noKk(String nilai) => nik(nilai);

  static String noHp(String nilai) {
    final s = nilai.replaceAll(RegExp(r'\s'), '');
    if (s.length < 6) return '*' * s.length;
    return '${s.substring(0, 4)}${'*' * (s.length - 7)}${s.substring(s.length - 3)}';
  }

  static String surel(String nilai) {
    final at = nilai.indexOf('@');
    if (at <= 2) return nilai;
    final nama = nilai.substring(0, at);
    final domain = nilai.substring(at);
    return '${nama.substring(0, 2)}${'*' * (nama.length - 2)}$domain';
  }
}
