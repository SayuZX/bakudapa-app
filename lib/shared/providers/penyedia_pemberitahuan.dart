import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/notifications/data/repositori_pemberitahuan.dart';
import '../models/pemberitahuan.dart';
import 'penyedia_otentikasi.dart';
import 'penyedia_repositori.dart';

class KondisiPemberitahuan {
  const KondisiPemberitahuan({
    this.daftar = const [],
    this.memuat = false,
    this.memuatLagi = false,
    this.galat,
    this.halaman = 1,
    this.totalHalaman = 1,
    this.filterDibaca,
    this.filterKategori,
  });

  final List<Pemberitahuan> daftar;
  final bool memuat;
  final bool memuatLagi;
  final Object? galat;
  final int halaman;
  final int totalHalaman;
  final bool? filterDibaca;
  final KategoriPemberitahuan? filterKategori;

  bool get bisaLanjut => halaman < totalHalaman;
  bool get kosong => daftar.isEmpty;

  KondisiPemberitahuan salin({
    List<Pemberitahuan>? daftar,
    bool? memuat,
    bool? memuatLagi,
    Object? galat,
    bool hapusGalat = false,
    int? halaman,
    int? totalHalaman,
  }) {
    return KondisiPemberitahuan(
      daftar: daftar ?? this.daftar,
      memuat: memuat ?? this.memuat,
      memuatLagi: memuatLagi ?? this.memuatLagi,
      galat: hapusGalat ? null : (galat ?? this.galat),
      halaman: halaman ?? this.halaman,
      totalHalaman: totalHalaman ?? this.totalHalaman,
      filterDibaca: filterDibaca,
      filterKategori: filterKategori,
    );
  }
}

class PengaturPemberitahuan extends StateNotifier<KondisiPemberitahuan> {
  PengaturPemberitahuan(this._ref) : super(const KondisiPemberitahuan()) {
    if (_masuk) muat();
    _langgan = _ref.listen<KondisiOtentikasi>(penyediaOtentikasi, (
      sebelum,
      sesudah,
    ) {
      final masukBaru =
          sebelum?.status != StatusOtentikasi.masuk &&
          sesudah.status == StatusOtentikasi.masuk;
      final keluar =
          sebelum?.status == StatusOtentikasi.masuk &&
          sesudah.status != StatusOtentikasi.masuk;
      if (masukBaru) {
        muat();
      } else if (keluar) {
        state = const KondisiPemberitahuan();
      }
    });
  }

  final Ref _ref;
  ProviderSubscription<KondisiOtentikasi>? _langgan;
  bool _sibuk = false;

  static const int _ukuran = 20;

  RepositoriPemberitahuan get _repo =>
      _ref.read(penyediaRepositoriPemberitahuan);

  bool get _masuk =>
      _ref.read(penyediaOtentikasi).status == StatusOtentikasi.masuk;

  String? get _kategoriParam {
    final k = state.filterKategori;
    if (k == null || k == KategoriPemberitahuan.takDikenal) return null;
    return k.name;
  }

  Future<void> muat() async {
    if (!_masuk || _sibuk) return;
    _sibuk = true;
    state = state.salin(memuat: true, hapusGalat: true);
    try {
      final hasil = await _repo.daftar(
        halaman: 1,
        ukuran: _ukuran,
        dibaca: state.filterDibaca,
        kategori: _kategoriParam,
      );
      if (!mounted) return;
      state = state.salin(
        daftar: hasil.daftar,
        memuat: false,
        halaman: hasil.halaman,
        totalHalaman: hasil.totalHalaman,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.salin(memuat: false, galat: e);
    } finally {
      _sibuk = false;
    }
  }

  Future<void> segarkan() => muat();

  Future<void> muatBerikutnya() async {
    if (!_masuk || _sibuk || state.memuat || !state.bisaLanjut) return;
    _sibuk = true;
    state = state.salin(memuatLagi: true);
    try {
      final hasil = await _repo.daftar(
        halaman: state.halaman + 1,
        ukuran: _ukuran,
        dibaca: state.filterDibaca,
        kategori: _kategoriParam,
      );
      if (!mounted) return;
      state = state.salin(
        daftar: [...state.daftar, ...hasil.daftar],
        memuatLagi: false,
        halaman: hasil.halaman,
        totalHalaman: hasil.totalHalaman,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.salin(memuatLagi: false);
    } finally {
      _sibuk = false;
    }
  }

  Future<void> pilihDibaca(bool? dibaca) async {
    state = KondisiPemberitahuan(
      filterDibaca: dibaca,
      filterKategori: state.filterKategori,
    );
    await muat();
  }

  Future<void> pilihKategori(KategoriPemberitahuan? kategori) async {
    state = KondisiPemberitahuan(
      filterDibaca: state.filterDibaca,
      filterKategori: kategori,
    );
    await muat();
  }

  Future<void> tandaiDibaca(String id) async {
    final adaBelum = state.daftar.any((n) => n.id == id && !n.dibaca);
    if (adaBelum) {
      state = state.salin(
        daftar: [
          for (final n in state.daftar) n.id == id ? n.tandaiDibaca() : n,
        ],
      );
      _ref.read(penyediaJumlahBelumDibaca.notifier).kurangi();
    }
    try {
      await _repo.tandaiDibaca(id);
    } catch (_) {}
  }

  Future<void> tandaiSemuaDibaca() async {
    if (state.daftar.isEmpty) return;
    state = state.salin(
      daftar: [for (final n in state.daftar) n.tandaiDibaca()],
    );
    _ref.read(penyediaJumlahBelumDibaca.notifier).nolkan();
    try {
      await _repo.tandaiSemuaDibaca();
    } catch (_) {}
    _ref.read(penyediaJumlahBelumDibaca.notifier).segarkan();
  }

  @override
  void dispose() {
    _langgan?.close();
    _langgan = null;
    super.dispose();
  }
}

final penyediaPemberitahuan =
    StateNotifierProvider<PengaturPemberitahuan, KondisiPemberitahuan>((ref) {
      return PengaturPemberitahuan(ref);
    });

class PengaturJumlahBelumDibaca extends StateNotifier<int> {
  PengaturJumlahBelumDibaca(this._ref) : super(0) {
    if (_masuk) segarkan();
    _langgan = _ref.listen<KondisiOtentikasi>(penyediaOtentikasi, (
      sebelum,
      sesudah,
    ) {
      if (sesudah.status == StatusOtentikasi.masuk) {
        segarkan();
      } else {
        state = 0;
      }
    });
  }

  final Ref _ref;
  ProviderSubscription<KondisiOtentikasi>? _langgan;
  bool _sibuk = false;

  bool get _masuk =>
      _ref.read(penyediaOtentikasi).status == StatusOtentikasi.masuk;

  Future<void> segarkan() async {
    if (!_masuk || _sibuk) return;
    _sibuk = true;
    try {
      final jumlah = await _ref
          .read(penyediaRepositoriPemberitahuan)
          .jumlahBelumDibaca();
      if (!mounted) return;
      state = jumlah;
    } catch (_) {
    } finally {
      _sibuk = false;
    }
  }

  void kurangi([int jumlah = 1]) {
    final nilai = state - jumlah;
    state = nilai < 0 ? 0 : nilai;
  }

  void nolkan() => state = 0;

  @override
  void dispose() {
    _langgan?.close();
    _langgan = null;
    super.dispose();
  }
}

final penyediaJumlahBelumDibaca =
    StateNotifierProvider<PengaturJumlahBelumDibaca, int>((ref) {
      return PengaturJumlahBelumDibaca(ref);
    });
