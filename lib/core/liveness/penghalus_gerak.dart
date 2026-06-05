import 'dart:ui';

class PenghalusEma {
  PenghalusEma({this.alpha = 0.3, double awal = 0});
  final double alpha;
  double _nilai = 0;
  bool _terinisialisasi = false;

  double get nilai => _nilai;

  double terapkan(double sampel) {
    if (!_terinisialisasi) {
      _nilai = sampel;
      _terinisialisasi = true;
      return _nilai;
    }
    _nilai = _nilai * (1 - alpha) + sampel * alpha;
    return _nilai;
  }

  void atur(double nilai) {
    _nilai = nilai;
    _terinisialisasi = true;
  }

  void reset() {
    _nilai = 0;
    _terinisialisasi = false;
  }
}

class PenghalusOffset {
  PenghalusOffset({this.alpha = 0.3});
  final double alpha;
  Offset _nilai = Offset.zero;
  bool _terinisialisasi = false;

  Offset get nilai => _nilai;

  Offset terapkan(Offset sampel) {
    if (!_terinisialisasi) {
      _nilai = sampel;
      _terinisialisasi = true;
      return _nilai;
    }
    _nilai = Offset(
      _nilai.dx * (1 - alpha) + sampel.dx * alpha,
      _nilai.dy * (1 - alpha) + sampel.dy * alpha,
    );
    return _nilai;
  }

  void reset() {
    _nilai = Offset.zero;
    _terinisialisasi = false;
  }
}

class PenahanThreshold {
  PenahanThreshold({required this.ambang});
  final double ambang;
  double _terakhir = 0;
  bool _terinisialisasi = false;

  double terapkan(double sampel) {
    if (!_terinisialisasi) {
      _terakhir = sampel;
      _terinisialisasi = true;
      return _terakhir;
    }
    if ((sampel - _terakhir).abs() > ambang) {
      _terakhir = sampel;
    }
    return _terakhir;
  }

  void reset() {
    _terakhir = 0;
    _terinisialisasi = false;
  }
}
