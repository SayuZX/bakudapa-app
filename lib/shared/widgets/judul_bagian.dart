import 'package:flutter/material.dart';

import '../../core/extensions/konteks.dart';
import '../../core/theme/dimensi.dart';
import '../../core/theme/warna.dart';

class JudulBagian extends StatelessWidget {
  const JudulBagian({
    super.key,
    required this.judul,
    this.subJudul,
    this.aksi,
    this.saatAksi,
  });

  final String judul;
  final String? subJudul;
  final String? aksi;
  final VoidCallback? saatAksi;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Jarak.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(judul, style: context.teks.titleMedium),
                if (subJudul != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subJudul!,
                    style: context.teks.bodySmall?.copyWith(color: Warna.teksKedua),
                  ),
                ],
              ],
            ),
          ),
          if (aksi != null)
            TextButton(onPressed: saatAksi, child: Text(aksi!)),
        ],
      ),
    );
  }
}
