import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/errors/kesalahan.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/router/navigasi_aman.dart';
import '../../../core/storage/berkas_sementara.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/models/jenis_layanan.dart';
import '../../../shared/widgets/kondisi_galat.dart';
import '../../../shared/widgets/kotak_centang_setuju.dart';
import '../../../shared/widgets/pemuat_lingkar.dart';
import '../../../shared/widgets/tombol_utama.dart';
import '../domain/detail_layanan.dart';
import '../providers/penyedia_layanan.dart';

class HalamanAwalPermohonan extends ConsumerStatefulWidget {
  const HalamanAwalPermohonan({super.key, required this.ringkasan});

  final RingkasanLayanan ringkasan;

  @override
  ConsumerState<HalamanAwalPermohonan> createState() =>
      _HalamanAwalPermohonanState();
}

class _HalamanAwalPermohonanState extends ConsumerState<HalamanAwalPermohonan> {
  bool _setuju = false;

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);
    final detail = ref.watch(penyediaDetailLayanan(widget.ringkasan.kode));

    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(title: Text(t.katalog(widget.ringkasan.namaSingkat))),
      body: detail.when(
        loading: () => PemuatLingkar(pesan: t.mohonTungguSebentar),
        error: (e, _) => KondisiGalat(
          pesan: pesanRamah(e, fallback: t.terjadiKesalahan, teks: t),
          saatCobaLagi: () =>
              ref.invalidate(penyediaDetailLayanan(widget.ringkasan.kode)),
        ),
        data: (layanan) => _Isi(
          teks: t,
          ringkasan: widget.ringkasan,
          layanan: layanan,
          setuju: _setuju,
          saatSetuju: (v) => setState(() => _setuju = v),
        ),
      ),
    );
  }
}

class _Isi extends StatelessWidget {
  const _Isi({
    required this.teks,
    required this.ringkasan,
    required this.layanan,
    required this.setuju,
    required this.saatSetuju,
  });

  final Teks teks;
  final RingkasanLayanan ringkasan;
  final DetailLayanan layanan;
  final bool setuju;
  final ValueChanged<bool> saatSetuju;

