import 'package:flutter/material.dart';

import '../../core/theme/dimensi.dart';
import '../../core/theme/warna.dart';

class TombolUtama extends StatelessWidget {
  const TombolUtama({
    super.key,
    required this.label,
    required this.saatTekan,
    this.memuat = false,
    this.ikon,
    this.melebar = true,
    this.bahaya = false,
  });

  final String label;
  final VoidCallback? saatTekan;
  final bool memuat;
  final Widget? ikon;
  final bool melebar;
  final bool bahaya;

  @override
  Widget build(BuildContext context) {
    final nonaktif = saatTekan == null || memuat;
    final latar = bahaya ? Warna.bahaya : Warna.primer;

    final isi = memuat
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (ikon != null) ...[
                ikon!,
                const SizedBox(width: Jarak.sm),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final tombol = FilledButton(
      onPressed: nonaktif ? null : saatTekan,
      style: FilledButton.styleFrom(
        backgroundColor: latar,
        disabledBackgroundColor: Warna.netral200,
      ),
      child: isi,
    );

    return melebar ? SizedBox(width: double.infinity, child: tombol) : tombol;
  }
}
