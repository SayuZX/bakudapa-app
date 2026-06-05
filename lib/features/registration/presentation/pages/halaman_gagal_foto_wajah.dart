import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/router/nama_rute.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../providers/penyedia_registrasi.dart';
import '../widgets/stepper_registrasi.dart';

class HalamanGagalFotoWajah extends ConsumerWidget {
  const HalamanGagalFotoWajah({super.key, this.alasanTerakhir});

  final String? alasanTerakhir;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kondisi = ref.watch(penyediaRegistrasi);
    final t = ref.watch(teksProvider);
    final percobaan = kondisi.percobaanFotoWajah;
    final maks = KondisiRegistrasi.maksPercobaanFotoWajah;
    final habis = kondisi.terblokirFotoWajah;
    final sisa = (maks - percobaan).clamp(0, maks);

    return Scaffold(
      backgroundColor: Warna.permukaan,
      appBar: AppBar(
        title: Text(t.fotoWajah),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          StepperRegistrasi(
            langkahAktif: LangkahRegistrasi.fotoWajah,
            judulLangkah: t.fotoWajah,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
              children: [
                _Kepala(habis: habis),
                if (alasanTerakhir != null && alasanTerakhir!.isNotEmpty) ...[
                  const SizedBox(height: Jarak.lg),
                  const Divider(height: 1, color: Warna.pemisah),
                  const SizedBox(height: Jarak.md),
                  _Peringatan(pesan: alasanTerakhir!),
                ],
                const SizedBox(height: Jarak.xl),
                const Divider(height: 1, color: Warna.pemisah),
                const SizedBox(height: Jarak.xl),
                _DaftarPanduan(),
                const SizedBox(height: Jarak.xxl),
                _StatusPercobaan(habis: habis, sisa: sisa, total: maks),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: _Aksi(habis: habis, ref: ref),
            ),
          ),
        ],
      ),
    );
  }
}

class _Kepala extends ConsumerWidget {
  const _Kepala({required this.habis});
  final bool habis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final warnaIkon = habis ? Warna.bahaya : Warna.teksKedua;
    return Column(
      children: [
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: warnaIkon, width: 1.4),
            ),
            alignment: Alignment.center,
            child: Icon(
              habis
                  ? HugeIcons.strokeRoundedAlert02
                  : HugeIcons.strokeRoundedRefresh,
              size: 26,
              color: warnaIkon,
            ),
          ),
        ),
        const SizedBox(height: Jarak.lg),
        Text(
          habis ? t.fotoBelumVerifikasi : t.butuhCobaSekaliLagi,
          textAlign: TextAlign.center,
          style: context.teks.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          habis ? t.andaTelahMenggunakanKuota : t.sistemBelumDapatMemverifikasi,
          textAlign: TextAlign.center,
          style: context.teks.bodyMedium?.copyWith(
            color: Warna.teksKedua,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

class _Peringatan extends StatelessWidget {
  const _Peringatan({required this.pesan});
  final String pesan;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          HugeIcons.strokeRoundedAlert02,
          size: 16,
          color: Warna.teksKedua,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            pesan,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Warna.teksUtama,
                  height: 1.55,
                ),
          ),
        ),
      ],
    );
  }
}

class _DaftarPanduan extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final panduan = [t.panduan1, t.panduan2, t.panduan3, t.panduan4];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.panduanTambahan,
          style: context.teks.labelSmall?.copyWith(
            color: Warna.teksKetiga,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: Jarak.md),
        for (var i = 0; i < panduan.length; i++) ...[
          _BarisPanduan(nomor: i + 1, teks: panduan[i]),
          if (i < panduan.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Divider(height: 1, color: Warna.pemisah),
            ),
        ],
      ],
    );
  }
}

class _BarisPanduan extends StatelessWidget {
  const _BarisPanduan({required this.nomor, required this.teks});
  final int nomor;
  final String teks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '$nomor.',
              style: context.teks.bodyMedium?.copyWith(
                color: Warna.teksKedua,
                fontWeight: FontWeight.w700,
                height: 1.55,
              ),
            ),
          ),
          Expanded(
            child: Text(
              teks,
              style: context.teks.bodyMedium?.copyWith(
                color: Warna.teksUtama,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPercobaan extends ConsumerWidget {
  const _StatusPercobaan({
    required this.habis,
    required this.sisa,
    required this.total,
  });
  final bool habis;
  final int sisa;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final teks = habis
        ? t.percobaanHabisFormat(total)
        : t.sisaPercobaanFormat(sisa, total);
    return Center(
      child: Text(
        teks,
        style: context.teks.labelMedium?.copyWith(
          color: habis ? Warna.bahaya : Warna.teksKetiga,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _Aksi extends ConsumerWidget {
  const _Aksi({required this.habis, required this.ref});
  final bool habis;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final t = widgetRef.watch(teksProvider);
    if (habis) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: () {
            ref.read(penyediaRegistrasi.notifier).resetPercobaanFotoWajah();
            context.go(NamaRute.daftarFotoWajah);
          },
          style: FilledButton.styleFrom(
            backgroundColor: Warna.merahUtama,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: Text(t.bukaPanduan),
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () => context.go(NamaRute.daftarFotoWajah),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Warna.garisTegas, width: 1.2),
                foregroundColor: Warna.teksUtama,
                shape: const StadiumBorder(),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: Text(t.bukaPanduan),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: () => context.go(NamaRute.daftarKameraFotoWajah),
              style: FilledButton.styleFrom(
                backgroundColor: Warna.merahUtama,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(t.cobaLagi),
            ),
          ),
        ),
      ],
    );
  }
}
