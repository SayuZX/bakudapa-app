import '../localization/teks.dart';

class Validasi {
  const Validasi._();

  static Teks? _bahasa;

  static void pasang(Teks teks) {
    _bahasa = teks;
  }

  static Teks _t() {
    final t = _bahasa;
    if (t != null) return t;
    throw StateError(
      'Validasi.pasang(t) belum dipanggil. Pastikan ProviderObserver atau widget root memasang Teks aktif sebelum menggunakan Validasi.',
    );
  }

  static String? wajib(String? nilai, {String? label}) {
    if (nilai == null || nilai.trim().isEmpty) {
      final t = _t();
      return t.wajibDiisi(label ?? t.kolomIniLabel);
    }
    return null;
  }

  static String? nik(String? nilai) {
    final t = _t();
    if (nilai == null || nilai.isEmpty) return t.wajibDiisi(t.nikLabel);
    final digit = nilai.replaceAll(RegExp(r'\s'), '');
    if (digit.length != 16) return t.nikHarus16Digit;
    if (!RegExp(r'^\d{16}$').hasMatch(digit)) return t.nikHanyaAngka;
    return null;
  }

  static String? noKk(String? nilai) {
    final t = _t();
    if (nilai == null || nilai.isEmpty) return t.wajibDiisi(t.noKkLabel);
    final digit = nilai.replaceAll(RegExp(r'\s'), '');
    if (digit.length != 16) return t.noKkHarus16Digit;
    if (!RegExp(r'^\d{16}$').hasMatch(digit)) return t.noKkHanyaAngka;
    return null;
  }

  static String? surel(String? nilai) {
    final t = _t();
    if (nilai == null || nilai.isEmpty) return t.wajibDiisi(t.emailLabel);
    final regex = RegExp(r'^[\w.+\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!regex.hasMatch(nilai.trim())) return t.formatEmailTidakValid;
    return null;
  }

  static String? noHp(String? nilai) {
    final t = _t();
    if (nilai == null || nilai.isEmpty) return t.wajibDiisi(t.nomorHpLabel);
    final digit = nilai.replaceAll(RegExp(r'\D'), '');
    if (digit.length < 9 || digit.length > 14) {
      return t.noHpTidakValid;
    }
    return null;
  }

  static String? noHpTanpaPrefiks(String? nilai) {
    final t = _t();
    if (nilai == null || nilai.trim().isEmpty) {
      return t.wajibDiisi(t.nomorHpLabel);
    }
    final digit = nilai
        .replaceAll(RegExp(r'\D'), '')
        .replaceFirst(RegExp(r'^0+'), '');
    if (digit.isEmpty) return t.wajibDiisi(t.nomorHpLabel);
    if (digit.startsWith('0')) return t.hapusAngka0DiAwal;
    if (digit.length < 8 || digit.length > 13) {
      return t.noHpHarus9Digit;
    }
    if (!digit.startsWith(RegExp(r'[1-9]'))) {
      return t.noHpTidakValid;
    }
    return null;
  }

  static String? kataSandi(String? nilai) {
    final t = _t();
    if (nilai == null || nilai.isEmpty) return t.wajibDiisi(t.kataSandiLabel);
    if (nilai.length < 8) return t.kataSandiMin8;
    if (!RegExp(r'[A-Z]').hasMatch(nilai)) return t.sertakanHurufBesar;
    if (!RegExp(r'[0-9]').hasMatch(nilai)) return t.sertakanAngka;
    return null;
  }

  static String? username(String? nilai) {
    final t = _t();
    final v = (nilai ?? '').trim();
    if (v.isEmpty) return t.wajibDiisi(t.usernameLabel);
    if (v.length < 4 || v.length > 20) return t.usernamePanjang;
    if (!RegExp(r'^[a-z0-9][a-z0-9._]*$').hasMatch(v)) return t.usernameFormat;
    if (!RegExp(r'[a-z]').hasMatch(v)) return t.usernameWajibHuruf;
    return null;
  }

  static String? konfirmasiKataSandi(String? nilai, String asli) {
    final t = _t();
    if (nilai == null || nilai.isEmpty) {
      return t.wajibDiisi(t.konfirmasiKataSandiLabel);
    }
    if (nilai != asli) return t.kataSandiTidakCocok;
    return null;
  }

  static String? identitasAtauSurel(String? nilai) {
    final t = _t();
    if (nilai == null || nilai.trim().isEmpty) {
      return t.wajibDiisi(t.nikAtauEmailLabel);
    }
    final bersih = nilai.trim();
    if (RegExp(r'^\d+$').hasMatch(bersih)) return nik(bersih);
    if (bersih.contains('@')) return surel(bersih);
    if (bersih.length < 3) return t.identitasTidakValid;
    return null;
  }

  static String? panjangMinimal(String? nilai, int minimal, {String? label}) {
    final t = _t();
    if (nilai == null || nilai.length < minimal) {
      return t.minimalKarakter(label ?? t.kolomIniLabel, minimal);
    }
    return null;
  }
}
