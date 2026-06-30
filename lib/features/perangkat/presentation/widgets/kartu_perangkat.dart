import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../../core/utils/format.dart';
import '../../../../shared/models/perangkat_aktif.dart';

class KartuPerangkat extends ConsumerWidget {
  const KartuPerangkat({
    super.key,
    required this.perangkat,
    this.saatLogout,
    this.sedangProses = false,
    this.tampilkanStatus = false,
  });

  final PerangkatAktif perangkat;
  final VoidCallback? saatLogout;
  final bool sedangProses;
  final bool tampilkanStatus;

  ({String label, Color warna})? _status(Teks t) {
    switch (perangkat.status) {
      case StatusPerangkat.aktif:
        return (label: t.statusPerangkatAktif, warna: Warna.sukses);
      case StatusPerangkat.dicabut:
        return (label: t.statusPerangkatDicabut, warna: Warna.teksKedua);
      case StatusPerangkat.kedaluwarsa:
        return (label: t.statusPerangkatKedaluwarsa, warna: Warna.peringatan);
      case StatusPerangkat.takDikenal:
        return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final ini = perangkat.iniPerangkatSaatIni;
    final nama = perangkat.namaTampil.isNotEmpty
        ? perangkat.namaTampil
        : t.perangkatTidakDikenal;
    final status = tampilkanStatus ? _status(t) : null;

    return Container(
      padding: const EdgeInsets.all(Jarak.lg),
      decoration: BoxDecoration(
        color: Warna.permukaan,
        borderRadius: BorderRadius.circular(Sudut.lg),
        border: Border.all(color: ini ? Warna.primer : Warna.garis),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Warna.primer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Sudut.md),
            ),
            alignment: Alignment.center,
            child: const Icon(
              HugeIcons.strokeRoundedSmartPhone01,
              size: 22,
              color: Warna.primer,
            ),
          ),
          const SizedBox(width: Jarak.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.teks.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (ini) ...[
                      const SizedBox(width: Jarak.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Warna.primer.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(Sudut.pil),
                        ),
                        child: Text(
                          t.perangkatIni,
                          style: context.teks.labelSmall?.copyWith(
                            color: Warna.primer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (perangkat.label.isEmpty && perangkat.os.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    perangkat.os,
                    style: context.teks.bodySmall?.copyWith(
                      color: Warna.teksKedua,
                    ),
                  ),
                ],
                if (perangkat.terakhirAktif != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${t.terakhirAktif}: ${Format.relatif(perangkat.terakhirAktif!)}',
                    style: context.teks.bodySmall?.copyWith(
                      color: Warna.teksKetiga,
                    ),
                  ),
                ],
                if (tampilkanStatus && perangkat.masukPada != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${t.masukPada}: ${Format.tanggalJam(perangkat.masukPada!)}',
                    style: context.teks.bodySmall?.copyWith(
                      color: Warna.teksKetiga,
                    ),
                  ),
                ],
                if (status != null) ...[
                  const SizedBox(height: Jarak.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: status.warna.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(Sudut.pil),
                    ),
                    child: Text(
                      status.label,
                      style: context.teks.labelSmall?.copyWith(
                        color: status.warna,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (saatLogout != null && !ini) ...[
            const SizedBox(width: Jarak.sm),
            sedangProses
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Warna.bahaya,
                    ),
                  )
                : IconButton(
                    onPressed: saatLogout,
                    tooltip: t.logoutPerangkat,
                    icon: const Icon(
                      HugeIcons.strokeRoundedLogout03,
                      size: 20,
                      color: Warna.bahaya,
                    ),
                  ),
          ],
        ],
      ),
    );
  }
}
