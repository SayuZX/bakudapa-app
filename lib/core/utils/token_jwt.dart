import 'dart:convert';

class TokenJwt {
  const TokenJwt._();

  static DateTime? bacaKedaluwarsa(String token) {
    final muatan = bacaMuatan(token);
    final exp = muatan?['exp'];
    if (exp is int) {
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    }
    if (exp is String) {
      final angka = int.tryParse(exp);
      if (angka != null) {
        return DateTime.fromMillisecondsSinceEpoch(angka * 1000);
      }
    }
    return null;
  }

  static Map<String, dynamic>? bacaMuatan(String token) {
    final bagian = token.split('.');
    if (bagian.length != 3) return null;
    try {
      final normal = base64Url.normalize(bagian[1]);
      final teks = utf8.decode(base64Url.decode(normal));
      final json = jsonDecode(teks);
      return json is Map<String, dynamic> ? json : null;
    } catch (_) {
      return null;
    }
  }
}
