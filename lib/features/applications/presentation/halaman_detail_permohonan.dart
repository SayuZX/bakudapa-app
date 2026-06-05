import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/errors/kesalahan.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../core/utils/format.dart';
import '../../../shared/models/permohonan.dart';
import '../../../shared/models/status_permohonan.dart';
import '../../../shared/providers/penyedia_permohonan.dart';
import '../../../shared/providers/penyedia_repositori.dart';
import '../../../shared/widgets/kondisi_galat.dart';
import '../../../shared/widgets/lencana_status.dart';
import '../../../shared/widgets/pemuat_kerlip.dart';
import '../../../shared/widgets/tombol_utama.dart';
import 'widgets/lini_status.dart';
import 'widgets/progres_permohonan.dart';

class HalamanDetailPermohonan extends ConsumerWidget {
  const HalamanDetailPermohonan({super.key, required this.id});
  final String id;

  Future<void> _unduhDokumen(BuildContext context, WidgetRef ref) async {
    try {
      final url = await ref.read(penyediaRepositoriPermohonan).unduhDokumenHasil(id);
      if (url.isEmpty) {
        if (!context.mounted) return;
        context.tampilkanPesan('Dokumen belum tersedia.', galat: true);
        return;
      }
      await OpenFilex.open(url);
    } on Kesalahan catch (e) {
      if (!context.mounted) return;
      context.tampilkanPesan(e.pesan, galat: true);
    } catch (_) {
      if (!context.mounted) return;
      context.tampilkanPesan('Gagal membuka dokumen.', galat: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(penyediaDetailPermohonan(id));
    final t = ref.watch(teksProvider);

    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(title: Text(t.detailPermohonan)),
      body: SafeArea(
        top: false,
        child: detail.when(
          loading: () => const DaftarKerangka(jumlah: 3),
          error: (e, _) => KondisiGalat(
            pesan: pesanRamah(e, fallback: t.terjadiKesalahan),
            saatCobaLagi: () => ref.invalidate(penyediaDetailPermohonan(id)),
          ),
          data: (p) => _Isi(permohonan: p, saatUnduh: () => _unduhDokumen(context, ref)),
        ),
      ),
    );
  }
}

class _Isi extends StatelessWidget {
  const _Isi({required this.permohonan, required this.saatUnduh});
  final Permohonan permohonan;
  final VoidCallback saatUnduh;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(Jarak.layarH, Jarak.md, Jarak.layarH, Jarak.xxl),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(Jarak.lg, Jarak.xl, Jarak.lg, Jarak.lg),
          decoration: BoxDecoration(
            color: Warna.permukaan,
            border: Border.all(color: Warna.garis),
            borderRadius: BorderRadius.circular(Sudut.lg),
          ),
          child: ProgresPermohonan(permohonan: permohonan),
        ),
        const SizedBox(height: Jarak.lg),
        Container(
          padding: const EdgeInsets.all(Jarak.lg),
          decoration: BoxDecoration(
            color: Warna.permukaan,
            border: Border.all(color: Warna.garis),
            borderRadius: BorderRadius.circular(Sudut.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(permohonan.jenis.ikon, color: Warna.merahUtama, size: 26),
                  const SizedBox(width: Jarak.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(permohonan.jenis.nama, style: context.teks.titleMedium),
                        Text(
                          permohonan.kodeReferensi,
                          style: context.teks.bodySmall?.copyWith(color: Warna.teksKedua),
                        ),
                      ],
                    ),
                  ),
                  LencanaStatus(status: permohonan.status),
                ],
              ),
              const SizedBox(height: Jarak.md),
              const Divider(),
              _Ringkas(label: 'Diajukan', nilai: Format.tanggalJam(permohonan.diajukanPada)),
              if (permohonan.diperbaruiPada != null)
                _Ringkas(label: 'Diperbarui', nilai: Format.tanggalJam(permohonan.diperbaruiPada!)),
              if (permohonan.catatan != null && permohonan.catatan!.isNotEmpty)
                _Ringkas(label: 'Catatan', nilai: permohonan.catatan!),
            ],
          ),
        ),
        const SizedBox(height: Jarak.xl),
        Text('Lini Masa', style: context.teks.titleMedium),
        const SizedBox(height: Jarak.md),
        Container(
          padding: const EdgeInsets.all(Jarak.lg),
          decoration: BoxDecoration(
            color: Warna.permukaan,
            border: Border.all(color: Warna.garis),
            borderRadius: BorderRadius.circular(Sudut.lg),
          ),
          child: LiniStatus(permohonan: permohonan),
        ),
        if (permohonan.status == StatusPermohonan.selesai) ...[
          const SizedBox(height: Jarak.xl),
          TombolUtama(
            label: 'Unduh Dokumen Hasil',
            ikon: const Icon(HugeIcons.strokeRoundedDownload01, color: Colors.white, size: 18),
            saatTekan: saatUnduh,
          ),
        ],
      ],
    );
  }
}

class _Ringkas extends StatelessWidget {
  const _Ringkas({required this.label, required this.nilai});
  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: context.teks.bodySmall?.copyWith(color: Warna.teksKedua),
            ),
          ),
          Expanded(child: Text(nilai, style: context.teks.bodyMedium)),
        ],
      ),
    );
  }
}
