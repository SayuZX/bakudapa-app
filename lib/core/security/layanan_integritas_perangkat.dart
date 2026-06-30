import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:safe_device/safe_device.dart';

import 'detektor_native.dart';

class HasilIntegritas {
  const HasilIntegritas({
    required this.aman,
    required this.terootJailbreak,
    required this.modePengembang,
    required this.lokasiPalsu,
    required this.emulator,
    this.frida = false,
    this.debugger = false,
    this.tandaTanganTidakValid = false,
    this.galat,
  });

  final bool aman;
  final bool terootJailbreak;
  final bool modePengembang;
  final bool lokasiPalsu;
  final bool emulator;
  final bool frida;
  final bool debugger;
  final bool tandaTanganTidakValid;
  final String? galat;

  String get ringkasan {
    final tanda = <String>[];
    if (terootJailbreak) tanda.add(Platform.isIOS ? 'jailbreak' : 'root');
    if (emulator) tanda.add('emulator');
    if (frida) tanda.add('frida');
    if (debugger) tanda.add('debugger');
    if (tandaTanganTidakValid) tanda.add('repackaging');
    if (lokasiPalsu) tanda.add('mock-location');
    if (galat != null) tanda.add('gagal-cek');
    return tanda.join(', ');
  }
}

class LayananIntegritasPerangkat {
  LayananIntegritasPerangkat._();
  static final LayananIntegritasPerangkat instance =
      LayananIntegritasPerangkat._();

  Future<HasilIntegritas> periksa() async {
    try {
      final futures = await Future.wait<bool>([
        SafeDevice.isJailBroken,
        SafeDevice.isMockLocation,
        SafeDevice.isRealDevice,
        SafeDevice.isOnExternalStorage,
        SafeDevice.isDevelopmentModeEnable,
      ]);
      final rootPlugin = futures[0];
      final mock = futures[1];
      final asli = futures[2];
      final modeDev = futures[4];

      final native = kReleaseMode
          ? await DetektorNative.instance.periksa()
          : HasilNative.takDidukung;
      final frida = native.frida;
      final debugger = native.debugger;
      final tandaTidakValid =
          native.tandaTanganValid == false || !native.watermarkUtuh;
      final root = rootPlugin || native.root;
      final emu = !asli || native.emulator;

      final amanProduksi =
          !root && !emu && !frida && !debugger && !tandaTidakValid;
      final aman = kReleaseMode ? amanProduksi : !root;

      return HasilIntegritas(
        aman: aman,
        terootJailbreak: root,
        modePengembang: modeDev,
        lokasiPalsu: mock,
        emulator: emu,
        frida: frida,
        debugger: debugger,
        tandaTanganTidakValid: tandaTidakValid,
      );
    } catch (e) {
      return HasilIntegritas(
        aman: false,
        terootJailbreak: false,
        modePengembang: false,
        lokasiPalsu: false,
        emulator: false,
        galat: e.toString(),
      );
    }
  }
}
