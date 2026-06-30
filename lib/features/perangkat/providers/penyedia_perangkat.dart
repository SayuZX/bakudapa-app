import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/perangkat_aktif.dart';
import '../../../shared/providers/penyedia_repositori.dart';

final penyediaDaftarPerangkat =
    FutureProvider.autoDispose<List<PerangkatAktif>>((ref) {
      return ref.watch(penyediaRepositoriPerangkat).mintaDaftar();
    });

final penyediaRiwayatPerangkat =
    FutureProvider.autoDispose<List<PerangkatAktif>>((ref) {
      return ref.watch(penyediaRepositoriPerangkat).mintaRiwayat();
    });
