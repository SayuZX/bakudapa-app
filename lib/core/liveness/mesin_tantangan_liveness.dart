import 'layanan_deteksi_wajah.dart';
import 'model_tantangan_liveness.dart';

enum StatusEvaluasi {
  menunggu,
  sedangBerlangsung,
  arahSalah,
  lulus,
}

class HasilEvaluasi {
  const HasilEvaluasi({
    required this.status,
    required this.kemajuan,
    this.arahSalah = ArahTantangan.tidakAda,
  });

  final StatusEvaluasi status;
  final double kemajuan;
  final ArahTantangan arahSalah;

  static const awal = HasilEvaluasi(
    status: StatusEvaluasi.menunggu,
    kemajuan: 0,
  );
}

abstract class EvaluatorTantangan {
  HasilEvaluasi evaluasi(HasilDeteksiWajah w);
  void reset();
}

class _EvaluatorHadapArah implements EvaluatorTantangan {
  _EvaluatorHadapArah({required this.arahDiminta});
  final ArahTantangan arahDiminta;

  static const double _ambangSiap = 18.0;
  static const double _ambangSalah = 14.0;
  static const int _frameKonfirmasi = 3;

  int _frameSesuai = 0;

  @override
  HasilEvaluasi evaluasi(HasilDeteksiWajah w) {
    if (!w.ada) {
      _frameSesuai = 0;
      return HasilEvaluasi.awal;
    }
    final yaw = w.sudutY ?? 0;

    final hadapKiri = yaw < -_ambangSiap;
    final hadapKanan = yaw > _ambangSiap;
    final salahKiri = yaw < -_ambangSalah && arahDiminta == ArahTantangan.kanan;
    final salahKanan = yaw > _ambangSalah && arahDiminta == ArahTantangan.kiri;

    var sesuai = false;
    if (arahDiminta == ArahTantangan.kiri && hadapKiri) sesuai = true;
    if (arahDiminta == ArahTantangan.kanan && hadapKanan) sesuai = true;

    if (sesuai) {
      _frameSesuai++;
      final kemajuan = (_frameSesuai / _frameKonfirmasi).clamp(0.0, 1.0);
      if (_frameSesuai >= _frameKonfirmasi) {
        return HasilEvaluasi(
          status: StatusEvaluasi.lulus,
          kemajuan: 1,
        );
      }
      return HasilEvaluasi(
        status: StatusEvaluasi.sedangBerlangsung,
        kemajuan: kemajuan,
      );
    }
    _frameSesuai = 0;
    if (salahKiri || salahKanan) {
      return HasilEvaluasi(
        status: StatusEvaluasi.arahSalah,
        kemajuan: 0,
        arahSalah: salahKiri ? ArahTantangan.kiri : ArahTantangan.kanan,
      );
    }
    return HasilEvaluasi.awal;
  }

  @override
  void reset() => _frameSesuai = 0;
}

class _EvaluatorAnggukKepala implements EvaluatorTantangan {
  static const double _ambangBawah = 12.0;
  static const double _ambangKembali = 6.0;
  static const int _siklusDibutuhkan = 1;

  bool _sudahMiringBawah = false;
  int _siklusTuntas = 0;

  @override
  HasilEvaluasi evaluasi(HasilDeteksiWajah w) {
    if (!w.ada) return HasilEvaluasi.awal;
    final pitch = w.sudutX ?? 0;

    if (!_sudahMiringBawah && pitch > _ambangBawah) {
      _sudahMiringBawah = true;
    } else if (_sudahMiringBawah && pitch.abs() < _ambangKembali) {
      _siklusTuntas++;
      _sudahMiringBawah = false;
    }

    if (_siklusTuntas >= _siklusDibutuhkan) {
      return const HasilEvaluasi(status: StatusEvaluasi.lulus, kemajuan: 1);
    }
    final kemajuan = _sudahMiringBawah ? 0.5 : (_siklusTuntas / _siklusDibutuhkan);
    return HasilEvaluasi(
      status: kemajuan > 0
          ? StatusEvaluasi.sedangBerlangsung
          : StatusEvaluasi.menunggu,
      kemajuan: kemajuan.clamp(0.0, 1.0),
    );
  }

  @override
  void reset() {
    _sudahMiringBawah = false;
    _siklusTuntas = 0;
  }
}

class _EvaluatorKedipMata implements EvaluatorTantangan {
  static const double _ambangTutup = 0.35;
  static const double _ambangBuka = 0.7;
  static const int _kedipDibutuhkan = 2;

