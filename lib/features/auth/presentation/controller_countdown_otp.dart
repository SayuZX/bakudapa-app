import 'dart:async';

import 'package:flutter/foundation.dart';

class KondisiCountdownOtp {
  const KondisiCountdownOtp({
    required this.detikCooldown,
    required this.detikKedaluwarsa,
  });

  final int detikCooldown;
  final int detikKedaluwarsa;

  bool get bolehKirimUlang => detikCooldown == 0;
  bool get sudahKedaluwarsa => detikKedaluwarsa == 0;
}

class ControllerCountdownOtp extends ValueNotifier<KondisiCountdownOtp> {
  ControllerCountdownOtp({
    this.cooldown = const Duration(seconds: 60),
    this.kedaluwarsa = const Duration(minutes: 5),
  }) : super(const KondisiCountdownOtp(
          detikCooldown: 0,
          detikKedaluwarsa: 0,
        ));

  final Duration cooldown;
  final Duration kedaluwarsa;

  Timer? _ticker;
  DateTime? _terakhirKirim;
  DateTime? _kedaluwarsaPada;

  void tandaiKirim() {
    final sekarang = DateTime.now();
    _terakhirKirim = sekarang;
    _kedaluwarsaPada = sekarang.add(kedaluwarsa);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _hitung());
    _hitung();
  }

  void _hitung() {
    final sekarang = DateTime.now();
    final cooldownSisa = _terakhirKirim == null
        ? 0
        : (cooldown - sekarang.difference(_terakhirKirim!))
            .inSeconds
            .clamp(0, cooldown.inSeconds);
    final kedaluwarsaSisa = _kedaluwarsaPada == null
        ? 0
        : (_kedaluwarsaPada!.difference(sekarang))
            .inSeconds
            .clamp(0, kedaluwarsa.inSeconds);
    value = KondisiCountdownOtp(
      detikCooldown: cooldownSisa,
      detikKedaluwarsa: kedaluwarsaSisa,
    );
    if (cooldownSisa == 0 && kedaluwarsaSisa == 0) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
