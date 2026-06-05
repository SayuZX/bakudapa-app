import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../../shared/providers/penyedia_bahasa.dart';
import '../../../../shared/widgets/lembar_pilih_bahasa.dart';

class BingkaiOtentikasi extends StatelessWidget {
  const BingkaiOtentikasi({
    super.key,
    required this.judul,
    required this.subJudul,
    required this.anak,
    this.tampilkanKembali = false,
    this.tinggiHero = 300,
  });

  final String judul;
  final String subJudul;
  final Widget anak;
  final bool tampilkanKembali;
  final double tinggiHero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.permukaan,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _Hero(tinggi: tinggiHero, tampilkanKembali: tampilkanKembali),
          ),
          Positioned.fill(
            top: tinggiHero - 36,
            child: Container(
              decoration: const BoxDecoration(
                color: Warna.permukaan,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  28,
                  40,
                  28,
                  28 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      judul,
                      textAlign: TextAlign.center,
                      style: context.teks.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subJudul,
                      textAlign: TextAlign.center,
                      style: context.teks.bodyMedium?.copyWith(
                        color: Warna.teksKedua,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: Jarak.xxl),
                    anak,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.tinggi, required this.tampilkanKembali});
  final double tinggi;
  final bool tampilkanKembali;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: tinggi,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/hero-malut.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (_, _, _) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFC8102E), Color(0xFFEA8528)],
                ),
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.55, 1.0],
                colors: [
                  Color(0xB3000000),
                  Color(0x33000000),
                  Color(0x66000000),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (tampilkanKembali)
                      _TombolBundar(
                        ikon: Icons.arrow_back,
                        onTap: () => context.canPop() ? context.pop() : null,
                      )
                    else
                      const _Wordmark(),
                    const ChipPilihBahasa(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BAKUDAPA',
          style: GoogleFonts.sora(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Disdukcapil Maluku Utara',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withValues(alpha: 0.92),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class ChipPilihBahasa extends ConsumerWidget {
  const ChipPilihBahasa({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bahasa = ref.watch(penyediaBahasa);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => LembarPilihBahasa.tampilkan(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Bendera(kode: bahasa),
            const SizedBox(width: 6),
            Text(
              bahasa.kode.toUpperCase(),
              style: const TextStyle(
                color: Warna.teksUtama,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.expand_more, color: Warna.teksKetiga, size: 16),
          ],
        ),
      ),
    );
  }

}

class _Bendera extends StatelessWidget {
  const _Bendera({required this.kode});
  final KodeBahasa kode;

  static const double _tinggi = 11;
  static const double _lebar = 16;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        width: _lebar,
        height: _tinggi,
        child: switch (kode) {
          KodeBahasa.id => Column(
              children: [
                Expanded(child: Container(color: const Color(0xFFE70011))),
                Expanded(child: Container(color: Colors.white)),
              ],
            ),
          KodeBahasa.en => CustomPaint(
              painter: _BenderaUSPainter(),
              size: const Size(_lebar, _tinggi),
            ),
        },
      ),
    );
  }
}

class _BenderaUSPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cat = Paint();

    cat.color = Colors.white;
    canvas.drawRect(Offset.zero & size, cat);

    cat.color = const Color(0xFFB22234);
    final tinggiGaris = size.height / 13;
    for (var i = 0; i < 13; i++) {
      if (i.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(0, i * tinggiGaris, size.width, tinggiGaris),
          cat,
        );
      }
    }

    cat.color = const Color(0xFF3C3B6E);
    final union = Rect.fromLTWH(
      0,
      0,
      size.width * 0.4,
      tinggiGaris * 7,
    );
    canvas.drawRect(union, cat);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _TombolBundar extends StatelessWidget {
  const _TombolBundar({required this.ikon, required this.onTap});
  final IconData ikon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(ikon, color: Warna.teksUtama, size: 22),
        ),
      ),
    );
  }
}
