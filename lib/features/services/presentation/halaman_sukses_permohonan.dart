import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/models/jenis_layanan.dart';
import '../../../shared/widgets/tombol_utama.dart';
import '../../applications/domain/repositori_permohonan.dart';
import '../../registration/presentation/widgets/animated_success_icon.dart';
import '../../registration/presentation/widgets/konfeti_sukses.dart';

class HalamanSuksesPermohonan extends ConsumerWidget {
  const HalamanSuksesPermohonan({super.key, required this.hasil});

  final HasilAjukan hasil;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (sudahPop, _) {
        if (!sudahPop) context.go(NamaRute.beranda);
      },
      child: Scaffold(
        backgroundColor: Warna.permukaan,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Jarak.xxl),
            child: Column(
              children: [
                const Spacer(),
                SizedBox(
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: const [
                      Positioned.fill(
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
                  t.permohonanTerkirim,
                  textAlign: TextAlign.center,
                  style: context.teks.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ).animate(delay: 120.ms).fadeIn(duration: 280.ms).slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 320.ms,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: Jarak.sm),
                Text(
                  t.suksesPermohonanSub(
                    t.katalog(JenisLayanan.labelSlug(hasil.slugLayanan)),
                  ),
                  textAlign: TextAlign.center,
                  style: context.teks.bodyMedium?.copyWith(
                    color: Warna.teksKedua,
                    height: 1.5,
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 280.ms),
                const SizedBox(height: Jarak.xxl),
                if (hasil.nomorPermohonan.isNotEmpty)
                  _KotakNomor(teks: t, nomor: hasil.nomorPermohonan)
                      .animate(delay: 280.ms)
                      .fadeIn(duration: 280.ms)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 320.ms,
                        curve: Curves.easeOutCubic,
                      ),
                const Spacer(),
                TombolUtama(
                  label: t.lihatRiwayatPermohonan,
                  saatTekan: () => context.go(NamaRute.riwayat),
                ),
                const SizedBox(height: Jarak.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go(NamaRute.beranda),
                    child: Text(t.kembaliKeBeranda),
                  ),
                ),
                const SizedBox(height: Jarak.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KotakNomor extends StatelessWidget {
  const _KotakNomor({required this.teks, required this.nomor});

  final Teks teks;
  final String nomor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: nomor));
        if (context.mounted) {
          context.tampilkanInfo(teks.nomorDisalin);
        }
      },
      borderRadius: BorderRadius.circular(Sudut.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Jarak.xl),
        decoration: BoxDecoration(
          color: Warna.netral50,
          borderRadius: BorderRadius.circular(Sudut.lg),
          border: Border.all(color: Warna.garis),
        ),
        child: Column(
          children: [
            Text(
              teks.nomorPermohonan,
              style: context.teks.labelSmall?.copyWith(
                color: Warna.teksKetiga,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: Jarak.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    nomor,
                    textAlign: TextAlign.center,
                    style: context.teks.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: Warna.primerGelap,
                    ),
                  ),
                ),
                const SizedBox(width: Jarak.sm),
                const Icon(
                  HugeIcons.strokeRoundedCopy01,
                  size: 16,
                  color: Warna.teksKetiga,
                ),
              ],
            ),
            const SizedBox(height: Jarak.xs),
            Text(
              teks.ketukSalinBukti,
              style: context.teks.labelSmall?.copyWith(
                color: Warna.teksKetiga,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
