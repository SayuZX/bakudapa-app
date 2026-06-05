import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/warna.dart';

class AnimatedSuccessIcon extends StatefulWidget {
  const AnimatedSuccessIcon({
    super.key,
    this.ukuran = 96,
    this.warnaCheck = Warna.sukses,
    this.tebal = 4.0,
    this.mainSuara = true,
    this.sumberSuara = 'sounds/registrasi_sukses.mp3',
    this.volumeSuara = 0.8,
    this.terisi = false,
    this.warnaCentang = Colors.white,
  });

  final double ukuran;
  final Color warnaCheck;
  final double tebal;
  final bool mainSuara;
  final String sumberSuara;
  final double volumeSuara;
  final bool terisi;
  final Color warnaCentang;

  @override
  State<AnimatedSuccessIcon> createState() => _AnimatedSuccessIconState();
}

class _AnimatedSuccessIconState extends State<AnimatedSuccessIcon>
    with TickerProviderStateMixin {
  late final AnimationController _animasi = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  late final Animation<double> _cincin = CurvedAnimation(
    parent: _animasi,
    curve: const Interval(0, 0.45, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _checkmark = CurvedAnimation(
    parent: _animasi,
    curve: const Interval(0.4, 0.85, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _denyut = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 1.06)
          .chain(CurveTween(curve: Curves.easeOut)),
      weight: 50,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.06, end: 1.0)
          .chain(CurveTween(curve: Curves.easeIn)),
      weight: 50,
    ),
  ]).animate(CurvedAnimation(
    parent: _animasi,
    curve: const Interval(0.78, 1.0),
  ));

  AudioPlayer? _pemain;

  @override
  void initState() {
    super.initState();
    _animasi.forward();
    if (widget.mainSuara) {
      _mainkanSuara();
    }
  }

  Future<void> _mainkanSuara() async {
    try {
      final pemain = AudioPlayer();
      _pemain = pemain;
      await pemain.setReleaseMode(ReleaseMode.stop);
      await pemain.setVolume(widget.volumeSuara.clamp(0.0, 1.0));
      await pemain.play(AssetSource(widget.sumberSuara));
    } catch (_) {}
  }

  @override
  void dispose() {
    _animasi.dispose();
    _pemain?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animasi,
      builder: (_, _) {
        return Transform.scale(
          scale: _denyut.value,
          child: CustomPaint(
            size: Size.square(widget.ukuran),
            painter: _PengecatSukses(
              progresCincin: _cincin.value,
              progresCheck: _checkmark.value,
              warna: widget.warnaCheck,
              tebal: widget.tebal,
              terisi: widget.terisi,
              warnaCentang: widget.warnaCentang,
            ),
          ),
        );
      },
    );
  }
}

class _PengecatSukses extends CustomPainter {
  _PengecatSukses({
    required this.progresCincin,
    required this.progresCheck,
    required this.warna,
    required this.tebal,
    required this.terisi,
    required this.warnaCentang,
  });

  final double progresCincin;
  final double progresCheck;
  final Color warna;
  final double tebal;
  final bool terisi;
  final Color warnaCentang;

  @override
  void paint(Canvas canvas, Size size) {
    final pusat = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - tebal;

    if (terisi) {
      final cincinPenuh = (progresCincin * 1.4).clamp(0.0, 1.0);
      final catIsi = Paint()
        ..style = PaintingStyle.fill
        ..color = warna.withValues(alpha: cincinPenuh);
      canvas.drawCircle(pusat, radius + tebal / 2, catIsi);
    } else {
      final catCincin = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = tebal
        ..color = warna;
      canvas.drawArc(
        Rect.fromCircle(center: pusat, radius: radius),
        -math.pi / 2,
        2 * math.pi * progresCincin.clamp(0.0, 1.0),
        false,
        catCincin,
      );
    }

    if (progresCheck > 0) {
      final catCheck = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = terisi ? tebal * 1.2 : tebal
        ..color = terisi ? warnaCentang : warna;

      final p1 = Offset(size.width * 0.30, size.height * 0.52);
      final p2 = Offset(size.width * 0.46, size.height * 0.66);
      final p3 = Offset(size.width * 0.72, size.height * 0.38);

      final totalPanjang = (p2 - p1).distance + (p3 - p2).distance;
      final panjangSekarang = totalPanjang * progresCheck.clamp(0.0, 1.0);
      final panjang1 = (p2 - p1).distance;

      final path = Path()..moveTo(p1.dx, p1.dy);
      if (panjangSekarang <= panjang1) {
        final t = panjangSekarang / panjang1;
        final px = p1.dx + (p2.dx - p1.dx) * t;
        final py = p1.dy + (p2.dy - p1.dy) * t;
        path.lineTo(px, py);
      } else {
        path.lineTo(p2.dx, p2.dy);
        final sisa = panjangSekarang - panjang1;
        final panjang2 = (p3 - p2).distance;
        final t = (sisa / panjang2).clamp(0.0, 1.0);
        final px = p2.dx + (p3.dx - p2.dx) * t;
        final py = p2.dy + (p3.dy - p2.dy) * t;
        path.lineTo(px, py);
      }
      canvas.drawPath(path, catCheck);
    }
  }

  @override
  bool shouldRepaint(covariant _PengecatSukses oldDelegate) =>
      oldDelegate.progresCincin != progresCincin ||
      oldDelegate.progresCheck != progresCheck ||
      oldDelegate.warna != warna ||
      oldDelegate.tebal != tebal ||
      oldDelegate.terisi != terisi ||
      oldDelegate.warnaCentang != warnaCentang;
}
