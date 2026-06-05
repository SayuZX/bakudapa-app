import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/models/jenis_layanan.dart';
import '../../../shared/providers/penyedia_otentikasi.dart';
import '../../../shared/widgets/tombol_utama.dart';
import '../domain/definisi_formulir.dart';

class HalamanDetailLayanan extends ConsumerWidget {
  const HalamanDetailLayanan({super.key, required this.jenis});
  final JenisLayanan jenis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formulir = KatalogFormulir.untuk(jenis);
    final t = ref.watch(teksProvider);
    final terverifikasi =
        ref.watch(penyediaOtentikasi).pengguna?.terverifikasi ?? false;

    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(title: Text(jenis.nama)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Jarak.layarH, Jarak.md, Jarak.layarH, 120),
          children: [
            Container(
              padding: const EdgeInsets.all(Jarak.lg),
              decoration: BoxDecoration(
                color: Warna.permukaan,
                border: Border.all(color: Warna.garis),
                borderRadius: BorderRadius.circular(Sudut.lg),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Warna.merahLembut,
                      borderRadius: BorderRadius.circular(Sudut.md),
                    ),
                    child: Icon(jenis.ikon, color: Warna.merahUtama, size: 26),
                  ),
                  const SizedBox(width: Jarak.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(jenis.nama, style: context.teks.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          jenis.deskripsi,
                          style: context.teks.bodySmall?.copyWith(color: Warna.teksKedua),
                        ),
                        const SizedBox(height: Jarak.sm),
                        _LencanaKetersediaan(bisaOnline: jenis.bisaOnline, t: t),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Jarak.xl),
            Text(t.langkahPengajuan, style: context.teks.titleMedium),
            const SizedBox(height: Jarak.md),
            for (var i = 0; i < formulir.langkahPanduan.length; i++) ...[
              _Langkah(nomor: i + 1, teks: formulir.langkahPanduan[i]),
              const SizedBox(height: Jarak.sm),
            ],
            const SizedBox(height: Jarak.lg),
            Text(t.dokumenDisiapkan, style: context.teks.titleMedium),
            const SizedBox(height: Jarak.md),
            for (final b in formulir.berkas) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(HugeIcons.strokeRoundedFileAttachment,
                      size: 18, color: Warna.teksKedua),
                  const SizedBox(width: Jarak.sm),
                  Expanded(
                    child: Text(
                      '${b.label}${b.wajib ? '' : ' (${t.opsional})'}',
                      style: context.teks.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Jarak.sm),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Jarak.layarH),
          child: _AksiPengajuan(
            jenis: jenis,
            terverifikasi: terverifikasi,
            t: t,
          ),
        ),
      ),
    );
  }
}

class _LencanaKetersediaan extends StatelessWidget {
  const _LencanaKetersediaan({required this.bisaOnline, required this.t});
  final bool bisaOnline;
  final Teks t;

  @override
  Widget build(BuildContext context) {
    final warna = bisaOnline ? Warna.sukses : Warna.peringatan;
    final latar = bisaOnline ? Warna.suksesLembut : Warna.peringatanLembut;
    final ikon =
        bisaOnline ? HugeIcons.strokeRoundedGlobe : HugeIcons.strokeRoundedStore01;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: latar,
        borderRadius: BorderRadius.circular(Sudut.pil),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, color: warna, size: 13),
          const SizedBox(width: 5),
          Text(
            bisaOnline ? t.tersediaOnline : t.layananLoket,
            style: context.teks.labelSmall
                ?.copyWith(color: warna, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _AksiPengajuan extends StatelessWidget {
  const _AksiPengajuan({
    required this.jenis,
    required this.terverifikasi,
    required this.t,
  });

  final JenisLayanan jenis;
  final bool terverifikasi;
  final Teks t;

  @override
  Widget build(BuildContext context) {
    if (!jenis.bisaOnline) {
      return _Panel(
        ikon: HugeIcons.strokeRoundedStore01,
        warna: Warna.peringatan,
        latar: Warna.peringatanLembut,
        pesan: t.layananBelumOnlinePesan,
      );
    }
    if (!terverifikasi) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Panel(
            ikon: HugeIcons.strokeRoundedAlert02,
            warna: Warna.bahaya,
            latar: Warna.bahayaLembut,
            pesan: t.perluVerifikasiPesan,
          ),
          const SizedBox(height: Jarak.md),
          TombolUtama(
            label: t.verifikasiAkun,
            saatTekan: () => context.push(NamaRute.profil),
          ),
        ],
      );
    }
    return TombolUtama(
      label: t.ajukanSekarang,
      saatTekan: () => context.push('${NamaRute.formulir}/${jenis.kode}'),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.ikon,
    required this.warna,
    required this.latar,
    required this.pesan,
  });

  final IconData ikon;
  final Color warna;
  final Color latar;
  final String pesan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Jarak.md),
      decoration: BoxDecoration(
        color: latar,
        borderRadius: BorderRadius.circular(Sudut.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: warna, size: 20),
          const SizedBox(width: Jarak.sm),
          Expanded(
            child: Text(
              pesan,
              style: context.teks.bodySmall?.copyWith(color: warna),
            ),
          ),
        ],
      ),
    );
  }
}

class _Langkah extends StatelessWidget {
  const _Langkah({required this.nomor, required this.teks});
  final int nomor;
  final String teks;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Warna.merahUtama,
            borderRadius: BorderRadius.circular(Sudut.pil),
          ),
          alignment: Alignment.center,
          child: Text(
            '$nomor',
            style: context.teks.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: Jarak.sm),
        Expanded(child: Text(teks, style: context.teks.bodyMedium)),
      ],
    );
  }
}
