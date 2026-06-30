import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/dimensi.dart';
import '../../core/theme/warna.dart';

class PemuatKerlip extends StatelessWidget {
  const PemuatKerlip({
    super.key,
    this.lebar,
    this.tinggi = 16,
    this.sudut = 8,
    this.lingkaran = false,
  });

  final double? lebar;
  final double tinggi;
  final double sudut;
  final bool lingkaran;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Warna.kerlipDasar,
      highlightColor: Warna.kerlipSorot,
      period: const Duration(milliseconds: 1400),
      child: Container(
        width: lingkaran ? tinggi : lebar,
        height: tinggi,
        decoration: BoxDecoration(
          color: Warna.kerlipDasar,
          shape: lingkaran ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: lingkaran ? null : BorderRadius.circular(sudut),
        ),
      ),
    );
  }
}

class DaftarKerangka extends StatelessWidget {
  const DaftarKerangka({super.key, this.jumlah = 5});
  final int jumlah;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(Jarak.layarH),
      itemBuilder: (_, _) => Container(
        padding: const EdgeInsets.all(Jarak.lg),
        decoration: BoxDecoration(
          color: Warna.permukaan,
          borderRadius: BorderRadius.circular(Sudut.lg),
          border: Border.all(color: Warna.garis),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PemuatKerlip(lebar: 160, tinggi: 14),
            SizedBox(height: 10),
            PemuatKerlip(lebar: double.infinity, tinggi: 12),
            SizedBox(height: 8),
            PemuatKerlip(lebar: 200, tinggi: 12),
          ],
        ),
      ),
      separatorBuilder: (_, _) => const SizedBox(height: Jarak.md),
      itemCount: jumlah,
    );
  }
}
