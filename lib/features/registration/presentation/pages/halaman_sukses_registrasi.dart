import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/router/nama_rute.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../../shared/providers/penyedia_bahasa.dart';
import '../../providers/penyedia_registrasi.dart';
import '../widgets/animated_success_icon.dart';
import '../widgets/konfeti_sukses.dart';

class HalamanSuksesRegistrasi extends ConsumerWidget {
  const HalamanSuksesRegistrasi({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final sesi = ref.watch(penyediaRegistrasi).sesi;
    final tokenRingkas = (sesi.token ?? '').isEmpty
        ? '-'
        : sesi.token!.length > 10
            ? sesi.token!.substring(sesi.token!.length - 10).toUpperCase()
            : sesi.token!.toUpperCase();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Jarak.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),
              Text(
                t.verifikasiBerhasilDikirim,
                textAlign: TextAlign.center,
                style: context.teks.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: Jarak.xxl),
              SizedBox(
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned.fill(
                      child: KonfetiSukses(radiusMaks: 130),
                    ),
                    AnimatedSuccessIcon(
                      ukuran: 120,
                      tebal: 6,
                      terisi: true,
                      warnaCheck: Warna.primer,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Jarak.xxl),
              Text(
                ref.watch(penyediaBahasa) == KodeBahasa.en
                    ? 'Your registration has been submitted and is awaiting verification by Disdukcapil Provinsi Maluku Utara.'
                    : 'Data registrasi Anda telah dikirim dan sedang menunggu verifikasi operator Disdukcapil Provinsi Maluku Utara.',
                textAlign: TextAlign.center,
                style: context.teks.bodyMedium?.copyWith(
                  color: Warna.teksKedua,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: Jarak.lg),
              Container(
                padding: const EdgeInsets.all(Jarak.md),
                decoration: BoxDecoration(
                  color: Warna.primerLembut,
                  borderRadius: BorderRadius.circular(Sudut.md),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      HugeIcons.strokeRoundedMail01,
                      size: 18,
                      color: Warna.primer,
                    ),
                    const SizedBox(width: Jarak.sm),
                    Expanded(
                      child: Text(
                        t.infoKataSandiSementara,
                        style: context.teks.bodySmall?.copyWith(
                          color: Warna.teksKedua,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Jarak.lg),
              Text(
                t.nomorRegistrasi,
                textAlign: TextAlign.center,
                style: context.teks.labelSmall?.copyWith(
                  color: Warna.teksKedua,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'REG-$tokenRingkas',
                textAlign: TextAlign.center,
                style: context.teks.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Warna.teksUtama,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(flex: 5),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () async {
                    await ref
                        .read(penyediaRegistrasi.notifier)
                        .resetPenuh();
                    if (context.mounted) {
                      context.go(NamaRute.masuk);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Warna.primer,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(t.selesai),
                ),
              ),
              const SizedBox(height: Jarak.md),
            ],
          ),
        ),
      ),
    );
  }
}
