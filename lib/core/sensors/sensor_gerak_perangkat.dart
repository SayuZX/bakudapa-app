import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';

class HasilGerakPerangkat {
  const HasilGerakPerangkat({required this.magnitudo, required this.goyang});

  final double magnitudo;
  final bool goyang;
}

class SensorGerakPerangkat {
  SensorGerakPerangkat._();
  static final SensorGerakPerangkat instance = SensorGerakPerangkat._();

  static const double _ambangGoyang = 1.8;
  static const Duration _intervalSampel = Duration(milliseconds: 120);

  StreamSubscription<UserAccelerometerEvent>? _langgan;
  final StreamController<HasilGerakPerangkat> _kontroler =
      StreamController<HasilGerakPerangkat>.broadcast();
  double _emaMagnitudo = 0;

  Stream<HasilGerakPerangkat> get aliran => _kontroler.stream;

  void mulai() {
    if (_langgan != null) return;
    _langgan = userAccelerometerEventStream(samplingPeriod: _intervalSampel)
        .listen(_olah);
  }

  void _olah(UserAccelerometerEvent e) {
    final mag = math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
    _emaMagnitudo = _emaMagnitudo * 0.6 + mag * 0.4;
    final goyang = _emaMagnitudo > _ambangGoyang;
    _kontroler.add(
      HasilGerakPerangkat(magnitudo: _emaMagnitudo, goyang: goyang),
    );
  }

  Future<void> hentikan() async {
    await _langgan?.cancel();
    _langgan = null;
    _emaMagnitudo = 0;
  }

  Future<void> buang() async {
    await hentikan();
    await _kontroler.close();
  }
}