  bool _terakhirTutup = false;
  int _hitunganKedip = 0;

  @override
  HasilEvaluasi evaluasi(HasilDeteksiWajah w) {
    if (!w.ada) return HasilEvaluasi.awal;
    final kiri = w.bukaMataKiri;
    final kanan = w.bukaMataKanan;
    if (kiri == null || kanan == null) return HasilEvaluasi.awal;

    final tertutup = kiri < _ambangTutup && kanan < _ambangTutup;
    final terbuka = kiri > _ambangBuka && kanan > _ambangBuka;

    if (tertutup) {
      _terakhirTutup = true;
    } else if (_terakhirTutup && terbuka) {
      _hitunganKedip++;
      _terakhirTutup = false;
    }

    if (_hitunganKedip >= _kedipDibutuhkan) {
      return const HasilEvaluasi(status: StatusEvaluasi.lulus, kemajuan: 1);
    }
    final kemajuan = _hitunganKedip / _kedipDibutuhkan;
    return HasilEvaluasi(
      status: _hitunganKedip > 0
          ? StatusEvaluasi.sedangBerlangsung
          : StatusEvaluasi.menunggu,
      kemajuan: kemajuan,
    );
  }

  @override
  void reset() {
    _terakhirTutup = false;
    _hitunganKedip = 0;
  }
}

class _EvaluatorBukaMulut implements EvaluatorTantangan {
  static const double _ambangBuka = 0.08;
  static const int _frameKonfirmasi = 3;

  int _frameBuka = 0;

  @override
  HasilEvaluasi evaluasi(HasilDeteksiWajah w) {
    if (!w.ada) {
      _frameBuka = 0;
      return HasilEvaluasi.awal;
    }
    final bukaMulut = w.bukaMulutNormal;
    if (bukaMulut == null) return HasilEvaluasi.awal;

    if (bukaMulut >= _ambangBuka) {
      _frameBuka++;
      final kemajuan = (_frameBuka / _frameKonfirmasi).clamp(0.0, 1.0);
      if (_frameBuka >= _frameKonfirmasi) {
        return const HasilEvaluasi(status: StatusEvaluasi.lulus, kemajuan: 1);
      }
      return HasilEvaluasi(
        status: StatusEvaluasi.sedangBerlangsung,
        kemajuan: kemajuan,
      );
    }
    _frameBuka = 0;
    return HasilEvaluasi.awal;
  }

  @override
  void reset() => _frameBuka = 0;
}

class _EvaluatorSenyum implements EvaluatorTantangan {
  static const double _ambang = 0.7;
  static const int _frameKonfirmasi = 4;

  int _frameSenyum = 0;

  @override
  HasilEvaluasi evaluasi(HasilDeteksiWajah w) {
    if (!w.ada) {
      _frameSenyum = 0;
      return HasilEvaluasi.awal;
    }
    final s = w.senyum;
    if (s == null) return HasilEvaluasi.awal;

    if (s >= _ambang) {
      _frameSenyum++;
      final kemajuan = (_frameSenyum / _frameKonfirmasi).clamp(0.0, 1.0);
      if (_frameSenyum >= _frameKonfirmasi) {
        return const HasilEvaluasi(status: StatusEvaluasi.lulus, kemajuan: 1);
      }
      return HasilEvaluasi(
        status: StatusEvaluasi.sedangBerlangsung,
        kemajuan: kemajuan,
      );
    }
    _frameSenyum = 0;
    return HasilEvaluasi.awal;
  }

  @override
  void reset() => _frameSenyum = 0;
}

class MesinTantanganLiveness {
  MesinTantanganLiveness();

  EvaluatorTantangan _buatEvaluator(TantanganLiveness t) {
    switch (t.jenis) {
      case JenisTantanganLiveness.hadapKiri:
        return _EvaluatorHadapArah(arahDiminta: ArahTantangan.kiri);
      case JenisTantanganLiveness.hadapKanan:
        return _EvaluatorHadapArah(arahDiminta: ArahTantangan.kanan);
      case JenisTantanganLiveness.anggukKepala:
        return _EvaluatorAnggukKepala();
      case JenisTantanganLiveness.kedipMata:
        return _EvaluatorKedipMata();
      case JenisTantanganLiveness.bukaMulut:
        return _EvaluatorBukaMulut();
      case JenisTantanganLiveness.senyum:
        return _EvaluatorSenyum();
    }
  }

  EvaluatorTantangan untuk(TantanganLiveness t) => _buatEvaluator(t);
}
