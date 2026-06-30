import 'dart:io';

import 'package:flutter/services.dart';

class HasilNative {
  const HasilNative({
    required this.debugger,
    required this.frida,
    required this.root,
    required this.emulator,
    required this.tandaTanganValid,
    required this.didukung,
    this.watermarkUtuh = true,
    this.sidikTandaTangan,
    this.galat,
  });

  final bool debugger;
  final bool frida;
  final bool root;
  final bool emulator;
  final bool? tandaTanganValid;
  final bool didukung;
  final bool watermarkUtuh;
  final String? sidikTandaTangan;
  final String? galat;

  static const HasilNative takDidukung = HasilNative(
    debugger: false,
    frida: false,
    root: false,
    emulator: false,
    tandaTanganValid: null,
    didukung: false,
  );
}

class DetektorNative {
  DetektorNative._();
  static final DetektorNative instance = DetektorNative._();

  static const MethodChannel _saluran = MethodChannel('bakudapa/keamanan');

  static const String _overrideTandaTangan =
      String.fromEnvironment('BAKUDAPA_SIGNATURE_SHA256', defaultValue: '');

  static const String _sidikUploadSah =
      'f84bd91145394d61010e6386323c2cda'
      'a466b9d7c9ccd23049b2117ef5d0212c';

  Set<String> get _daftarSidikSah {
    final dasar = <String>{_sidikUploadSah};
    if (_overrideTandaTangan.isNotEmpty) {
      dasar.addAll(
        _overrideTandaTangan
            .split(',')
            .map((e) => e.replaceAll(':', '').trim().toLowerCase())
            .where((e) => e.isNotEmpty),
      );
    }
    return dasar;
  }

  Future<HasilNative> periksa() async {
    if (!Platform.isAndroid) return HasilNative.takDidukung;
    try {
      final debugger = await _saluran.invokeMethod<bool>('debuggerTerpasang');
      final frida = await _saluran.invokeMethod<bool>('fridaTerdeteksi');
      final root = await _saluran.invokeMethod<bool>('rootTerdeteksi');
      final emulator = await _saluran.invokeMethod<bool>('emulatorTerdeteksi');
      final sidik = await _saluran.invokeMethod<String>('sidikTandaTangan');

      final sidikNormal = sidik?.replaceAll(':', '').trim().toLowerCase();
      final tandaValid = sidikNormal == null || sidikNormal.isEmpty
          ? null
          : _daftarSidikSah.contains(sidikNormal);

      return HasilNative(
        debugger: debugger ?? false,
        frida: frida ?? false,
        root: root ?? false,
        emulator: emulator ?? false,
        tandaTanganValid: tandaValid,
        didukung: true,
        sidikTandaTangan: sidikNormal,
      );
    } on MissingPluginException {
      return HasilNative.takDidukung;
    } catch (e) {
      return HasilNative(
        debugger: false,
        frida: false,
        root: false,
        emulator: false,
        tandaTanganValid: null,
        didukung: false,
        galat: e.toString(),
      );
    }
  }
}
