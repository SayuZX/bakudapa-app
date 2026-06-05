import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/ui_behavior.dart';
import '../models/pemberitahuan.dart';
import 'penyedia_otentikasi.dart';
import 'penyedia_repositori.dart';

class PengaturPemberitahuan extends StateNotifier<AsyncValue<List<Pemberitahuan>>> {
  PengaturPemberitahuan(this._ref) : super(const AsyncValue.loading()) {
    final status = _ref.read(penyediaOtentikasi).status;
    if (status == StatusOtentikasi.masuk) {
      muat();
      _mulaiPoling();
    }
    _langgan = _ref.listen<KondisiOtentikasi>(penyediaOtentikasi, (sebelum, sesudah) {
      if (sebelum?.status != StatusOtentikasi.masuk &&
          sesudah.status == StatusOtentikasi.masuk) {
        muat();
        _mulaiPoling();
      } else if (sebelum?.status == StatusOtentikasi.masuk &&
          sesudah.status != StatusOtentikasi.masuk) {
        _hentikanPoling();
        state = const AsyncValue.data([]);
      }
    });
  }

  final Ref _ref;
  Timer? _poling;
  ProviderSubscription<KondisiOtentikasi>? _langgan;

  void _mulaiPoling() {
    _poling?.cancel();
    _poling = Timer.periodic(
      UiBehavior.intervalPolingNotifikasi,
      (_) => muatDiam(),
    );
  }

  void _hentikanPoling() {
    _poling?.cancel();
    _poling = null;
  }

  Future<void> muat() async {
    if (_ref.read(penyediaOtentikasi).status != StatusOtentikasi.masuk) return;
    state = const AsyncValue.loading();
    try {
      final data = await _ref.read(penyediaRepositoriPemberitahuan).daftar();
      if (!mounted) return;
      state = AsyncValue.data(data);
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> muatDiam() async {
    if (_ref.read(penyediaOtentikasi).status != StatusOtentikasi.masuk) return;
    try {
      final data = await _ref.read(penyediaRepositoriPemberitahuan).daftar();
      if (!mounted) return;
      state = AsyncValue.data(data);
    } catch (_) {}
  }

  Future<void> tandaiDibaca(String id) async {
    final saatIni = state.valueOrNull;
    if (saatIni == null) return;
    state = AsyncValue.data([
      for (final n in saatIni) n.id == id ? n.tandaiDibaca() : n,
    ]);
    try {
      await _ref.read(penyediaRepositoriPemberitahuan).tandaiDibaca(id);
    } catch (_) {}
  }

  Future<void> tandaiSemuaDibaca() async {
    final saatIni = state.valueOrNull;
    if (saatIni == null || saatIni.isEmpty) return;
    state = AsyncValue.data([for (final n in saatIni) n.tandaiDibaca()]);
    try {
      await _ref.read(penyediaRepositoriPemberitahuan).tandaiSemuaDibaca();
    } catch (_) {}
  }

  @override
  void dispose() {
    _hentikanPoling();
    _langgan?.close();
    _langgan = null;
    super.dispose();
  }
}

final penyediaPemberitahuan = StateNotifierProvider<PengaturPemberitahuan,
    AsyncValue<List<Pemberitahuan>>>((ref) {
  return PengaturPemberitahuan(ref);
});

final penyediaJumlahBelumDibaca = Provider<int>((ref) {
  final daftar = ref.watch(penyediaPemberitahuan).valueOrNull;
  if (daftar == null) return 0;
  return daftar.where((n) => !n.dibaca).length;
});
