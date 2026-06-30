import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:bakudapa_mobile/core/security/sampul_blob.dart';

void main() {
  final kunci = List<int>.generate(32, (i) => i + 1);
  final nonce = List<int>.generate(12, (i) => 100 + i);

  test('round-trip mengembalikan teks asli', () {
    final sampul = SampulBlob.enkrip('token-rahasia-123', kunci, nonce: nonce);
    expect(SampulBlob.apakahTersampul(sampul), isTrue);
    expect(sampul.startsWith('v1:'), isTrue);
    expect(SampulBlob.dekrip(sampul, kunci), 'token-rahasia-123');
  });

  test('ciphertext bukan plaintext', () {
    final sampul = SampulBlob.enkrip('AAAAAAAAAA', kunci, nonce: nonce);
    expect(sampul.contains('AAAAAAAAAA'), isFalse);
  });

  test('kunci salah => dekrip null (MAC gagal)', () {
    final sampul = SampulBlob.enkrip('token', kunci, nonce: nonce);
    final kunciLain = List<int>.generate(32, (i) => i + 9);
    expect(SampulBlob.dekrip(sampul, kunciLain), isNull);
  });

  test('ciphertext diutak-atik => dekrip null', () {
    final sampul = SampulBlob.enkrip('token', kunci, nonce: nonce);
    final mentah = base64.decode(sampul.substring(3));
    mentah[13] ^= 0xFF;
    final rusak = 'v1:${base64.encode(mentah)}';
    expect(SampulBlob.dekrip(rusak, kunci), isNull);
  });

  test('nilai non-sampul => apakahTersampul false & dekrip null', () {
    expect(SampulBlob.apakahTersampul('plaintext-lama'), isFalse);
    expect(SampulBlob.dekrip('plaintext-lama', kunci), isNull);
  });

  test('nonce acak => dua enkripsi berbeda', () {
    final a = SampulBlob.enkrip('sama', kunci);
    final b = SampulBlob.enkrip('sama', kunci);
    expect(a == b, isFalse);
    expect(SampulBlob.dekrip(a, kunci), 'sama');
    expect(SampulBlob.dekrip(b, kunci), 'sama');
  });
}
