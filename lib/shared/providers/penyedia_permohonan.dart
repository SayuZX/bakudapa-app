import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/applications/domain/repositori_permohonan.dart';
import '../models/permohonan.dart';
import '../models/status_permohonan.dart';
import 'penyedia_repositori.dart';

class PengaturRiwayat extends StateNotifier<AsyncValue<List<Permohonan>>> {
  PengaturRiwayat(this._repo) : super(const AsyncValue.loading()) {
    muat();
  }

  final RepositoriPermohonan _repo;
  bool _sedangMemuat = false;

  Future<void> muat() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repo.mintaGabunganTerbaru(ukuran: 20);
      if (!mounted) return;
      state = AsyncValue.data(data);
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> segarkan() async {
    if (_sedangMemuat) return;
    _sedangMemuat = true;
    try {
      final data = await _repo.mintaGabunganTerbaru(ukuran: 20);
      if (!mounted) return;
      state = AsyncValue.data(data);
    } catch (e, st) {
      if (!mounted) return;
      if (state.valueOrNull == null) {
        state = AsyncValue.error(e, st);
      }
    } finally {
      _sedangMemuat = false;
    }
  }
}

final penyediaPengaturRiwayat = StateNotifierProvider.autoDispose<PengaturRiwayat,
    AsyncValue<List<Permohonan>>>((ref) {
  return PengaturRiwayat(ref.watch(penyediaRepositoriPermohonan));
});

final penyediaRingkasanStatus = Provider.autoDispose<RingkasanStatus?>((ref) {
  final daftar = ref.watch(penyediaPengaturRiwayat).valueOrNull;
  if (daftar == null) return null;
  var menunggu = 0;
  var berjalan = 0;
  var selesai = 0;
  var perluTindakan = 0;
  for (final p in daftar) {
    switch (p.status) {
      case StatusPermohonan.menunggu:
      case StatusPermohonan.tertunda:
        menunggu++;
      case StatusPermohonan.diverifikasi:
      case StatusPermohonan.diproses:
      case StatusPermohonan.menungguSiak:
        berjalan++;
      case StatusPermohonan.selesai:
        selesai++;
      case StatusPermohonan.perluPerbaikan:
        perluTindakan++;
      case StatusPermohonan.ditolak:
      case StatusPermohonan.dibatalkan:
        break;
    }
  }
  return RingkasanStatus(
    menunggu: menunggu,
    berjalan: berjalan,
    selesai: selesai,
    perluTindakan: perluTindakan,
  );
});

final penyediaDetailPermohonan =
    FutureProvider.autoDispose.family<Permohonan, String>((ref, id) async {
  return ref.watch(penyediaRepositoriPermohonan).mintaDetail(id);
});

final penyediaDokumenHasil =
    FutureProvider.autoDispose.family<List<DokumenHasil>, String>((ref, id) async {
  return ref.watch(penyediaRepositoriPermohonan).mintaDokumenHasil(id);
});
