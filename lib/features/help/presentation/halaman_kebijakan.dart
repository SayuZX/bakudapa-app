import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../core/utils/format.dart';
import '../data/repositori_kebijakan.dart';
import '../providers/penyedia_kebijakan.dart';

export '../../../core/enums/jenis_kebijakan.dart' show JenisKebijakan;

class HalamanKebijakan extends ConsumerStatefulWidget {
  const HalamanKebijakan({
    super.key,
    required this.jenis,
    this.modePersetujuan = false,
  });

  final JenisKebijakan jenis;
  final bool modePersetujuan;

  @override
  ConsumerState<HalamanKebijakan> createState() => _HalamanKebijakanState();
}

class _HalamanKebijakanState extends ConsumerState<HalamanKebijakan> {
  final ScrollController _kontrolerScroll = ScrollController();
  bool _sudahDibaca = false;

  @override
  void initState() {
    super.initState();
    _kontrolerScroll.addListener(_periksaScroll);
  }

  void _periksaScroll() {
    if (!mounted) return;
    if (!_kontrolerScroll.hasClients) return;
    final maks = _kontrolerScroll.position.maxScrollExtent;
    final sekarang = _kontrolerScroll.position.pixels;
    final sudah = maks <= 0 || sekarang >= maks - 24;
    if (sudah && !_sudahDibaca) {
      setState(() => _sudahDibaca = true);
    }
  }

  @override
  void dispose() {
    _kontrolerScroll.removeListener(_periksaScroll);
    _kontrolerScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);
    final asyncKonten = ref.watch(penyediaKontenKebijakan(widget.jenis));
    final judulAppBar = asyncKonten.maybeWhen(
      data: (k) => k.judul,
      orElse: () => widget.jenis.labelId,
    );

    return Scaffold(
      backgroundColor: Warna.permukaan,
      appBar: AppBar(
        title: Text(judulAppBar),
        leading: IconButton(
          onPressed: () => context.canPop()
              ? context.pop(false)
              : Navigator.of(context).maybePop(),
          icon: const Icon(HugeIcons.strokeRoundedArrowLeft01),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: asyncKonten.when(
              data: (konten) => _isi(context, konten, t),
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: Warna.primer,
                  strokeWidth: 2.4,
                ),
              ),
              error: (_, _) => _galat(context, t),
            ),
          ),
          if (widget.modePersetujuan) _barPersetujuan(context, t),
        ],
      ),
    );
  }

  Widget _isi(BuildContext context, KontenKebijakan konten, Teks t) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _periksaScroll());
    final tanggal = DateTime.tryParse(konten.berlakuSejak ?? '');
    final tanggalTeks =
        tanggal != null ? Format.tanggalPanjang(tanggal) : konten.berlakuSejak;
    final adaMeta = konten.berlakuSejak != null || konten.versi != null;

    return Scrollbar(
      controller: _kontrolerScroll,
      thumbVisibility: true,
      child: ListView(
        controller: _kontrolerScroll,
        padding: const EdgeInsets.fromLTRB(
            Jarak.layarH, Jarak.lg, Jarak.layarH, 24),
        children: [
          if (adaMeta) ...[
            Text(
              [
                if (konten.berlakuSejak != null)
                  '${t.berlakuSejak} $tanggalTeks',
                if (konten.versi != null) '${t.versiLabel} ${konten.versi}',
              ].join(' · '),
              style: context.teks.labelSmall?.copyWith(
                color: Warna.teksKetiga,
                letterSpacing: 0.2,
                height: 1.4,
              ),
            ),
            const SizedBox(height: Jarak.md),
            const Divider(height: 1, color: Warna.pemisah),
            const SizedBox(height: Jarak.lg),
          ],
          for (var i = 0; i < konten.pasal.length; i++) ...[
            _BagianPasal(pasal: konten.pasal[i]),
            if (i < konten.pasal.length - 1) const SizedBox(height: Jarak.lg),
          ],
        ],
      ),
    );
  }

  Widget _galat(BuildContext context, Teks t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Jarak.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              HugeIcons.strokeRoundedAlert02,
              color: Warna.teksKetiga,
              size: 40,
            ),
            const SizedBox(height: Jarak.md),
            Text(
              t.gagalMemuatKebijakan,
              textAlign: TextAlign.center,
              style: context.teks.bodyMedium?.copyWith(color: Warna.teksKedua),
            ),
            const SizedBox(height: Jarak.lg),
            OutlinedButton(
              onPressed: () =>
                  ref.invalidate(penyediaKontenKebijakan(widget.jenis)),
              child: Text(t.cobaLagi),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barPersetujuan(BuildContext context, Teks t) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: const BoxDecoration(
          color: Warna.permukaan,
          border: Border(top: BorderSide(color: Warna.pemisah, width: 1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_sudahDibaca)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(
                      HugeIcons.strokeRoundedArrowDown01,
                      color: Warna.teksKedua,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.gulirSampaiAkhir,
                        style: context.teks.labelSmall?.copyWith(
                          color: Warna.teksKedua,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => context.pop(false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Warna.garisTegas, width: 1.2),
                        foregroundColor: Warna.teksUtama,
                        shape: const StadiumBorder(),
                        textStyle:
                            const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      child: Text(t.kembali),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed:
                          _sudahDibaca ? () => context.pop(true) : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: Warna.primer,
                        disabledBackgroundColor: Warna.netral200,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(t.sayaMengertiDanSetuju),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BagianPasal extends StatelessWidget {
  const _BagianPasal({required this.pasal});
  final Pasal pasal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pasal.judul.isNotEmpty) ...[
          Text(
            pasal.judul,
            style: context.teks.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Text(
          pasal.isi,
          style: context.teks.bodyMedium?.copyWith(
            color: Warna.teksKedua,
            height: 1.62,
          ),
        ),
      ],
    );
  }
}
