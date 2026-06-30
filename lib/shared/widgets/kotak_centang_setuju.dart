import 'package:flutter/material.dart';

import '../../core/extensions/konteks.dart';
import '../../core/theme/dimensi.dart';
import '../../core/theme/warna.dart';

class KotakCentangSetuju extends StatelessWidget {
  const KotakCentangSetuju({
    super.key,
    required this.nilai,
    required this.saatBerubah,
    required this.label,
    this.saatKetukTaut,
    this.aksenTaut,
  });

  final bool nilai;
  final ValueChanged<bool> saatBerubah;
  final String label;
  final VoidCallback? saatKetukTaut;
  final String? aksenTaut;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => saatBerubah(!nilai),
      borderRadius: BorderRadius.circular(Sudut.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 22,
              width: 22,
              child: Checkbox(
                value: nilai,
                onChanged: (v) => saatBerubah(v ?? false),
              ),
            ),
            const SizedBox(width: Jarak.sm),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: label,
                  style: context.teks.bodyMedium?.copyWith(color: Warna.teksKedua),
                  children: [
                    if (aksenTaut != null) ...[
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: aksenTaut,
                        style: context.teks.bodyMedium?.copyWith(
                          color: Warna.primer,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: null,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
