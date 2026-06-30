import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class SampulBlob {
  SampulBlob._();

  static const String prefiks = 'v1:';
  static const int _panjangNonce = 12;
  static const int _panjangMac = 32;

  static final Random _acak = Random.secure();

  static bool apakahTersampul(String nilai) => nilai.startsWith(prefiks);

  static String enkrip(String teksBiasa, List<int> kunci, {List<int>? nonce}) {
    final n = nonce ?? List<int>.generate(_panjangNonce, (_) => _acak.nextInt(256));
    final teks = utf8.encode(teksBiasa);
    final ks = _aliranKunci(kunci, n, teks.length);
    final sandi = Uint8List(teks.length);
    for (var i = 0; i < teks.length; i++) {
      sandi[i] = teks[i] ^ ks[i];
    }
    final mac = _mac(kunci, n, sandi);
    final muatan = <int>[...n, ...sandi, ...mac];
    return prefiks + base64.encode(muatan);
  }

  static String? dekrip(String sampul, List<int> kunci) {
    if (!apakahTersampul(sampul)) return null;
    List<int> mentah;
    try {
      mentah = base64.decode(sampul.substring(prefiks.length));
    } catch (_) {
      return null;
    }
    if (mentah.length < _panjangNonce + _panjangMac) return null;
    final n = mentah.sublist(0, _panjangNonce);
    final sandi = mentah.sublist(_panjangNonce, mentah.length - _panjangMac);
    final mac = mentah.sublist(mentah.length - _panjangMac);
    final macHarap = _mac(kunci, n, sandi);
    if (!_setaraWaktuTetap(mac, macHarap)) return null;
    final ks = _aliranKunci(kunci, n, sandi.length);
    final teks = Uint8List(sandi.length);
    for (var i = 0; i < sandi.length; i++) {
      teks[i] = sandi[i] ^ ks[i];
    }
    try {
      return utf8.decode(teks);
    } catch (_) {
      return null;
    }
  }

  static List<int> _aliranKunci(List<int> kunci, List<int> nonce, int panjang) {
    final hmac = Hmac(sha256, kunci);
    final keluar = <int>[];
    var penghitung = 0;
    while (keluar.length < panjang) {
      final blokInput = <int>[
        ...nonce,
        (penghitung >> 24) & 0xFF,
        (penghitung >> 16) & 0xFF,
        (penghitung >> 8) & 0xFF,
        penghitung & 0xFF,
      ];
      keluar.addAll(hmac.convert(blokInput).bytes);
      penghitung++;
    }
    return keluar.sublist(0, panjang);
  }

  static List<int> _mac(List<int> kunci, List<int> nonce, List<int> sandi) {
    final hmac = Hmac(sha256, kunci);
    return hmac.convert(<int>[...nonce, ...sandi]).bytes;
  }

  static bool _setaraWaktuTetap(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var beda = 0;
    for (var i = 0; i < a.length; i++) {
      beda |= a[i] ^ b[i];
    }
    return beda == 0;
  }
}
