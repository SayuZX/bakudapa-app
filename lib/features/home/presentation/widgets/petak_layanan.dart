import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../../shared/models/jenis_layanan.dart';

class PetakLayanan extends ConsumerWidget {
  const PetakLayanan({super.key, required this.jenis, required this.saatKetuk});

  final JenisLayanan jenis;
  final VoidCallback saatKetuk;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    return InkWell(
      onTap: saatKetuk,
      borderRadius: BorderRadius.circular(Sudut.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Jarak.xs,
          vertical: Jarak.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Warna.primerLembut,
                borderRadius: BorderRadius.circular(Sudut.lg),
              ),
              child: Icon(jenis.ikon, size: 24, color: Warna.primer),
            ),
            const SizedBox(height: Jarak.sm),
            Text(
              t.katalog(jenis.namaSingkat),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.teks.labelMedium?.copyWith(
                color: Warna.teksUtama,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
