import 'package:flutter/material.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../../shared/models/permohonan.dart';
import '../../../../shared/widgets/kartu.dart';

class BarisPermohonan extends StatelessWidget {
  const BarisPermohonan({
    super.key,
    required this.permohonan,
    required this.subJudul,
    required this.lencana,
    this.saatKetuk,
  });

  final Permohonan permohonan;
  final String subJudul;
  final Widget lencana;
  final VoidCallback? saatKetuk;

  @override
  Widget build(BuildContext context) {
    return Kartu(
      saatKetuk: saatKetuk,
      anak: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Warna.netral100,
              borderRadius: BorderRadius.circular(Sudut.md),
            ),
            child: Icon(permohonan.jenis.ikon, size: 22, color: Warna.teksUtama),
          ),
          const SizedBox(width: Jarak.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(permohonan.kodeReferensi, style: context.teks.titleSmall),
                const SizedBox(height: 2),
                Text(
                  subJudul,
                  style: context.teks.bodySmall?.copyWith(color: Warna.teksKedua),
                ),
              ],
            ),
          ),
          const SizedBox(width: Jarak.sm),
          lencana,
        ],
      ),
    );
  }
}
