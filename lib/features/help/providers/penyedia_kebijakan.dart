import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/penyedia_repositori.dart';
import '../data/repositori_kebijakan.dart';

final penyediaKontenKebijakan = FutureProvider.autoDispose
    .family<KontenKebijakan, JenisKebijakan>((ref, jenis) {
  return ref.watch(penyediaRepositoriKebijakan).ambil(jenis);
});
