import 'dart:math' as math;

import 'package:flutter/material.dart';

class KonfetiSukses extends StatefulWidget {
  const KonfetiSukses({
    super.key,
    this.jumlah = 36,
    this.radiusMaks = 140,
    this.durasi = const Duration(milliseconds: 1600),
    this.jeda = const Duration(milliseconds: 320),
  });

  final int jumlah;
  final double radiusMaks;
  final Duration durasi;
  final Duration jeda;

  @override
  State<KonfetiSukses> createState() => _KonfetiSuksesState();
}

class _KonfetiSuksesState extends State<KonfetiSukses>
    with SingleTickerProviderStateMixin {
  static const _palet = [
    Color(0xFFC8102E),
    Color(0xFFEA8528),
    Color(0xFFF6C90E),
    Color(0xFF2EB67D),
    Color(0xFF1F6FB8),
    Color(0xFF8E5BD9),
  ];

  late final AnimationController _kontroler = AnimationController(
    vsync: this,
    duration: widget.durasi,
  );

  late final List<_Partikel> _partikel;

  @override
  void initState() {
    super.initState();
    final acak = math.Random();
    _partikel = List.generate(widget.jumlah, (_) {
      final sudut = acak.nextDouble() * 2 * math.pi;
      return _Partikel(
        sudut: sudut,
        kecepatan: 0.55 + acak.nextDouble() * 0.45,
        warna: _palet[acak.nextInt(_palet.length)],
        bentukKotak: acak.nextBool(),
        ukuran: 4 + acak.nextDouble() * 5,
        rotasiAwal: acak.nextDouble() * 2 * math.pi,
        kecepatanRotasi: (acak.nextDouble() - 0.5) * 6,
        jatuh: acak.nextDouble() * 0.5,
      );
    });
    Future.delayed(widget.jeda, () {
      if (mounted) _kontroler.forward();
    });
  }

  @override
  void dispose() {
    _kontroler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _kontroler,
        builder: (_, _) {
          return CustomPaint(
            painter: _PengecatKonfeti(
              partikel: _partikel,
              progres: _kontroler.value,
              radiusMaks: widget.radiusMaks,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _Partikel {
  const _Partikel({
    required this.sudut,
    required this.kecepatan,
    required this.warna,
    required this.bentukKotak,
    required this.ukuran,
    required this.rotasiAwal,
    required this.kecepatanRotasi,
    required this.jatuh,
  });

  final double sudut;
  final double kecepatan;
  final Color warna;
  final bool bentukKotak;
  final double ukuran;
  final double rotasiAwal;
  final double kecepatanRotasi;
  final double jatuh;
}

class _PengecatKonfeti extends CustomPainter {
  _PengecatKonfeti({
    required this.partikel,
    required this.progres,
    required this.radiusMaks,
  });

  final List<_Partikel> partikel;
  final double progres;
  final double radiusMaks;

  @override
  void paint(Canvas canvas, Size size) {
    if (progres <= 0) return;
    final pusat = Offset(size.width / 2, size.height / 2);
    final easeOut = 1 - math.pow(1 - progres, 2).toDouble();

    for (final p in partikel) {
      final jarak = radiusMaks * p.kecepatan * easeOut;
      final dx = math.cos(p.sudut) * jarak;
      final dy = math.sin(p.sudut) * jarak + p.jatuh * radiusMaks * progres * progres;
      final posisi = pusat + Offset(dx, dy);

      final opasitas = (1 - progres).clamp(0.0, 1.0);
      final cat = Paint()
        ..style = PaintingStyle.fill
        ..color = p.warna.withValues(alpha: opasitas);

      canvas.save();
      canvas.translate(posisi.dx, posisi.dy);
      canvas.rotate(p.rotasiAwal + p.kecepatanRotasi * progres);
      if (p.bentukKotak) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.ukuran,
            height: p.ukuran * 0.45,
          ),
          cat,
        );
      } else {
        canvas.drawCircle(Offset.zero, p.ukuran / 2, cat);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PengecatKonfeti oldDelegate) =>
      oldDelegate.progres != progres ||
      oldDelegate.radiusMaks != radiusMaks ||
      oldDelegate.partikel != partikel;
}
