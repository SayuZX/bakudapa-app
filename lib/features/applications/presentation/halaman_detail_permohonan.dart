import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/dialogs/dialog_aplikasi.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../core/utils/format.dart';
import '../../../shared/models/permohonan.dart';
import '../../../shared/models/status_permohonan.dart';
import '../../../shared/providers/penyedia_muat_global.dart';
import '../../../shared/providers/penyedia_pemberitahuan.dart';
import '../../../shared/providers/penyedia_permohonan.dart';
import '../../../shared/providers/penyedia_repositori.dart';
import '../../../shared/widgets/kondisi_galat.dart';
import '../../../shared/widgets/lencana_status.dart';
import '../../../shared/widgets/pemuat_lingkar.dart';
import '../../services/domain/detail_layanan.dart';
import '../../services/providers/penyedia_layanan.dart';
import '../domain/repositori_permohonan.dart';
import 'widgets/progres_permohonan.dart';

class HalamanDetailPermohonan extends ConsumerWidget {
  const HalamanDetailPermohonan({
    super.key,
    required this.kodeLayanan,
    required this.id,
  });

  final String kodeLayanan;
  final String id;

  Future<void> _unduhHasil(
    BuildContext context,
    WidgetRef ref,
    DokumenHasil dokumen,
  ) async {
    final t = ref.read(teksProvider);
    try {
      final repo = ref.read(penyediaRepositoriPermohonan);
      final jalur = await ref
          .read(penyediaMuatGlobal.notifier)
          .jalankan(
            () => repo.unduhDokumenHasil(id, dokumen),
            judul: t.mengunduhDokumen,
            pesan: t.mohonTungguSebentar,
          );
      if (!context.mounted) return;
      final hasil = await OpenFilex.open(jalur);
      if (hasil.type != ResultType.done && context.mounted) {
        context.tampilkanGalat(t.takAdaPembukaPdf);
      }
    } on Kesalahan catch (e) {
      if (context.mounted) context.tampilkanGalat(e.pesan);
    } catch (_) {
      if (context.mounted) context.tampilkanGalat(t.gagalUnduhDokumen);
    }
  }

  Future<void> _batalkan(BuildContext context, WidgetRef ref) async {
    final t = ref.read(teksProvider);
    final yakin = await DialogAplikasi.tampilkanKonfirmasi(
      context: context,
      judul: t.batalkanPermohonanJudul,
      pesan: t.batalkanPermohonanPesan,
      labelKonfirmasi: t.yaBatalkan,
      labelBatal: t.kembali,
      destruktif: true,
      nada: NadaDialog.bahaya,
    );
    if (!yakin || !context.mounted) return;
    try {
      await ref
          .read(penyediaMuatGlobal.notifier)
          .jalankan(
            () => ref.read(penyediaRepositoriPermohonan).batalkan(id),
            judul: t.batalkanPermohonanAksi,
          );
      if (!context.mounted) return;
      ref.invalidate(penyediaDetailPermohonan(id));
      ref.invalidate(penyediaPengaturRiwayat);
      ref.read(penyediaJumlahBelumDibaca.notifier).segarkan();
      context.tampilkanSukses(t.permohonanDibatalkan);
    } on Kesalahan catch (e) {
      if (context.mounted) context.tampilkanGalat(e.pesan);
    } catch (_) {
      if (context.mounted) {
        context.tampilkanGalat(t.gagalBatalkan);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final detail = ref.watch(penyediaDetailPermohonan(id));

    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(title: Text(t.detailPermohonan)),
      body: detail.when(
        loading: () => PemuatLingkar(pesan: t.memuatDetail),
        error: (e, _) => KondisiGalat(
          pesan: pesanRamah(e, fallback: t.gagalMuatDetail, teks: t),
          saatCobaLagi: () => ref.invalidate(penyediaDetailPermohonan(id)),
        ),
        data: (p) => _Isi(
          permohonan: p,
          kodeLayanan: kodeLayanan,
          saatUnduhHasil: (dokumen) => _unduhHasil(context, ref, dokumen),
          saatBatalkan: () => _batalkan(context, ref),
          saatSegarkan: () async {
            ref.invalidate(penyediaDetailPermohonan(id));
            ref.invalidate(penyediaDokumenHasil(id));
          },
        ),
      ),
    );
  }
}

class _Isi extends ConsumerWidget {
  const _Isi({
    required this.permohonan,
    required this.kodeLayanan,
    required this.saatUnduhHasil,
    required this.saatBatalkan,
    required this.saatSegarkan,
  });

