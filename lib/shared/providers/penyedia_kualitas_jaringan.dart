import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/layanan_kualitas_jaringan.dart';
import '../../core/network/model_kualitas_jaringan.dart';

final layananKualitasJaringanProvider =
    Provider<LayananKualitasJaringan>((ref) {
  final layanan = LayananKualitasJaringan.instance;
  layanan.mulai();
  ref.onDispose(() {
    layanan.hentikan();
  });
  return layanan;
});

final aliranKualitasJaringanProvider =
    StreamProvider<HasilKualitasJaringan>((ref) {
  final layanan = ref.watch(layananKualitasJaringanProvider);
  return layanan.aliran;
});

final kualitasJaringanProvider = Provider<HasilKualitasJaringan>((ref) {
  final aliran = ref.watch(aliranKualitasJaringanProvider);
  return aliran.maybeWhen(
    data: (h) => h,
    orElse: () =>
        ref.read(layananKualitasJaringanProvider).terakhir,
  );
});
