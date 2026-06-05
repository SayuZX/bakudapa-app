import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/applications/domain/repositori_permohonan.dart';
import '../models/halaman_data.dart';
import '../models/permohonan.dart';
import 'penyedia_repositori.dart';

class KueriRiwayat {
  const KueriRiwayat({this.kueri = ''});
  final String kueri;
}

class PengaturRiwayat extends StateNotifier<AsyncValue<HalamanData<Permohonan>>> {
  PengaturRiwayat(this._repo) : super(const AsyncValue.loading()) {
    muatHalamanAwal();
  }

  final RepositoriPermohonan _repo;
  String _kueri = '';
  int _halamanSekarang = 1;
  bool _sedangMemuatBerikut = false;

  String get kueri => _kueri;

  Future<void> muatHalamanAwal() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repo.mintaRiwayat(halaman: 1, kueriPencarian: _kueri);
      _halamanSekarang = data.halaman;
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> muatBerikut() async {
    final saatIni = state.valueOrNull;
    if (saatIni == null || !saatIni.adaHalamanBerikut || _sedangMemuatBerikut) return;
    _sedangMemuatBerikut = true;
    try {
      final halamanBerikut = _halamanSekarang + 1;
      final data = await _repo.mintaRiwayat(halaman: halamanBerikut, kueriPencarian: _kueri);
      _halamanSekarang = data.halaman;
      state = AsyncValue.data(saatIni.gabung(data));
    } catch (_) {} finally {
      _sedangMemuatBerikut = false;
    }
  }

  Future<void> cari(String kueri) async {
    _kueri = kueri;
    await muatHalamanAwal();
  }

  Future<void> segarkan() => muatHalamanAwal();
}

final penyediaPengaturRiwayat = StateNotifierProvider.autoDispose<PengaturRiwayat,
    AsyncValue<HalamanData<Permohonan>>>((ref) {
  return PengaturRiwayat(ref.watch(penyediaRepositoriPermohonan));
});

final penyediaRingkasanStatus = FutureProvider.autoDispose((ref) async {
  return ref.watch(penyediaRepositoriPermohonan).mintaRingkasan();
});

final penyediaDetailPermohonan =
    FutureProvider.autoDispose.family<Permohonan, String>((ref, id) async {
  return ref.watch(penyediaRepositoriPermohonan).mintaDetail(id);
});