  final Permohonan permohonan;
  final String kodeLayanan;
  final ValueChanged<DokumenHasil> saatUnduhHasil;
  final VoidCallback saatBatalkan;
  final Future<void> Function() saatSegarkan;

  static const _kunciTersembunyi = {
    'id',
    'kode_referensi',
    'nomor_permohonan',
    'application_number',
    'jenis_layanan',
    'nama_layanan',
    'service_type',
    'service_type_label',
    'service_type_slug',
    'progress_status',
    'status',
    'diajukan_pada',
    'diperbarui_pada',
    'diselesaikan_pada',
    'created_at',
    'updated_at',
    'created_by',
    'user_id',
    'deleted_at',
    'rejection_reason',
    'alasan_penolakan',
    'rejection_detail',
    'catatan',
    'notes',
    'data_formulir',
    'dokumen',
    'biodata_changes',
  };

  Map<String, String> _labelRuas(DetailLayanan? detail) {
    if (detail == null) return const {};
    return {
      for (final grup in detail.formulir)
        for (final ruas in grup.ruas) ruas.kunci: ruas.label,
    };
  }

  Map<String, dynamic> _dataFormulir() {
    final dataForm = permohonan.detail['data_formulir'];
    if (dataForm is Map) return Map<String, dynamic>.from(dataForm);
    return permohonan.detail;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final detailLayanan = ref.watch(penyediaDetailLayanan(kodeLayanan));
    final dokumenHasil = ref.watch(penyediaDokumenHasil(permohonan.id));
    final labelRuas = _labelRuas(
      detailLayanan.valueOrNull,
    ).map((kunci, label) => MapEntry(kunci, t.katalog(label)));

    return RefreshIndicator(
      color: Warna.primer,
      onRefresh: saatSegarkan,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(
          Jarak.layarH,
          Jarak.sm,
          Jarak.layarH,
          Jarak.xxxl,
        ),
        children: [
          _KartuKepala(
            permohonan: permohonan,
          ).animate().fadeIn(duration: 280.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: Jarak.lg),
          Container(
            padding: const EdgeInsets.all(Jarak.lg),
            decoration: BoxDecoration(
              color: Warna.permukaan,
              borderRadius: BorderRadius.circular(Sudut.lg),
              border: Border.all(color: Warna.garis),
            ),
            child: ProgresPermohonan(permohonan: permohonan),
          ),
          if (permohonan.status == StatusPermohonan.perluPerbaikan &&
              (permohonan.catatan ?? '').isNotEmpty) ...[
            const SizedBox(height: Jarak.lg),
            _CatatanPetugas(
              catatan: permohonan.catatan!,
              catatanLabel: t.catatanPetugas,
            ),
          ],
          const SizedBox(height: Jarak.lg),
          _DataPermohonan(
            detail: _dataFormulir(),
            labelRuas: labelRuas,
            tersembunyi: _kunciTersembunyi,
          ),
          if (permohonan.status == StatusPermohonan.selesai) ...[
            const SizedBox(height: Jarak.xxl),
            _DokumenHasil(
              dokumen: dokumenHasil,
              saatUnduh: saatUnduhHasil,
              saatCobaLagi: () =>
                  ref.invalidate(penyediaDokumenHasil(permohonan.id)),
            ),
          ],
          if (permohonan.status.bisaDibatalkan) ...[
            const SizedBox(height: Jarak.xl),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: saatBatalkan,
                style: TextButton.styleFrom(foregroundColor: Warna.bahaya),
                child: Text(t.batalkanPermohonanAksi),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KartuKepala extends ConsumerWidget {
  const _KartuKepala({required this.permohonan});

  final Permohonan permohonan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    return Container(
      padding: const EdgeInsets.all(Jarak.xl),
      decoration: BoxDecoration(
        color: Warna.permukaan,
        borderRadius: BorderRadius.circular(Sudut.lg),
        border: Border.all(color: Warna.garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.katalog(permohonan.namaLayanan),
                  style: context.teks.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              LencanaStatus(status: permohonan.status),
            ],
          ),
          const SizedBox(height: Jarak.lg),
          _BarisInfo(
            label: t.nomorPermohonan,
            nilai: permohonan.nomorPermohonan.isEmpty
                ? '—'
                : permohonan.nomorPermohonan,
            tebal: true,
          ),
          _BarisInfo(
            label: t.tanggalPengajuan,
            nilai: Format.tanggalJam(permohonan.diajukanPada),
          ),
          if (permohonan.diperbaruiPada != null)
            _BarisInfo(
              label: t.pembaruanTerakhir,
              nilai: Format.tanggalJam(permohonan.diperbaruiPada!),
            ),
          if ((permohonan.namaPemohon ?? '').isNotEmpty)
            _BarisInfo(label: t.pemohon, nilai: permohonan.namaPemohon!),
        ],
      ),
    );
  }
}

class _BarisInfo extends StatelessWidget {
  const _BarisInfo({
    required this.label,
    required this.nilai,
    this.tebal = false,
  });

  final String label;
  final String nilai;
  final bool tebal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: context.teks.bodySmall?.copyWith(color: Warna.teksKetiga),
            ),
          ),
          Expanded(
            child: Text(
              nilai,
              style: context.teks.bodySmall?.copyWith(
                fontWeight: tebal ? FontWeight.w800 : FontWeight.w600,
                color: tebal ? Warna.primerGelap : Warna.teksUtama,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatatanPetugas extends StatelessWidget {
  const _CatatanPetugas({required this.catatan, required this.catatanLabel});

  final String catatan;
  final String catatanLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Jarak.lg),
      decoration: BoxDecoration(
        color: Warna.peringatanLembut,
        borderRadius: BorderRadius.circular(Sudut.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            HugeIcons.strokeRoundedMessage01,
            size: 18,
            color: Warna.peringatan,
          ),
          const SizedBox(width: Jarak.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  catatanLabel,
                  style: context.teks.labelLarge?.copyWith(
                    color: Warna.peringatan,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  catatan,
                  style: context.teks.bodySmall?.copyWith(
                    color: Warna.teksUtama,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataPermohonan extends ConsumerWidget {
  const _DataPermohonan({
    required this.detail,
    required this.labelRuas,
    required this.tersembunyi,
  });

  final Map<String, dynamic> detail;
  final Map<String, String> labelRuas;
  final Set<String> tersembunyi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final baris = <MapEntry<String, String>>[];
    for (final masuk in detail.entries) {
      if (tersembunyi.contains(masuk.key)) continue;
      if (masuk.key.startsWith('doc_')) continue;
      final nilai = masuk.value;
      if (nilai == null) continue;
      if (nilai is Map || nilai is List) continue;
      final teks = nilai.toString().trim();
      if (teks.isEmpty) continue;
      baris.add(
        MapEntry(labelRuas[masuk.key] ?? _rapikanKunci(masuk.key), teks),
      );
    }
    if (baris.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(Jarak.lg),
      decoration: BoxDecoration(
        color: Warna.permukaan,
        borderRadius: BorderRadius.circular(Sudut.lg),
        border: Border.all(color: Warna.garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.dataPermohonan,
            style: context.teks.labelLarge?.copyWith(
              color: Warna.primerGelap,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: Jarak.sm),
          for (final item in baris)
            _BarisInfo(label: item.key, nilai: item.value),
        ],
      ),
    );
  }

  String _rapikanKunci(String kunci) {
    final kata = kunci.replaceAll('_', ' ').trim();
    if (kata.isEmpty) return kunci;
    return kata
        .split(' ')
        .map((k) => k.isEmpty ? k : '${k[0].toUpperCase()}${k.substring(1)}')
        .join(' ');
  }
}

class _DokumenHasil extends ConsumerWidget {
  const _DokumenHasil({
    required this.dokumen,
    required this.saatUnduh,
    required this.saatCobaLagi,
  });

  final AsyncValue<List<DokumenHasil>> dokumen;
  final ValueChanged<DokumenHasil> saatUnduh;
  final VoidCallback saatCobaLagi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.unduhDokumenHasil,
          style: context.teks.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: Jarak.md),
        dokumen.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: Jarak.lg),
            child: PemuatLingkar(ukuran: 24),
          ),
          error: (e, _) => _KotakKosongHasil(
            pesan: pesanRamah(e, fallback: t.gagalMuatDetail, teks: t),
            ikon: HugeIcons.strokeRoundedAlert02,
            saatCobaLagi: saatCobaLagi,
            labelCobaLagi: t.cobaLagi,
          ),
          data: (daftar) {
            if (daftar.isEmpty) {
              return _KotakKosongHasil(
                pesan: t.tidakAdaData,
                ikon: HugeIcons.strokeRoundedFile02,
              );
            }
            return Container(
              decoration: BoxDecoration(
                color: Warna.permukaan,
                borderRadius: BorderRadius.circular(Sudut.lg),
                border: Border.all(color: Warna.garis),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < daftar.length; i++) ...[
                    if (i > 0) const Divider(indent: 64, color: Warna.pemisah),
                    _BarisDokumenHasil(
                      dokumen: daftar[i],
                      saatUnduh: () => saatUnduh(daftar[i]),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BarisDokumenHasil extends StatelessWidget {
  const _BarisDokumenHasil({required this.dokumen, required this.saatUnduh});

  final DokumenHasil dokumen;
  final VoidCallback saatUnduh;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: saatUnduh,
      splashColor: Warna.primerLembut,
      highlightColor: Warna.primerLembut,
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
                color: Warna.primerLembut,
                borderRadius: BorderRadius.circular(Sudut.sm),
              ),
              child: const Icon(
                HugeIcons.strokeRoundedFileDownload,
                size: 18,
                color: Warna.primer,
              ),
            ),
            const SizedBox(width: Jarak.md),
            Expanded(
              child: Text(
                dokumen.nama,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.teks.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: Jarak.sm),
            const Icon(
              HugeIcons.strokeRoundedDownload04,
              size: 20,
              color: Warna.primer,
            ),
          ],
        ),
      ),
    );
  }
}

class _KotakKosongHasil extends StatelessWidget {
  const _KotakKosongHasil({
    required this.pesan,
    required this.ikon,
    this.saatCobaLagi,
    this.labelCobaLagi,
  });

  final String pesan;
  final IconData ikon;
  final VoidCallback? saatCobaLagi;
  final String? labelCobaLagi;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Jarak.lg),
      decoration: BoxDecoration(
        color: Warna.permukaan,
        borderRadius: BorderRadius.circular(Sudut.lg),
        border: Border.all(color: Warna.garis),
      ),
      child: Column(
        children: [
          Icon(ikon, size: 28, color: Warna.teksKetiga),
          const SizedBox(height: Jarak.sm),
          Text(
            pesan,
            textAlign: TextAlign.center,
            style: context.teks.bodySmall?.copyWith(
              color: Warna.teksKedua,
              height: 1.45,
            ),
          ),
          if (saatCobaLagi != null && labelCobaLagi != null) ...[
            const SizedBox(height: Jarak.sm),
            TextButton(onPressed: saatCobaLagi, child: Text(labelCobaLagi!)),
          ],
        ],
      ),
    );
  }
}
