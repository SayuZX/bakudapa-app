import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/router/nama_rute.dart';
import '../../../../core/router/navigasi_aman.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../../core/utils/format.dart';
import '../../../../shared/models/permohonan.dart';
import '../../../../shared/widgets/kartu.dart';
import '../../../../shared/widgets/lencana_status.dart';

class BarisPermohonan extends ConsumerWidget {
  const BarisPermohonan({super.key, required this.permohonan, this.saatKetuk});

  final Permohonan permohonan;
  final VoidCallback? saatKetuk;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final jenis = permohonan.jenis;
    return Kartu(
      saatKetuk: saatKetuk ?? () => _bukaDetail(context),
      anak: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Warna.primerLembut,
              borderRadius: BorderRadius.circular(Sudut.md),
            ),
            child: Icon(
              jenis?.ikon ?? HugeIcons.strokeRoundedFile02,
              size: 22,
              color: Warna.primer,
            ),
          ),
          const SizedBox(width: Jarak.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.katalog(permohonan.namaLayanan),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.teks.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  permohonan.nomorPermohonan.isNotEmpty
                      ? '${permohonan.nomorPermohonan} · ${Format.tanggalPendek(permohonan.diajukanPada)}'
                      : Format.tanggalPendek(permohonan.diajukanPada),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.teks.bodySmall?.copyWith(
                    color: Warna.teksKetiga,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Jarak.sm),
          LencanaStatus(status: permohonan.status, kompak: true),
        ],
      ),
    );
  }

  void _bukaDetail(BuildContext context) {
    final slug = permohonan.slugLayanan;
    if (slug.isEmpty || permohonan.id.isEmpty) return;
    context.pushAman(
      '${NamaRute.detailPermohonan}/$slug/${permohonan.id}',
    );
  }
}
