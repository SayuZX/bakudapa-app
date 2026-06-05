class BakudapaValidators {
  BakudapaValidators._();

  static final RegExp nikRegex = RegExp(r'^\d{16}$');
  static final RegExp e164Regex = RegExp(r'^\+?[1-9]\d{8,14}$');
  static final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
  );
  static final RegExp passwordUpper = RegExp(r'[A-Z]');
  static final RegExp passwordDigit = RegExp(r'\d');

  static String? nik(String? value) {
    if (value == null || value.isEmpty) return 'NIK wajib diisi';
    if (!nikRegex.hasMatch(value)) return 'NIK harus 16 digit angka';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email wajib diisi';
    if (!emailRegex.hasMatch(value)) return 'Format email tidak valid';
    return null;
  }

  static String? noHp(String? value) {
    if (value == null || value.isEmpty) return 'Nomor HP wajib diisi';
    final normalized = normalizeNoHp(value);
    if (!e164Regex.hasMatch(normalized)) return 'Format nomor HP tidak valid';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Kata sandi wajib diisi';
    if (value.length < 8) return 'Kata sandi minimal 8 karakter';
    if (!passwordUpper.hasMatch(value)) return 'Kata sandi harus mengandung huruf besar';
    if (!passwordDigit.hasMatch(value)) return 'Kata sandi harus mengandung angka';
    return null;
  }

  static String? usiaMinimum(DateTime? tanggalLahir, {int min = 17}) {
    if (tanggalLahir == null) return 'Tanggal lahir wajib diisi';
    final now = DateTime.now();
    final years = now.year - tanggalLahir.year - (now.month < tanggalLahir.month ||
        (now.month == tanggalLahir.month && now.day < tanggalLahir.day) ? 1 : 0);
    if (years < min) return 'Usia minimal $min tahun';
    return null;
  }

  static String normalizeNoHp(String raw) {
    var v = raw.trim().replaceAll(RegExp(r'[\s-]'), '');
    if (v.startsWith('+')) return v;
    if (v.startsWith('0')) return '+62${v.substring(1)}';
    return '+$v';
  }
}
