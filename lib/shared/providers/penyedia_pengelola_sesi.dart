import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/pengelola_sesi.dart';
import 'penyedia_otentikasi.dart';

final penyediaPengelolaSesi = Provider<PengelolaSesi>((ref) {
  final pengelola = PengelolaSesi();
  ref.onDispose(pengelola.dispose);
  return pengelola;
});

final pemicuPengelolaSesi = Provider<void>((ref) {
  final pengelola = ref.watch(penyediaPengelolaSesi);
  pengelola.daftarPenanganKedaluwarsa(() {
    ref.read(penyediaOtentikasi.notifier).paksaKeluar();
  });
  ref.listen<KondisiOtentikasi>(
    penyediaOtentikasi,
    (sebelum, sesudah) {
      if (sesudah.status == StatusOtentikasi.masuk) {
        pengelola.mulai();
      } else {
        pengelola.berhenti();
      }
    },
    fireImmediately: true,
  );
});
