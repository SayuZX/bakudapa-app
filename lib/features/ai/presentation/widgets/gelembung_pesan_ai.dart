import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/ai/model_ai_chat.dart';
import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import 'chip_saran_ai.dart';
import 'lencana_asisten_ai.dart';

class GelembungPesanAi extends StatefulWidget {
  const GelembungPesanAi({
    super.key,
    required this.pesan,
    required this.teks,
    required this.saatAksi,
    required this.saatOperator,
    required this.saatCobaLagi,
    required this.saatSaran,
    this.tampilkanSaran = false,
    this.bisaLanjutkan = false,
    this.saatLanjutkan,
    this.bisaRegenerasi = false,
    this.saatRegenerasi,
  });

  final PesanAi pesan;
  final Teks teks;
  final ValueChanged<AksiAi> saatAksi;
  final VoidCallback saatOperator;
  final VoidCallback saatCobaLagi;
  final ValueChanged<String> saatSaran;
  final bool tampilkanSaran;
  final bool bisaLanjutkan;
  final VoidCallback? saatLanjutkan;
  final bool bisaRegenerasi;
  final VoidCallback? saatRegenerasi;

  @override
  State<GelembungPesanAi> createState() => _GelembungPesanAiState();
}

class _GelembungPesanAiState extends State<GelembungPesanAi>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kontrol;
  late final Animation<double> _opasitas;
  late final Animation<Offset> _geser;

  @override
  void initState() {
    super.initState();
    _kontrol = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _opasitas = CurvedAnimation(parent: _kontrol, curve: Curves.easeOut);
    _geser = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _kontrol, curve: Curves.easeOutCubic));
    _kontrol.forward();
  }

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  bool get _dariPengguna => widget.pesan.peran == PeranPesanAi.pengguna;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opasitas,
      child: SlideTransition(
        position: _geser,
        child: _dariPengguna
            ? _bangunPengguna(context)
            : _bangunAsisten(context),
      ),
    );
  }

  Widget _bangunPengguna(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Jarak.lg),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.82,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Jarak.lg,
              vertical: Jarak.md,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Warna.garis),
              borderRadius: BorderRadius.circular(Sudut.xl),
            ),
            child: Text(
              widget.pesan.isi,
              style: context.teks.bodyMedium?.copyWith(
                color: Warna.teksUtama,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bangunAsisten(BuildContext context) {
    final p = widget.pesan;
    final anak = <Widget>[];

    if (p.terjadiGalat) {
      anak.add(_bangunGalat(context));
      anak.add(const SizedBox(height: Jarak.md));
      final detik = p.detikCobaUlang;
      anak.add(
        detik != null && detik > 0
            ? _HitungMundurCobaLagi(
                detikAwal: detik,
                teks: widget.teks,
                saatCobaLagi: widget.saatCobaLagi,
              )
            : _TombolAksiAi(
                label: widget.teks.cobaLagi,
                ikon: HugeIcons.strokeRoundedArrowReloadHorizontal,
                saatKetuk: widget.saatCobaLagi,
              ),
      );
    } else {
      anak.add(_bangunIsi(context));
      final aksiTampil = p.aksi
          .where((a) => a.tipe != TipeAksiAi.takDikenal)
          .toList();
      if (aksiTampil.isNotEmpty) {
        anak.add(const SizedBox(height: Jarak.md));
        anak.add(
          Wrap(
            spacing: Jarak.sm,
            runSpacing: Jarak.sm,
            children: [
              for (final a in aksiTampil)
                _TombolAksiAi(
                  label: a.label,
                  saatKetuk: () => widget.saatAksi(a),
                ),
            ],
          ),
        );
      }
      if (widget.bisaLanjutkan && widget.saatLanjutkan != null) {
        anak.add(const SizedBox(height: Jarak.md));
        anak.add(
          _TombolAksiAi(
            label: widget.teks.lanjutkanAi,
            ikon: HugeIcons.strokeRoundedArrowDown01,
            saatKetuk: widget.saatLanjutkan!,
          ),
        );
      }
      anak.add(const SizedBox(height: Jarak.xs));
      anak.add(
        _BilahAksiPesan(
          isi: p.isi,
          teks: widget.teks,
          bisaRegenerasi: widget.bisaRegenerasi,
          saatRegenerasi: widget.saatRegenerasi,
        ),
      );
    }

    if (p.butuhOperator) {
      anak.add(const SizedBox(height: Jarak.md));
      anak.add(_bangunOperator(context));
    }

    if (widget.tampilkanSaran && p.saran.isNotEmpty) {
      anak.add(const SizedBox(height: Jarak.lg));
      anak.add(
        Wrap(
          spacing: Jarak.sm,
          runSpacing: Jarak.sm,
          children: [
            for (final s in p.saran)
              ChipSaranAi(label: s, saatKetuk: () => widget.saatSaran(s)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: Jarak.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LencanaAsistenAi(),
          const SizedBox(width: Jarak.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: anak,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bangunIsi(BuildContext context) {
    final dasar = context.teks;
    return MarkdownBody(
      data: widget.pesan.isi,
      selectable: true,
      softLineBreak: true,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: dasar.bodyMedium?.copyWith(color: Warna.teksUtama, height: 1.6),
        a: dasar.bodyMedium?.copyWith(
          color: Warna.primer,
          fontWeight: FontWeight.w600,
        ),
        strong: dasar.bodyMedium?.copyWith(
          color: Warna.teksUtama,
          fontWeight: FontWeight.w700,
        ),
        listBullet: dasar.bodyMedium?.copyWith(
          color: Warna.teksUtama,
          height: 1.6,
        ),
        h1: dasar.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        h2: dasar.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        h3: dasar.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        blockquote: dasar.bodyMedium?.copyWith(color: Warna.teksKedua),
        code: dasar.bodySmall?.copyWith(
          fontFamily: 'monospace',
          color: Warna.teksUtama,
          backgroundColor: Warna.netral100,
        ),
        listBulletPadding: const EdgeInsets.only(right: Jarak.sm),
        blockSpacing: Jarak.sm,
      ),
    );
  }

  Widget _bangunGalat(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Jarak.lg,
        vertical: Jarak.md,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Warna.garis),
        borderRadius: BorderRadius.circular(Sudut.xl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            HugeIcons.strokeRoundedInformationCircle,
            size: 18,
            color: Warna.peringatan,
          ),
          const SizedBox(width: Jarak.sm),
          Expanded(
            child: Text(
              widget.pesan.isi,
              style: context.teks.bodyMedium?.copyWith(
                color: Warna.teksUtama,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bangunOperator(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.teks.butuhBantuanOperator,
          style: context.teks.bodySmall?.copyWith(color: Warna.teksKedua),
        ),
        const SizedBox(height: Jarak.sm),
        _TombolAksiAi(
          label: widget.teks.hubungiDisdukcapil,
          ikon: HugeIcons.strokeRoundedHelpCircle,
          saatKetuk: widget.saatOperator,
        ),
      ],
    );
  }
}

class _TombolAksiAi extends StatelessWidget {
  const _TombolAksiAi({
    required this.label,
    required this.saatKetuk,
    this.ikon,
  });

  final String label;
  final VoidCallback saatKetuk;
  final IconData? ikon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: saatKetuk,
      style: OutlinedButton.styleFrom(
        foregroundColor: Warna.primer,
        side: const BorderSide(color: Warna.primer, width: 1.2),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: Jarak.lg,
          vertical: Jarak.sm,
        ),
        minimumSize: const Size(0, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ikon != null) ...[
            Icon(ikon, size: 16),
            const SizedBox(width: Jarak.xs + 2),
          ],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _BilahAksiPesan extends StatelessWidget {
  const _BilahAksiPesan({
    required this.isi,
    required this.teks,
    required this.bisaRegenerasi,
    this.saatRegenerasi,
  });

  final String isi;
  final Teks teks;
  final bool bisaRegenerasi;
  final VoidCallback? saatRegenerasi;

  Future<void> _salin(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: isi));
    HapticFeedback.selectionClick();
    if (context.mounted) context.tampilkanSukses(teks.disalin);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AksiIkon(
          ikon: HugeIcons.strokeRoundedCopy01,
          tooltip: teks.salinPesan,
          saatKetuk: () => _salin(context),
        ),
        if (bisaRegenerasi && saatRegenerasi != null)
          _AksiIkon(
            ikon: HugeIcons.strokeRoundedArrowReloadHorizontal,
            tooltip: teks.regenerasi,
            saatKetuk: saatRegenerasi!,
          ),
      ],
    );
  }
}

class _AksiIkon extends StatelessWidget {
  const _AksiIkon({
    required this.ikon,
    required this.tooltip,
    required this.saatKetuk,
  });

  final IconData ikon;
  final String tooltip;
  final VoidCallback saatKetuk;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: saatKetuk,
        radius: 22,
        child: Padding(
          padding: const EdgeInsets.all(Jarak.sm),
          child: Icon(ikon, size: 17, color: Warna.teksKetiga),
        ),
      ),
    );
  }
}

class _HitungMundurCobaLagi extends StatefulWidget {
  const _HitungMundurCobaLagi({
    required this.detikAwal,
    required this.teks,
    required this.saatCobaLagi,
  });

  final int detikAwal;
  final Teks teks;
  final VoidCallback saatCobaLagi;

  @override
  State<_HitungMundurCobaLagi> createState() => _HitungMundurCobaLagiState();
}

class _HitungMundurCobaLagiState extends State<_HitungMundurCobaLagi> {
  late int _sisa = widget.detikAwal;
  Timer? _pengatur;

  @override
  void initState() {
    super.initState();
    _pengatur = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _sisa = _sisa > 0 ? _sisa - 1 : 0);
      if (_sisa <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _pengatur?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sisa <= 0) {
      return _TombolAksiAi(
        label: widget.teks.cobaLagi,
        ikon: HugeIcons.strokeRoundedArrowReloadHorizontal,
        saatKetuk: widget.saatCobaLagi,
      );
    }
    return Row(
      children: [
        const Icon(
          HugeIcons.strokeRoundedClock01,
          size: 15,
          color: Warna.teksKetiga,
        ),
        const SizedBox(width: Jarak.sm),
        Text(
          widget.teks.cobaLagiDalam(_sisa),
          style: context.teks.bodySmall?.copyWith(color: Warna.teksKetiga),
        ),
      ],
    );
  }
}
