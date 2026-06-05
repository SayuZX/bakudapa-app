import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/ai/model_ai_chat.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/providers/penyedia_ai_chat.dart';

class HalamanAiChat extends ConsumerStatefulWidget {
  const HalamanAiChat({super.key});

  @override
  ConsumerState<HalamanAiChat> createState() => _HalamanAiChatState();
}

class _HalamanAiChatState extends ConsumerState<HalamanAiChat> {
  final _pengaturInput = TextEditingController();
  final _pengaturGulir = ScrollController();

  @override
  void dispose() {
    _pengaturInput.dispose();
    _pengaturGulir.dispose();
    super.dispose();
  }

  void _gulirKeBawah() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pengaturGulir.hasClients) {
        _pengaturGulir.animateTo(
          _pengaturGulir.position.maxScrollExtent,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _kirim() async {
    final teks = _pengaturInput.text.trim();
    if (teks.isEmpty) return;
    _pengaturInput.clear();
    await ref.read(penyediaAiChat.notifier).kirim(teks);
    _gulirKeBawah();
  }

  Future<void> _saran(String teks) async {
    await ref.read(penyediaAiChat.notifier).kirim(teks);
    _gulirKeBawah();
  }

  Future<void> _lanjutkan() async {
    await ref.read(penyediaAiChat.notifier).lanjutkan();
    _gulirKeBawah();
  }

  void _jalankanAksi(AksiAi aksi) {
    final target = aksi.target;
    switch (aksi.tipe) {
      case TipeAksiAi.bukaLayanan:
        if (target != null && target.isNotEmpty) {
          context.push('${NamaRute.detailLayanan}/$target');
        } else {
          context.push(NamaRute.layanan);
        }
      case TipeAksiAi.lihatStatus:
        if (target != null && target.isNotEmpty) {
          context.push('${NamaRute.detailPermohonan}/$target');
        } else {
          context.go(NamaRute.riwayat);
        }
      case TipeAksiAi.lihatPermohonan:
        context.go(NamaRute.riwayat);
      case TipeAksiAi.mulaiPengaduan:
      case TipeAksiAi.bukaFaq:
      case TipeAksiAi.hubungiOperator:
        context.push(NamaRute.bantuan);
      case TipeAksiAi.takDikenal:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final kondisi = ref.watch(penyediaAiChat);
    final t = ref.watch(teksProvider);
    final balasanTerakhir = kondisi.pesan.isNotEmpty ? kondisi.pesan.last : null;
    final perluLanjutkan = balasanTerakhir != null &&
        balasanTerakhir.peran == PeranPesanAi.asisten &&
        !balasanTerakhir.selesai &&
        !kondisi.memuat;

    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(
        title: Text(t.asistenAi),
        actions: [
          if (kondisi.pesan.isNotEmpty)
            IconButton(
              tooltip: t.mulaiSesiBaru,
              icon: const Icon(HugeIcons.strokeRoundedRefresh),
              onPressed: () =>
                  ref.read(penyediaAiChat.notifier).mulaiSesiBaru(),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _BilahDisclaimer(teks: t.disclaimerAi),
            Expanded(
              child: kondisi.pesan.isEmpty
                  ? _Sambutan(teks: t, saatSaran: _saran)
                  : ListView.builder(
                      controller: _pengaturGulir,
                      padding: const EdgeInsets.fromLTRB(
                          Jarak.layarH, Jarak.lg, Jarak.layarH, Jarak.lg),
                      itemCount: kondisi.pesan.length,
                      itemBuilder: (_, i) => _GelembungPesan(
                        pesan: kondisi.pesan[i],
                        labelOperator: t.hubungiDisdukcapil,
                        saatAksi: _jalankanAksi,
                        saatOperator: () => context.push(NamaRute.bantuan),
                      ),
                    ),
            ),
            if (kondisi.memuat) const _IndikatorMengetik(),
            if (perluLanjutkan)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    Jarak.layarH, 0, Jarak.layarH, Jarak.sm),
                child: OutlinedButton.icon(
                  onPressed: _lanjutkan,
                  icon: const Icon(HugeIcons.strokeRoundedArrowDown01, size: 16),
                  label: Text(t.lanjutkanAi),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                    foregroundColor: Warna.merahUtama,
                    side: const BorderSide(color: Warna.merahUtama, width: 1.2),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            _BilahInput(
              pengatur: _pengaturInput,
              memuat: kondisi.memuat,
              tidakTersedia: kondisi.tidakTersedia,
              saatKirim: _kirim,
              placeholder: t.ketikPertanyaan,
            ),
          ],
        ),
      ),
    );
  }
}

class _BilahDisclaimer extends StatelessWidget {
  const _BilahDisclaimer({required this.teks});
  final String teks;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Warna.netral100,
      padding: const EdgeInsets.symmetric(
          horizontal: Jarak.layarH, vertical: Jarak.sm),
      child: Row(
        children: [
          const Icon(HugeIcons.strokeRoundedInformationCircle,
              size: 14, color: Warna.teksKetiga),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              teks,
              style: context.teks.labelSmall?.copyWith(color: Warna.teksKedua),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sambutan extends StatelessWidget {
  const _Sambutan({required this.teks, required this.saatSaran});
  final Teks teks;
  final ValueChanged<String> saatSaran;

  @override
  Widget build(BuildContext context) {
    final saran = [
      teks.saranStatusPermohonan,
      teks.saranSyaratKk,
      teks.saranApaItuKia,
      teks.saranPindahDomisili,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Jarak.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Warna.merahLembut,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Icon(HugeIcons.strokeRoundedAiChat02,
                  color: Warna.merahUtama, size: 32),
            ),
            const SizedBox(height: Jarak.lg),
            Text(
              teks.asistenAi,
              textAlign: TextAlign.center,
              style: context.teks.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
            ),
            const SizedBox(height: 6),
            Text(
              teks.sapaanAi,
              textAlign: TextAlign.center,
              style: context.teks.bodyMedium
                  ?.copyWith(color: Warna.teksKedua, height: 1.55),
            ),
            const SizedBox(height: Jarak.xl),
            Text(
              teks.cobaTanya,
              style: context.teks.labelMedium?.copyWith(
                color: Warna.teksKetiga,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Jarak.sm),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: Jarak.sm,
              runSpacing: Jarak.sm,
              children: [
                for (final s in saran)
                  _ChipSaran(label: s, saatKetuk: () => saatSaran(s)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipSaran extends StatelessWidget {
  const _ChipSaran({required this.label, required this.saatKetuk});
  final String label;
  final VoidCallback saatKetuk;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Warna.permukaan,
      shape: StadiumBorder(side: const BorderSide(color: Warna.garis)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: saatKetuk,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(
            label,
            style: context.teks.bodySmall
                ?.copyWith(color: Warna.teksUtama, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _GelembungPesan extends StatelessWidget {
  const _GelembungPesan({
    required this.pesan,
    required this.labelOperator,
    required this.saatAksi,
    required this.saatOperator,
  });

  final PesanAi pesan;
  final String labelOperator;
  final ValueChanged<AksiAi> saatAksi;
  final VoidCallback saatOperator;

  bool get _dariPengguna => pesan.peran == PeranPesanAi.pengguna;

  @override
  Widget build(BuildContext context) {
    final align = _dariPengguna ? Alignment.centerRight : Alignment.centerLeft;
    final warnaLatar = _dariPengguna
        ? Warna.merahUtama
        : (pesan.terjadiGalat ? Warna.peringatanLembut : Warna.permukaan);
    final warnaTeks = _dariPengguna ? Colors.white : Warna.teksUtama;
    final borderRadius = _dariPengguna
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          );

    final aksiTampil =
        pesan.aksi.where((a) => a.tipe != TipeAksiAi.takDikenal).toList();

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: Column(
          crossAxisAlignment: _dariPengguna
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            RepaintBoundary(
              child: Container(
                margin: const EdgeInsets.only(bottom: Jarak.sm),
                padding: const EdgeInsets.symmetric(
                    horizontal: Jarak.md, vertical: Jarak.sm),
                decoration: BoxDecoration(
                  color: warnaLatar,
                  borderRadius: borderRadius,
                  border: _dariPengguna
                      ? null
                      : Border.all(color: Warna.garis, width: 1),
                ),
                child: _dariPengguna
                    ? Text(
                        pesan.isi,
                        style: context.teks.bodyMedium
                            ?.copyWith(color: warnaTeks, height: 1.5),
                      )
                    : MarkdownBody(
                        data: pesan.isi,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet.fromTheme(
                          Theme.of(context),
                        ).copyWith(
                          p: context.teks.bodyMedium
                              ?.copyWith(color: warnaTeks, height: 1.55),
                          strong: context.teks.bodyMedium?.copyWith(
                            color: warnaTeks,
                            fontWeight: FontWeight.w700,
                          ),
                          listBullet: context.teks.bodyMedium
                              ?.copyWith(color: warnaTeks, height: 1.5),
                          h1: context.teks.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                          h2: context.teks.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                          h3: context.teks.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                          code: context.teks.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: Warna.teksUtama,
                            backgroundColor: Warna.netral100,
                          ),
                        ),
                      ),
              ),
            ),
            if (!_dariPengguna && aksiTampil.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: Jarak.sm),
                child: Wrap(
                  spacing: Jarak.sm,
                  runSpacing: Jarak.sm,
                  children: [
                    for (final a in aksiTampil)
                      _TombolAksi(
                        label: a.label,
                        saatKetuk: () => saatAksi(a),
                      ),
                  ],
                ),
              ),
            if (!_dariPengguna && pesan.butuhOperator)
              Padding(
                padding: const EdgeInsets.only(bottom: Jarak.sm),
                child: _TombolAksi(
                  label: labelOperator,
                  ikon: HugeIcons.strokeRoundedHelpCircle,
                  saatKetuk: saatOperator,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TombolAksi extends StatelessWidget {
  const _TombolAksi({required this.label, required this.saatKetuk, this.ikon});
  final String label;
  final VoidCallback saatKetuk;
  final IconData? ikon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: saatKetuk,
      style: OutlinedButton.styleFrom(
        foregroundColor: Warna.merahUtama,
        side: const BorderSide(color: Warna.merahUtama, width: 1.2),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        minimumSize: const Size(0, 38),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ikon != null) ...[
            Icon(ikon, size: 16),
            const SizedBox(width: 6),
          ],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _IndikatorMengetik extends StatelessWidget {
  const _IndikatorMengetik();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Jarak.layarH, 0, Jarak.layarH, Jarak.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Warna.merahUtama,
            ),
          ),
          const SizedBox(width: 10),
          Consumer(
            builder: (context, ref, _) => Text(
              ref.watch(teksProvider).asistenMengetik,
              style:
                  context.teks.labelMedium?.copyWith(color: Warna.teksKedua),
            ),
          ),
        ],
      ),
    );
  }
}

class _BilahInput extends StatelessWidget {
  const _BilahInput({
    required this.pengatur,
    required this.memuat,
    required this.tidakTersedia,
    required this.saatKirim,
    required this.placeholder,
  });

  final TextEditingController pengatur;
  final bool memuat;
  final bool tidakTersedia;
  final VoidCallback saatKirim;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final dapatKirim = !memuat && !tidakTersedia;
    return Container(
      padding:
          const EdgeInsets.fromLTRB(Jarak.layarH, Jarak.sm, Jarak.layarH, Jarak.sm),
      decoration: const BoxDecoration(
        color: Warna.permukaan,
        border: Border(top: BorderSide(color: Warna.pemisah, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: pengatur,
                minLines: 1,
                maxLines: 4,
                enabled: dapatKirim,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => saatKirim(),
                decoration: InputDecoration(
                  hintText: placeholder,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: Warna.garis),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: Warna.garis),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide:
                        const BorderSide(color: Warna.merahUtama, width: 1.4),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: Warna.netral25,
                ),
              ),
            ),
            const SizedBox(width: Jarak.sm),
            Material(
              color: dapatKirim ? Warna.merahUtama : Warna.netral200,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: dapatKirim ? saatKirim : null,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(HugeIcons.strokeRoundedSent,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
