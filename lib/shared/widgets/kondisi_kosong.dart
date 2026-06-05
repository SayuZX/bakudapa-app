import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/extensions/konteks.dart';
import '../../core/theme/dimensi.dart';
import '../../core/theme/warna.dart';
import 'tombol_garis.dart';

class KondisiKosong extends StatelessWidget {
  const KondisiKosong({
    super.key,
    this.ikon = HugeIcons.strokeRoundedInbox,
    required this.judul,
    this.pesan,
    this.labelAksi,
    this.saatAksi,
  });

  final IconData ikon;
  final String judul;
  final String? pesan;
  final String? labelAksi;
  final VoidCallback? saatAksi;

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
              color: Warna.netral100,
              shape: BoxShape.circle,
            ),
            child: Icon(ikon, size: 32, color: Warna.teksKedua),
          ),
          const SizedBox(height: Jarak.lg),
          Text(judul, style: context.teks.titleMedium, textAlign: TextAlign.center),
          if (pesan != null) ...[
            const SizedBox(height: Jarak.xs),
            Text(
              pesan!,
              style: context.teks.bodyMedium?.copyWith(color: Warna.teksKedua),
              textAlign: TextAlign.center,
            ),
          ],
          if (labelAksi != null && saatAksi != null) ...[
            const SizedBox(height: Jarak.xl),
            TombolGaris(label: labelAksi!, saatTekan: saatAksi, melebar: false),
          ],
        ],
      ),
    );
  }
}
