import 'package:flutter_test/flutter_test.dart';
import 'package:bakudapa_mobile/core/security/penyedia_kunci_blob.dart';

void main() {
  test('heksKeBita mengonversi 64 char ke 32 byte', () {
    final b = heksKeBita('00ff10${'0' * 58}');
    expect(b, isNotNull);
    expect(b!.length, 32);
    expect(b[0], 0x00);
    expect(b[1], 0xff);
    expect(b[2], 0x10);
  });

  test('heksKeBita panjang ganjil/invalid => null', () {
    expect(heksKeBita('abc'), isNull);
    expect(heksKeBita('zz' * 32), isNull);
  });

  test('KunciBlobTetap mengembalikan kunci sama', () async {
    final k = List<int>.generate(32, (i) => i);
    final p = KunciBlobTetap(k);
    expect(await p.kunci(), k);
  });

  test('KunciBlobTetap(null) => null', () async {
    expect(await KunciBlobTetap(null).kunci(), isNull);
  });
}
