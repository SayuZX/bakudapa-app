import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/extensions/konteks.dart';
import '../../core/theme/dimensi.dart';
import '../../core/theme/warna.dart';
import 'tombol_utama.dart';

class KondisiGalat extends StatelessWidget {
  const KondisiGalat({
    super.key,
    required this.pesan,
    this.judul = 'Terjadi kesalahan',
    this.saatCobaLagi,
    this.labelCobaLagi = 'Coba lagi',
    this.ikon = HugeIcons.strokeRoundedAlert02,
  });

  final String pesan;
  final String judul;
  final VoidCallback? saatCobaLagi;
  final String labelCobaLagi;
  final IconData ikon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Jarak.xxl,
        vertical: Jarak.xxxl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Warna.bahayaLembut,
              shape: BoxShape.circle,
            ),
            child: Icon(ikon, size: 32, color: Warna.bahaya),
          ),
          const SizedBox(height: Jarak.lg),
          Text(judul, style: context.teks.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: Jarak.xs),
          Text(
            pesan,
            style: context.teks.bodyMedium?.copyWith(color: Warna.teksKedua),
            textAlign: TextAlign.center,
          ),
          if (saatCobaLagi != null) ...[
            const SizedBox(height: Jarak.xl),
            TombolUtama(label: labelCobaLagi, saatTekan: saatCobaLagi, melebar: false),
          ],
        ],
      ),
    );
  }
}
