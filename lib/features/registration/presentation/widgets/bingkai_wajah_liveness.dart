import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/liveness/model_tantangan_liveness.dart';
import '../../../../core/theme/warna.dart';

enum KondisiBingkaiWajah { netral, deteksi, sukses, peringatan }

class BingkaiWajahLiveness extends StatefulWidget {
  const BingkaiWajahLiveness({
    super.key,
    required this.anak,
    this.kondisi = KondisiBingkaiWajah.netral,
    this.diameterFraksi = 0.8,
    this.tampilkanGarisPanduan = true,
    this.offsetWajah = Offset.zero,
    this.wajahTerdeteksi = false,
    this.yawNorm = 0,
    this.pitchNorm = 0,
    this.arahAktif = ArahTantangan.tidakAda,
    this.kemajuanTantangan = 0,
  });

  final Widget anak;
  final KondisiBingkaiWajah kondisi;
  final double diameterFraksi;
  final bool tampilkanGarisPanduan;
  final Offset offsetWajah;
  final bool wajahTerdeteksi;
  final double yawNorm;
  final double pitchNorm;
  final ArahTantangan arahAktif;
  final double kemajuanTantangan;

  @override
  State<BingkaiWajahLiveness> createState() => _BingkaiWajahLivenessState();
}

class _BingkaiWajahLivenessState extends State<BingkaiWajahLiveness>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulsa;

  @override
  void initState() {
    super.initState();
    _pulsa = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulsa.dispose();
    super.dispose();
  }

  Color get _warnaAksen {
    switch (widget.kondisi) {
      case KondisiBingkaiWajah.sukses:
        return const Color(0xFF7BC489);
      case KondisiBingkaiWajah.peringatan:
        return const Color(0xFFF08A6B);
      case KondisiBingkaiWajah.deteksi:
        return Warna.merahUtama;
      case KondisiBingkaiWajah.netral:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final ukuran = math.min(c.maxWidth, c.maxHeight);
        final diameter = ukuran * widget.diameterFraksi;
        final radius = diameter / 2;
        final pergeseran = widget.wajahTerdeteksi
            ? Offset(
                (widget.offsetWajah.dx * radius * 0.55)
                    .clamp(-radius * 0.6, radius * 0.6),
                (widget.offsetWajah.dy * radius * 0.55)
                    .clamp(-radius * 0.6, radius * 0.6),
              )
            : Offset.zero;
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: widget.anak),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _MaskerLuarLingkaran(
                    diameter: diameter,
                    latar: const Color(0xFF0B0D11),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _pulsa,
                builder: (_, _) {
                  return CustomPaint(
                    size: Size.square(ukuran),
                    painter: _PengecatTracking(
                      diameter: diameter,
                      warnaAksen: _warnaAksen,
                      yawNorm: widget.yawNorm.clamp(-1.0, 1.0),
                      pitchNorm: widget.pitchNorm.clamp(-1.0, 1.0),
                      tampilkanGarisPanduan: widget.tampilkanGarisPanduan,
                      wajahTerdeteksi: widget.wajahTerdeteksi,
                      arahAktif: widget.arahAktif,
                      kemajuanAktif:
                          widget.kemajuanTantangan.clamp(0.0, 1.0),
                      fasePulsa: _pulsa.value,
                    ),
                  );
                },
              ),
            ),
            IgnorePointer(
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                offset: Offset(
                  pergeseran.dx / ukuran,
                  pergeseran.dy / ukuran,
                ),
                child: CustomPaint(
                  size: Size.square(ukuran),
                  painter: _PengecatCrosshair(
                    panjang: diameter * 0.18,
                    warna: widget.wajahTerdeteksi
                        ? _warnaAksen
                        : Colors.white.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PengecatCrosshair extends CustomPainter {
  _PengecatCrosshair({required this.panjang, required this.warna});
  final double panjang;
  final Color warna;

  @override
  void paint(Canvas canvas, Size size) {
    final pusat = Offset(size.width / 2, size.height / 2);
    final cat = Paint()
      ..color = warna
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(pusat.dx - panjang / 2, pusat.dy),
      Offset(pusat.dx + panjang / 2, pusat.dy),
      cat,
    );
    canvas.drawLine(
      Offset(pusat.dx, pusat.dy - panjang / 2),
      Offset(pusat.dx, pusat.dy + panjang / 2),
      cat,
    );
  }

  @override
  bool shouldRepaint(covariant _PengecatCrosshair oldDelegate) =>
      oldDelegate.warna != warna || oldDelegate.panjang != panjang;
}

class _MaskerLuarLingkaran extends CustomPainter {
  _MaskerLuarLingkaran({required this.diameter, required this.latar});
  final double diameter;
  final Color latar;

  @override
  void paint(Canvas canvas, Size size) {
    final pusat = Offset(size.width / 2, size.height / 2);
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addOval(Rect.fromCircle(center: pusat, radius: diameter / 2))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = latar);
  }

  @override
  bool shouldRepaint(covariant _MaskerLuarLingkaran oldDelegate) =>
      oldDelegate.diameter != diameter || oldDelegate.latar != latar;
}

class _PengecatTracking extends CustomPainter {
  _PengecatTracking({
    required this.diameter,
    required this.warnaAksen,
    required this.yawNorm,
    required this.pitchNorm,
    required this.tampilkanGarisPanduan,
    required this.wajahTerdeteksi,
    required this.arahAktif,
    required this.kemajuanAktif,
    required this.fasePulsa,
  });

  final double diameter;
  final Color warnaAksen;
  final double yawNorm;
  final double pitchNorm;
  final bool tampilkanGarisPanduan;
  final bool wajahTerdeteksi;
  final ArahTantangan arahAktif;
  final double kemajuanAktif;
  final double fasePulsa;

  static const int _jumlahTik = 72;
  static const double _jarakDariTepi = 14;
  static const double _panjangTikKecil = 6;
  static const double _panjangTikBesar = 12;
  static const double _tebalTik = 1.6;
  static const double _falloffRad = math.pi / 3;
  static const double _falloffArah = math.pi / 4;
  static const double _pulsaAmplitudo = 0.22;
  static const double _reaktifAmplitudo = 1.6;

  @override
  void paint(Canvas canvas, Size size) {
    final pusat = Offset(size.width / 2, size.height / 2);
    final radiusDalam = diameter / 2 + _jarakDariTepi;

    final magnitude =
        math.sqrt(yawNorm * yawNorm + pitchNorm * pitchNorm).clamp(0.0, 1.0);

    final adaArahWajah = wajahTerdeteksi && magnitude > 0.08;
    final sudutArahWajah = adaArahWajah ? math.atan2(yawNorm, -pitchNorm) : 0.0;

    final sudutAktif = _sudutDariArah(arahAktif);
    final adaInstruksi = sudutAktif != null;

    final fase2pi = fasePulsa * 2 * math.pi;

    for (var i = 0; i < _jumlahTik; i++) {
      final sudutTik = -math.pi / 2 + (i / _jumlahTik) * 2 * math.pi;
      final besar = i % 6 == 0;
      final panjangDasar = besar ? _panjangTikBesar : _panjangTikKecil;

      double terangAksen = 0;
      double dekatWajah = 0;
      if (adaArahWajah) {
        final beda = _selisihSudut(
          sudutTik,
          _normalisasiSudut(sudutArahWajah - math.pi / 2),
        );
        dekatWajah = math.max(0.0, 1 - beda / _falloffRad);
        terangAksen = magnitude * dekatWajah;
      }

      double terangInstruksi = 0;
      double dekatInstruksi = 0;
      if (adaInstruksi) {
        final beda = _selisihSudut(
          sudutTik,
          _normalisasiSudut(sudutAktif - math.pi / 2),
        );
        dekatInstruksi = math.max(0.0, 1 - beda / _falloffArah);
        terangInstruksi = dekatInstruksi;
      }

      final gelombang =
          math.sin(fase2pi + i * 0.34) * 0.5 + 0.5;
      final pulsaIdle = gelombang * _pulsaAmplitudo;

      final dorongReaktif =
          dekatWajah * magnitude * _reaktifAmplitudo +
              dekatInstruksi * 0.6;

      final faktorPanjang = 1 + pulsaIdle + dorongReaktif;
      final panjang = panjangDasar * faktorPanjang;

      final warnaDasar = Colors.white.withValues(
        alpha: besar ? 0.55 : 0.28,
      );
      final warnaPanduan = Colors.white.withValues(alpha: 0.85);

      var warna = Color.lerp(warnaDasar, warnaAksen, terangAksen)!;
      if (terangInstruksi > 0) {
        warna = Color.lerp(warna, warnaPanduan, terangInstruksi * 0.85)!;
      }

      final mulai = Offset(
        pusat.dx + math.cos(sudutTik) * radiusDalam,
        pusat.dy + math.sin(sudutTik) * radiusDalam,
      );
      final akhir = Offset(
        pusat.dx + math.cos(sudutTik) * (radiusDalam + panjang),
        pusat.dy + math.sin(sudutTik) * (radiusDalam + panjang),
      );

      final cat = Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = besar ? _tebalTik + 0.4 : _tebalTik
        ..color = warna;
      canvas.drawLine(mulai, akhir, cat);
    }

    final intensitasCincin = wajahTerdeteksi ? magnitude : 0.0;
    final catCincin = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = warnaAksen.withValues(alpha: 0.4 + intensitasCincin * 0.45);
    canvas.drawCircle(pusat, diameter / 2 + 1, catCincin);

    if (adaInstruksi && kemajuanAktif > 0) {
      final catKemajuan = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.6
        ..color = warnaAksen.withValues(alpha: 0.85);
      final rekt = Rect.fromCircle(center: pusat, radius: diameter / 2 + 1);
      final sapuan = math.pi / 2 * kemajuanAktif;
      final sudutMulai = sudutAktif - math.pi / 2 - sapuan / 2;
      canvas.drawArc(rekt, sudutMulai, sapuan, false, catKemajuan);
    }

    if (tampilkanGarisPanduan) {
      final catGaris = Paint()
        ..strokeWidth = 0.8
        ..color = Colors.white.withValues(alpha: 0.18);
      final panjangGaris = diameter * 0.6;
      canvas.drawLine(
        Offset(pusat.dx - panjangGaris / 2, pusat.dy),
        Offset(pusat.dx + panjangGaris / 2, pusat.dy),
        catGaris,
      );
      canvas.drawLine(
        Offset(pusat.dx, pusat.dy - panjangGaris / 2),
        Offset(pusat.dx, pusat.dy + panjangGaris / 2),
        catGaris,
      );
    }
  }

  double? _sudutDariArah(ArahTantangan arah) {
    switch (arah) {
      case ArahTantangan.kiri:
        return math.pi;
      case ArahTantangan.kanan:
        return 0;
      case ArahTantangan.atas:
        return -math.pi / 2;
      case ArahTantangan.bawah:
        return math.pi / 2;
      case ArahTantangan.pusat:
      case ArahTantangan.tidakAda:
        return null;
    }
  }

  double _normalisasiSudut(double sudut) {
    var s = sudut;
    while (s > math.pi) {
      s -= 2 * math.pi;
    }
    while (s < -math.pi) {
      s += 2 * math.pi;
    }
    return s;
  }

  double _selisihSudut(double a, double b) {
    var d = (a - b).abs();
    if (d > math.pi) d = 2 * math.pi - d;
    return d;
  }

  @override
  bool shouldRepaint(covariant _PengecatTracking oldDelegate) =>
      oldDelegate.yawNorm != yawNorm ||
      oldDelegate.pitchNorm != pitchNorm ||
      oldDelegate.wajahTerdeteksi != wajahTerdeteksi ||
      oldDelegate.warnaAksen != warnaAksen ||
      oldDelegate.diameter != diameter ||
      oldDelegate.tampilkanGarisPanduan != tampilkanGarisPanduan ||
      oldDelegate.arahAktif != arahAktif ||
      oldDelegate.kemajuanAktif != kemajuanAktif ||
      oldDelegate.fasePulsa != fasePulsa;
}
