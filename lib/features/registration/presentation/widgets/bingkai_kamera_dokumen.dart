import 'package:flutter/material.dart';

import '../../../../core/theme/warna.dart';

class BingkaiKameraDokumen extends StatelessWidget {
  const BingkaiKameraDokumen({
    super.key,
    required this.anak,
    this.rasio = 1.586,
    this.lebarFraksi = 0.92,
  });

  final Widget anak;
  final double rasio;
  final double lebarFraksi;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final lebar = c.maxWidth * lebarFraksi;
        final tinggi = lebar / rasio;
        final dx = (c.maxWidth - lebar) / 2;
        final dy = (c.maxHeight - tinggi) / 2;
        final rectLubang = Rect.fromLTWH(dx, dy, lebar, tinggi);

        return Stack(
          children: [
            Positioned.fill(child: anak),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _MaskerLuarKotak(
                    rectLubang: rectLubang,
                    radius: 16,
                    latar: Colors.black.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
            Positioned.fromRect(
              rect: rectLubang,
              child: IgnorePointer(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Warna.merahUtama, width: 2),
                        ),
                      ),
                    ),
                    CustomPaint(
                      size: Size(lebar, tinggi),
                      painter: _SudutPainter(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MaskerLuarKotak extends CustomPainter {
  _MaskerLuarKotak({
    required this.rectLubang,
    required this.radius,
    required this.latar,
  });

  final Rect rectLubang;
  final double radius;
  final Color latar;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(rectLubang, Radius.circular(radius)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = latar);
  }

  @override
  bool shouldRepaint(covariant _MaskerLuarKotak oldDelegate) =>
      oldDelegate.rectLubang != rectLubang ||
      oldDelegate.radius != radius ||
      oldDelegate.latar != latar;
}

class _SudutPainter extends CustomPainter {
  static const double _panjang = 22;
  static const double _tebal = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final cat = Paint()
      ..color = Colors.white
      ..strokeWidth = _tebal
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(0, 0), const Offset(_panjang, 0), cat);
    canvas.drawLine(const Offset(0, 0), const Offset(0, _panjang), cat);

    canvas.drawLine(Offset(size.width, 0), Offset(size.width - _panjang, 0), cat);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, _panjang), cat);

    canvas.drawLine(Offset(0, size.height), Offset(_panjang, size.height), cat);
    canvas.drawLine(
        Offset(0, size.height), Offset(0, size.height - _panjang), cat);

    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - _panjang, size.height), cat);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - _panjang), cat);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