  @override
  Widget build(BuildContext context) {
    final t = teks;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        Jarak.layarH,
        Jarak.sm,
        Jarak.layarH,
        Jarak.xxxl,
      ),
      children: [
        _KepalaLayanan(
          teks: t,
          ringkasan: ringkasan,
          layanan: layanan,
          estimasiMenit: layanan.estimasiMenit,
        ).animate().fadeIn(duration: 280.ms, curve: Curves.easeOutCubic),
        if (layanan.urlFormulirPdf != null ||
            layanan.formulirPdf.isNotEmpty) ...[
          const SizedBox(height: Jarak.xxl),
          _JudulSeksi(
            ikon: HugeIcons.strokeRoundedPdf02,
            judul: t.formulirResmi,
            keterangan: t.formulirResmiSub,
          ),
          const SizedBox(height: Jarak.md),
          if (layanan.urlFormulirPdf != null)
            _TombolUnduhPdf(url: layanan.urlFormulirPdf!, teks: t)
          else
            Container(
              decoration: BoxDecoration(
                color: Warna.permukaan,
                borderRadius: BorderRadius.circular(Sudut.lg),
                border: Border.all(color: Warna.garis),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < layanan.formulirPdf.length; i++) ...[
                    if (i > 0) const Divider(indent: 64, color: Warna.pemisah),
                    _BarisPdf(nama: layanan.formulirPdf[i].nama),
                  ],
                ],
              ),
            ),
        ],
        const SizedBox(height: Jarak.xxl),
        _JudulSeksi(
          ikon: HugeIcons.strokeRoundedCheckList,
          judul: t.persyaratanDokumen,
          keterangan: t.persyaratanDokumenSub,
        ),
        const SizedBox(height: Jarak.md),
        Container(
          padding: const EdgeInsets.all(Jarak.lg),
          decoration: BoxDecoration(
            color: Warna.permukaan,
            borderRadius: BorderRadius.circular(Sudut.lg),
            border: Border.all(color: Warna.garis),
          ),
          child: Column(
            children: [
              for (final (i, syarat)
                  in t.daftarKatalog(layanan.persyaratanTeks).indexed) ...[
                if (i > 0) const SizedBox(height: Jarak.md),
                _BarisSyarat(nomor: i + 1, teks: syarat),
              ],
            ],
          ),
        ),
        if (layanan.langkahPanduan.isNotEmpty) ...[
          const SizedBox(height: Jarak.xxl),
          _JudulSeksi(
            ikon: HugeIcons.strokeRoundedInformationCircle,
            judul: t.langkahPanduanJudul,
            keterangan: t.langkahPanduanSub,
          ),
          const SizedBox(height: Jarak.md),
          Container(
            padding: const EdgeInsets.all(Jarak.lg),
            decoration: BoxDecoration(
              color: Warna.permukaan,
              borderRadius: BorderRadius.circular(Sudut.lg),
              border: Border.all(color: Warna.garis),
            ),
            child: Column(
              children: [
                for (final (i, langkah)
                    in t.daftarKatalog(layanan.langkahPanduan).indexed) ...[
                  if (i > 0) const SizedBox(height: Jarak.md),
                  _BarisSyarat(nomor: i + 1, teks: langkah),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: Jarak.xxl),
        Container(
          padding: const EdgeInsets.all(Jarak.lg),
          decoration: BoxDecoration(
            color: Warna.permukaan,
            borderRadius: BorderRadius.circular(Sudut.lg),
            border: Border.all(color: Warna.garis),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KotakCentangSetuju(
                nilai: setuju,
                saatBerubah: saatSetuju,
                label: t.persetujuanPermohonan,
              ),
              const SizedBox(height: Jarak.xs),
              Padding(
                padding: const EdgeInsets.only(left: 34),
                child: Wrap(
                  spacing: Jarak.lg,
                  children: [
                    _TautKebijakan(
                      label: t.ketentuanLayananTaut,
                      saatKetuk: () =>
                          context.pushAman(NamaRute.kebijakanLayanan),
                    ),
                    _TautKebijakan(
                      label: t.kebijakanPrivasi,
                      saatKetuk: () =>
                          context.pushAman(NamaRute.kebijakanPrivasi),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Jarak.xxl),
        TombolUtama(
          label: t.mulaiPermohonan,
          saatTekan: setuju
              ? () => context.pushAman(NamaRute.formulir, extra: ringkasan)
              : null,
        ),
      ],
    );
  }
}

class _TombolUnduhPdf extends ConsumerStatefulWidget {
  const _TombolUnduhPdf({required this.url, required this.teks});

  final String url;
  final Teks teks;

  @override
  ConsumerState<_TombolUnduhPdf> createState() => _TombolUnduhPdfState();
}

class _TombolUnduhPdfState extends ConsumerState<_TombolUnduhPdf> {
  bool _sibuk = false;

  Future<void> _unduh() async {
    if (_sibuk) return;
    setState(() => _sibuk = true);
    try {
      final pisah = widget.url.contains('?') ? '&' : '?';
      final url = '${widget.url}${pisah}download=1';
      final namaDasar =
          Uri.tryParse(widget.url)?.pathSegments.lastOrNull ?? 'formulir.pdf';
      final aman = namaDasar.replaceAll(RegExp(r'[^\w.\- ]'), '_');
      final nama = aman.toLowerCase().endsWith('.pdf') ? aman : '$aman.pdf';
      final tujuan = await BerkasSementara.instance.jalurBaru(nama);
      await Dio().download(
        url,
        tujuan,
        options: Options(
          receiveTimeout: const Duration(minutes: 2),
          validateStatus: (s) => s == 200,
        ),
      );
      await OpenFilex.open(tujuan);
    } catch (_) {
      if (mounted) context.tampilkanGalat(widget.teks.gagalUnduhFormulir);
    } finally {
      if (mounted) setState(() => _sibuk = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Warna.permukaan,
        borderRadius: BorderRadius.circular(Sudut.lg),
        border: Border.all(color: Warna.garis),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _sibuk ? null : _unduh,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Jarak.lg,
            vertical: Jarak.md,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Warna.bahayaLembut,
                  borderRadius: BorderRadius.circular(Sudut.sm),
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedPdf02,
                  size: 18,
                  color: Warna.bahaya,
                ),
              ),
              const SizedBox(width: Jarak.md),
              Expanded(
                child: Text(
                  widget.teks.unduhFormulirPdf,
                  style: context.teks.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _sibuk
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : const Icon(
                      Icons.file_download_outlined,
                      size: 20,
                      color: Warna.primer,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KepalaLayanan extends StatelessWidget {
  const _KepalaLayanan({
    required this.teks,
    required this.ringkasan,
    required this.layanan,
    required this.estimasiMenit,
  });

  final Teks teks;
  final RingkasanLayanan ringkasan;
  final DetailLayanan layanan;
  final int estimasiMenit;

  @override
  Widget build(BuildContext context) {
    final nama = layanan.nama.isNotEmpty ? layanan.nama : ringkasan.nama;
    final deskripsi = (layanan.deskripsi?.isNotEmpty ?? false)
        ? layanan.deskripsi!
        : ringkasan.deskripsiTampil;
    return Container(
      padding: const EdgeInsets.all(Jarak.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Warna.primer, Warna.primerGelap],
        ),
        borderRadius: BorderRadius.circular(Sudut.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(Sudut.md),
                ),
                child: Icon(ringkasan.ikon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: Jarak.lg),
              Expanded(
                child: Text(
                  teks.katalog(nama),
                  style: context.teks.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Jarak.md),
          Text(
            teks.katalog(deskripsi),
            style: context.teks.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: Jarak.md),
          Row(
            children: [
              const Icon(
                HugeIcons.strokeRoundedClock01,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                teks.estimasiPengisian(estimasiMenit),
                style: context.teks.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JudulSeksi extends StatelessWidget {
  const _JudulSeksi({
    required this.ikon,
    required this.judul,
    required this.keterangan,
  });

  final IconData ikon;
  final String judul;
  final String keterangan;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(ikon, size: 18, color: Warna.primer),
        const SizedBox(width: Jarak.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                judul,
                style: context.teks.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                keterangan,
                style: context.teks.bodySmall?.copyWith(
                  color: Warna.teksKetiga,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BarisPdf extends StatelessWidget {
  const _BarisPdf({required this.nama});

  final String nama;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Jarak.lg,
        vertical: Jarak.md,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Warna.bahayaLembut,
              borderRadius: BorderRadius.circular(Sudut.sm),
            ),
            child: const Icon(
              HugeIcons.strokeRoundedPdf02,
              size: 18,
              color: Warna.bahaya,
            ),
          ),
          const SizedBox(width: Jarak.md),
          Expanded(
            child: Text(
              nama,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.teks.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarisSyarat extends StatelessWidget {
  const _BarisSyarat({required this.nomor, required this.teks});

  final int nomor;
  final String teks;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Warna.primerLembut,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$nomor',
            style: context.teks.labelSmall?.copyWith(
              color: Warna.primerGelap,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: Jarak.md),
        Expanded(
          child: Text(
            teks,
            style: context.teks.bodyMedium?.copyWith(height: 1.45),
          ),
        ),
      ],
    );
  }
}

class _TautKebijakan extends StatelessWidget {
  const _TautKebijakan({required this.label, required this.saatKetuk});

  final String label;
  final VoidCallback saatKetuk;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: saatKetuk,
      child: Text(
        label,
        style: context.teks.bodySmall?.copyWith(
          color: Warna.info,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
