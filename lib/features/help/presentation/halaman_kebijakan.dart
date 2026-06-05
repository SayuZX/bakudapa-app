import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/extensions/konteks.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/providers/penyedia_bahasa.dart';
import '../data/katalog_kebijakan.dart';

export '../data/katalog_kebijakan.dart' show JenisKebijakan;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _periksaScroll();
    });
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
    final bahasa = ref.watch(penyediaBahasa);
    final isi = KatalogKebijakan.ambil(widget.jenis, bahasa);

    return Scaffold(
      backgroundColor: Warna.permukaan,
      appBar: AppBar(
        title: Text(isi.judul),
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
            child: Scrollbar(
              controller: _kontrolerScroll,
              thumbVisibility: true,
              child: ListView(
                controller: _kontrolerScroll,
                padding: const EdgeInsets.fromLTRB(
                    Jarak.layarH, Jarak.lg, Jarak.layarH, 24),
                children: [
                  Text(
                    '${isi.terakhirDiperbaruiPrefix} ${isi.berlakuSejak} · ${isi.versiPrefix} ${isi.versi}',
                    style: context.teks.labelSmall?.copyWith(
                      color: Warna.teksKetiga,
                      letterSpacing: 0.2,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: Jarak.md),
                  const Divider(height: 1, color: Warna.pemisah),
                  const SizedBox(height: Jarak.lg),
                  for (var i = 0; i < isi.pasal.length; i++) ...[
                    _BagianPasal(pasal: isi.pasal[i]),
                    if (i < isi.pasal.length - 1)
                      const SizedBox(height: Jarak.lg),
                  ],
                  const SizedBox(height: Jarak.xxl),
                  Text(
                    isi.hubungiTeks.replaceFirst('{kontak}', isi.kontak),
                    style: context.teks.bodySmall?.copyWith(
                      color: Warna.teksKetiga,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.modePersetujuan)
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  color: Warna.permukaan,
                  border: Border(
                    top: BorderSide(color: Warna.pemisah, width: 1),
                  ),
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
                                isi.gulirSampaiAkhir,
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
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                              child: Text(isi.kembali),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: _sudahDibaca
                                  ? () => context.pop(true)
                                  : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: Warna.merahUtama,
                                disabledBackgroundColor: Warna.netral200,
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: Text(isi.sayaMengertiDanSetuju),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
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
        Text(
          pasal.judul,
          style: context.teks.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 6),
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
