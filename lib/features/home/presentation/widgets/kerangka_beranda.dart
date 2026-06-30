import 'package:flutter/material.dart';

import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../../shared/widgets/pemuat_kerlip.dart';

class KerangkaBeranda extends StatelessWidget {
  const KerangkaBeranda({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Jarak.layarH,
        Jarak.xs,
        Jarak.layarH,
        Jarak.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _KerangkaKartuRingkasan(),
          const SizedBox(height: Jarak.xxl),
          const PemuatKerlip(lebar: 180, tinggi: 16),
          const SizedBox(height: Jarak.md),
          const _KerangkaGridLayanan(),
          const SizedBox(height: Jarak.xxl),
          const PemuatKerlip(lebar: 160, tinggi: 16),
          const SizedBox(height: Jarak.md),
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(height: Jarak.md),
            const KerangkaBarisPermohonan(),
          ],
        ],
      ),
    );
  }
}

class _KerangkaKartuRingkasan extends StatelessWidget {
  const _KerangkaKartuRingkasan();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Jarak.xl),
      decoration: BoxDecoration(
        color: Warna.permukaan,
        borderRadius: BorderRadius.circular(Sudut.xl),
        border: Border.all(color: Warna.garis),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PemuatKerlip(lebar: 130, tinggi: 12),
          SizedBox(height: Jarak.md),
          PemuatKerlip(lebar: 72, tinggi: 34),
          SizedBox(height: Jarak.sm),
          PemuatKerlip(lebar: 180, tinggi: 10),
          SizedBox(height: Jarak.xl),
          PemuatKerlip(lebar: double.infinity, tinggi: 58, sudut: Sudut.md),
        ],
      ),
    );
  }
}

class _KerangkaGridLayanan extends StatelessWidget {
  const _KerangkaGridLayanan();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Warna.permukaan,
        borderRadius: BorderRadius.circular(Sudut.lg),
        border: Border.all(color: Warna.garis),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Jarak.sm,
        vertical: Jarak.lg,
      ),
      child: Column(
        children: [
          for (var baris = 0; baris < 2; baris++) ...[
            if (baris == 1) const SizedBox(height: Jarak.xl),
            Row(
              children: [
                for (var kolom = 0; kolom < 3; kolom++)
                  const Expanded(
                    child: Column(
                      children: [
                        PemuatKerlip(tinggi: 52, lingkaran: true),
                        SizedBox(height: Jarak.sm),
                        PemuatKerlip(lebar: 56, tinggi: 10),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class KerangkaBarisPermohonan extends StatelessWidget {
  const KerangkaBarisPermohonan({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Jarak.lg),
      decoration: BoxDecoration(
        color: Warna.permukaan,
        borderRadius: BorderRadius.circular(Sudut.lg),
        border: Border.all(color: Warna.garis),
      ),
      child: const Row(
        children: [
          PemuatKerlip(tinggi: 44, lebar: 44, sudut: Sudut.md),
          SizedBox(width: Jarak.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PemuatKerlip(lebar: 150, tinggi: 13),
                SizedBox(height: 8),
                PemuatKerlip(lebar: 110, tinggi: 11),
              ],
            ),
          ),
          SizedBox(width: Jarak.sm),
          PemuatKerlip(lebar: 64, tinggi: 22, sudut: Sudut.pil),
        ],
      ),
    );
  }
}
