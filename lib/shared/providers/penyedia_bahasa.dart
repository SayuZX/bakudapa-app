import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/storage_keys.dart';
import '../../core/network/klien_jaringan.dart';

enum KodeBahasa {
  id('id', 'ID', 'Bahasa Indonesia'),
  en('en', 'US', 'English');

  const KodeBahasa(this.kode, this.negara, this.label);
  final String kode;
  final String negara;
  final String label;

  Locale get locale => Locale(kode, negara);

  static KodeBahasa dariKode(String? kode) {
    if (kode == 'en') return KodeBahasa.en;
    return KodeBahasa.id;
  }
}

class PengaturBahasa extends StateNotifier<KodeBahasa> {
  PengaturBahasa() : super(KodeBahasa.id) {
    _pulihkan();
  }

  Future<void> _pulihkan() async {
    final prefs = await SharedPreferences.getInstance();
    final tersimpan = prefs.getString(StorageKeys.bahasaPilihan);
    state = KodeBahasa.dariKode(tersimpan);
    KlienJaringan.instance.aturBahasa(state.kode);
  }

  Future<void> ubah(KodeBahasa baru) async {
    state = baru;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.bahasaPilihan, baru.kode);
    KlienJaringan.instance.aturBahasa(baru.kode);
    await _sinkronkanKeServer(baru.kode);
  }

  Future<void> _sinkronkanKeServer(String kode) async {
    try {
      await KlienJaringan.instance.dio.put(
        '/profil/bahasa',
        data: {'bahasa': kode},
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
    } catch (_) {}
  }
}

final penyediaBahasa =
    StateNotifierProvider<PengaturBahasa, KodeBahasa>((ref) => PengaturBahasa());
