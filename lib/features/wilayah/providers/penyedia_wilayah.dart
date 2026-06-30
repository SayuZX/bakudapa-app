import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/wilayah.dart';
import '../../../shared/providers/penyedia_repositori.dart';

final penyediaKabupaten = FutureProvider.autoDispose<List<Wilayah>>((ref) {
  return ref.watch(penyediaRepositoriWilayah).kabupaten();
});

final penyediaKecamatan = FutureProvider.autoDispose
    .family<List<Wilayah>, String>((ref, kabupatenKode) {
      return ref.watch(penyediaRepositoriWilayah).kecamatan(kabupatenKode);
    });

final penyediaDesa = FutureProvider.autoDispose.family<List<Wilayah>, String>((
  ref,
  kecamatanKode,
) {
  return ref.watch(penyediaRepositoriWilayah).desa(kecamatanKode);
});
