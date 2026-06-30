import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../applications/domain/repositori_permohonan.dart';

class KartuRingkasan extends ConsumerWidget {
  const KartuRingkasan({
    super.key,
    required this.ringkasan,
    required this.memuat,
    this.saatKetuk,
  });

  final RingkasanStatus? ringkasan;
  final bool memuat;
  final VoidCallback? saatKetuk;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    return Material(
      color: Warna.primer,
      borderRadius: BorderRadius.circular(Sudut.xl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: saatKetuk,
        splashColor: Warna.primerGelap,
        highlightColor: Warna.primerGelap,
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Warna.primer, Warna.primerGelap],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Jarak.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.permohonanAnda,
                        style: context.teks.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const Icon(
                      HugeIcons.strokeRoundedArrowRight01,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: Jarak.sm),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  child: Text(
                    memuat && ringkasan == null
                        ? '—'
                        : '${ringkasan?.total ?? 0}',
                    key: ValueKey(ringkasan?.total),
                    style: context.teks.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.totalPermohonanAktif,
                  style: context.teks.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: Jarak.xl),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Jarak.lg,
                    vertical: Jarak.md,
                  ),
                  decoration: BoxDecoration(
                    color: Warna.primerGelap,
                    borderRadius: BorderRadius.circular(Sudut.md),
                  ),
                  child: Row(
                    children: [
                      _Statistik(
                        label: t.labelMenunggu,
                        nilai: ringkasan?.menunggu,
                      ),
                      _PembatasStatistik(),
                      _Statistik(
                        label: t.labelDiproses,
                        nilai: ringkasan?.berjalan,
                      ),
                      _PembatasStatistik(),
                      _Statistik(
                        label: t.labelSelesai,
                        nilai: ringkasan?.selesai,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Statistik extends StatelessWidget {
  const _Statistik({required this.label, required this.nilai});

  final String label;
  final int? nilai;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            nilai == null ? '—' : '$nilai',
            style: context.teks.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: context.teks.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _PembatasStatistik extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.14),
    );
  }
}
