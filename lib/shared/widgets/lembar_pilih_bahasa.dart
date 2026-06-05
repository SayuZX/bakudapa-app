import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/extensions/konteks.dart';
import '../../core/localization/teks.dart';
import '../../core/theme/dimensi.dart';
import '../../core/theme/warna.dart';
import '../providers/penyedia_bahasa.dart';
import '../providers/penyedia_toast_bahasa.dart';
import 'mesin_restart.dart';

class LembarPilihBahasa {
  const LembarPilihBahasa._();

  static Future<void> tampilkan(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Warna.permukaan,
      isScrollControlled: false,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _IsiLembarPilihBahasa(),
    );
  }
}

class _IsiLembarPilihBahasa extends ConsumerStatefulWidget {
  const _IsiLembarPilihBahasa();

  @override
  ConsumerState<_IsiLembarPilihBahasa> createState() =>
      _IsiLembarPilihBahasaState();
}

class _IsiLembarPilihBahasaState extends ConsumerState<_IsiLembarPilihBahasa> {
  late KodeBahasa _terpilih;

  @override
  void initState() {
    super.initState();
    _terpilih = ref.read(penyediaBahasa);
  }

  Future<void> _terapkan() async {
    final aktif = ref.read(penyediaBahasa);
    if (_terpilih == aktif) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    await ref.read(penyediaBahasa.notifier).ubah(_terpilih);
    if (!mounted) return;
    ref.read(perluToastBahasaProvider.notifier).state = true;
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MesinRestart.mulaiUlang();
    });
  }

  String _labelTombol(Teks t) {
    return _terpilih == KodeBahasa.en
        ? t.useEnglish
        : t.gunakanBahasaIndonesia;
  }

  String _namaBahasa(KodeBahasa kode, Teks t) {
    switch (kode) {
      case KodeBahasa.id:
        return t.bahasaIndonesiaLabel;
      case KodeBahasa.en:
        return t.englishUkLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final aktif = ref.watch(penyediaBahasa);
    final t = ref.watch(teksProvider);
    final ubahan = _terpilih != aktif;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.pilihBahasa,
                        style: context.teks.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.bahasaApaYangInginDigunakan,
                        style: context.teks.bodySmall?.copyWith(
                          color: Warna.teksKedua,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                _TombolTutup(onTap: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: Jarak.xl),
            for (var i = 0; i < KodeBahasa.values.length; i++) ...[
              _BarisOpsi(
                kode: KodeBahasa.values[i],
                nama: _namaBahasa(KodeBahasa.values[i], t),
                terpilih: _terpilih == KodeBahasa.values[i],
                onTap: () =>
                    setState(() => _terpilih = KodeBahasa.values[i]),
              ),
              if (i < KodeBahasa.values.length - 1)
                const Divider(height: 1, color: Warna.pemisah),
            ],
            const SizedBox(height: Jarak.xxl),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: ubahan ? _terapkan : null,
                style: FilledButton.styleFrom(
                  backgroundColor: Warna.merahUtama,
                  disabledBackgroundColor: Warna.netral200,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Warna.teksKetiga,
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                child: Text(_labelTombol(t)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TombolTutup extends StatelessWidget {
  const _TombolTutup({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Warna.netral100,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            HugeIcons.strokeRoundedCancel01,
            size: 16,
            color: Warna.teksKedua,
          ),
        ),
      ),
    );
  }
}

class _BarisOpsi extends StatelessWidget {
  const _BarisOpsi({
    required this.kode,
    required this.nama,
    required this.terpilih,
    required this.onTap,
  });

  final KodeBahasa kode;
  final String nama;
  final bool terpilih;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            _Bendera(kode: kode),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                nama,
                style: context.teks.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Warna.teksUtama,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            _RadioIndikator(terpilih: terpilih),
          ],
        ),
      ),
    );
  }
}

class _RadioIndikator extends StatelessWidget {
  const _RadioIndikator({required this.terpilih});
  final bool terpilih;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: terpilih ? Warna.merahUtama : Warna.netral300,
          width: terpilih ? 6 : 1.6,
        ),
        color: terpilih ? Colors.white : Colors.transparent,
      ),
    );
  }
}

class _Bendera extends StatelessWidget {
  const _Bendera({required this.kode});
  final KodeBahasa kode;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 28,
        height: 28,
        child: switch (kode) {
          KodeBahasa.id => CustomPaint(painter: _BenderaIdPainter()),
          KodeBahasa.en => CustomPaint(painter: _BenderaUkPainter()),
        },
      ),
    );
  }
}

class _BenderaIdPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cat = Paint()..color = const Color(0xFFE70011);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height / 2),
      cat,
    );
    cat.color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2),
      cat,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _BenderaUkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final biru = Paint()..color = const Color(0xFF012169);
    canvas.drawRect(Offset.zero & size, biru);

    final cross = Paint()
      ..color = Colors.white
      ..strokeWidth = w * 0.18
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(Offset(0, 0), Offset(w, h), cross);
    canvas.drawLine(Offset(w, 0), Offset(0, h), cross);

    final salib = Paint()
      ..color = const Color(0xFFC8102E)
      ..strokeWidth = w * 0.08;
    canvas.drawLine(Offset(0, 0), Offset(w, h), salib);
    canvas.drawLine(Offset(w, 0), Offset(0, h), salib);

    final tengahPutih = Paint()
      ..color = Colors.white
      ..strokeWidth = w * 0.24;
    canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), tengahPutih);
    canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), tengahPutih);

    final tengahMerah = Paint()
      ..color = const Color(0xFFC8102E)
      ..strokeWidth = w * 0.14;
    canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), tengahMerah);
    canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), tengahMerah);
  }

  @override
  bool shouldRepaint(_) => false;
}
