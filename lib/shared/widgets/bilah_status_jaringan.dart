import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/localization/teks.dart';
import '../../core/network/model_kualitas_jaringan.dart';
import '../../core/theme/warna.dart';
import '../providers/penyedia_kualitas_jaringan.dart';

class BilahStatusJaringan extends ConsumerWidget {
  const BilahStatusJaringan({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kualitas = ref.watch(kualitasJaringanProvider);
    final t = ref.watch(teksProvider);
    final tampil = kualitas.aktifOffline ||
        kualitas.status == StatusKualitasJaringan.serverTakTerjangkau;
    final tinggi = tampil ? 28.0 : 0.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: tinggi,
      color: kualitas.aktifOffline ? Warna.netral900 : Warna.netral800,
      child: tampil
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  kualitas.aktifOffline
                      ? HugeIcons.strokeRoundedWifiDisconnected03
                      : HugeIcons.strokeRoundedCellularNetworkOffline,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 8),
                Text(
                  kualitas.aktifOffline
                      ? t.jaringanOffline
                      : t.jaringanServerTakTerjangkauJudul,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
