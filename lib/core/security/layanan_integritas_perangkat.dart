import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:safe_device/safe_device.dart';

class HasilIntegritas {
  const HasilIntegritas({
    required this.aman,
    required this.terootJailbreak,
    required this.modePengembang,
    required this.lokasiPalsu,
    required this.emulator,
    this.galat,
  });

  final bool aman;
  final bool terootJailbreak;
  final bool modePengembang;
  final bool lokasiPalsu;
  final bool emulator;
  final String? galat;

  String get ringkasan {
    final tanda = <String>[];
    if (terootJailbreak) tanda.add(Platform.isIOS ? 'jailbreak' : 'root');
    if (emulator) tanda.add('emulator');
    if (lokasiPalsu) tanda.add('mock-location');
    return tanda.join(', ');
  }
}

class LayananIntegritasPerangkat {
  LayananIntegritasPerangkat._();
  static final LayananIntegritasPerangkat instance = LayananIntegritasPerangkat._();

  Future<HasilIntegritas> periksa() async {
    try {
      final futures = await Future.wait<bool>([
        SafeDevice.isJailBroken,
        SafeDevice.isMockLocation,
        SafeDevice.isRealDevice,
        SafeDevice.isOnExternalStorage,
        SafeDevice.isDevelopmentModeEnable,
      ]);
      final root = futures[0];
      final mock = futures[1];
      final asli = futures[2];
      final modeDev = futures[4];
      final emu = !asli;

      final amanProduksi = !root && !emu;
      final aman = kDebugMode ? !root : amanProduksi;

      return HasilIntegritas(
        aman: aman,
        terootJailbreak: root,
        modePengembang: modeDev,
        lokasiPalsu: mock,
        emulator: emu,
      );
    } catch (e) {
      return HasilIntegritas(
        aman: true,
        terootJailbreak: false,
        modePengembang: false,
        lokasiPalsu: false,
        emulator: false,
        galat: e.toString(),
      );
    }
  }
}
