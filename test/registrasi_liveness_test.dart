import 'package:flutter_test/flutter_test.dart';

import 'package:bakudapa_mobile/core/enums/langkah_registrasi.dart';
import 'package:bakudapa_mobile/core/liveness/layanan_liveness.dart';

void main() {
  group('LangkahRegistrasi tanpa suara & sidik jari', () {
    test('tidak ada langkah suara/sidik jari & total 5', () {
      final nilai = LangkahRegistrasi.values.map((e) => e.value).toList();
      expect(nilai.contains('suara'), isFalse);
      expect(nilai.contains('sidik_jari'), isFalse);
      expect(LangkahRegistrasi.total, 5);
    });

    test('urutan setelah liveness langsung kebijakan', () {
      expect(LangkahRegistrasi.liveness.urutan, 4);
      expect(LangkahRegistrasi.kebijakan.urutan, 5);
    });
  });

  group('LayananLiveness satu tantangan acak', () {
    test('acakTantangan default mengembalikan tepat satu', () {
      final hasil = LayananLiveness.instance.acakTantangan();
      expect(hasil.length, 1);
    });

    test('jumlah selalu di-clamp minimal satu', () {
      expect(LayananLiveness.instance.acakTantangan(jumlah: 0).length, 1);
    });

    test('benih sama menghasilkan tantangan sama (deterministik untuk uji)', () {
      final a = LayananLiveness.instance.acakTantangan(benih: 7).single;
      final b = LayananLiveness.instance.acakTantangan(benih: 7).single;
      expect(a.jenis, b.jenis);
    });

    test('dariKode memetakan kode server ke tantangan', () {
      expect(LayananLiveness.instance.dariKode('BLINK')?.kode, 'BLINK');
      expect(LayananLiveness.instance.dariKode('smile')?.kode, 'SMILE');
      expect(LayananLiveness.instance.dariKode('TURN_LEFT')?.kode, 'TURN_LEFT');
    });

    test('dariKode mengembalikan null untuk kode tak dikenal/kosong', () {
      expect(LayananLiveness.instance.dariKode('LOMPAT'), isNull);
      expect(LayananLiveness.instance.dariKode(''), isNull);
      expect(LayananLiveness.instance.dariKode(null), isNull);
    });
  });
}
