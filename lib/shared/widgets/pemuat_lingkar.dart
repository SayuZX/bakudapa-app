import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../core/extensions/konteks.dart';
import '../../core/theme/dimensi.dart';
import '../../core/theme/warna.dart';

class PemuatLingkar extends StatelessWidget {
  const PemuatLingkar({super.key, this.ukuran = 40, this.pesan});

  final double ukuran;
  final String? pesan;

  @override
  Widget build(BuildContext context) {
    final lingkar = LoadingAnimationWidget.fourRotatingDots(
      color: Warna.primer,
      size: ukuran,
    );
    if (pesan == null) return Center(child: lingkar);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          lingkar,
          const SizedBox(height: Jarak.lg),
          Text(
            pesan!,
            textAlign: TextAlign.center,
            style: context.teks.bodySmall?.copyWith(color: Warna.teksKedua),
          ),
        ],
      ),
    );
  }
}
