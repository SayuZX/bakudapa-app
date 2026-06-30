import 'dart:math';

import 'model_tantangan_liveness.dart';

class LayananLiveness {
  LayananLiveness._();
  static final LayananLiveness instance = LayananLiveness._();

  static const List<TantanganLiveness> _pool = [
    TantanganLiveness(
      jenis: JenisTantanganLiveness.kedipMata,
      instruksi: 'Kedipkan mata Anda dua kali',
    ),
    TantanganLiveness(
      jenis: JenisTantanganLiveness.bukaMulut,
      instruksi: 'Buka mulut Anda perlahan',
    ),
    TantanganLiveness(
      jenis: JenisTantanganLiveness.senyum,
      instruksi: 'Tersenyumlah dengan wajar',
    ),
    TantanganLiveness(
      jenis: JenisTantanganLiveness.hadapKiri,
      instruksi: 'Hadapkan wajah sedikit ke kiri',
    ),
    TantanganLiveness(
      jenis: JenisTantanganLiveness.hadapKanan,
      instruksi: 'Hadapkan wajah sedikit ke kanan',
    ),
    TantanganLiveness(
      jenis: JenisTantanganLiveness.anggukKepala,
      instruksi: 'Anggukkan kepala perlahan',
    ),
  ];

  List<TantanganLiveness> acakTantangan({int jumlah = 1, int? benih}) {
    final rng = benih != null ? Random(benih) : Random.secure();
    final salinan = [..._pool]..shuffle(rng);
    return salinan.take(jumlah.clamp(1, _pool.length)).toList();
  }

  TantanganLiveness? dariKode(String? kode) {
    if (kode == null || kode.isEmpty) return null;
    final dicari = kode.toUpperCase();
    for (final t in _pool) {
      if (t.kode == dicari) return t;
    }
    return null;
  }
}
