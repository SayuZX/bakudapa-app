import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../core/extensions/konteks.dart';
import '../../core/theme/dimensi.dart';
import '../../core/theme/warna.dart';
import '../providers/penyedia_muat_global.dart';

class OverlayMuatGlobal extends ConsumerWidget {
  const OverlayMuatGlobal({super.key, required this.anak});

  final Widget anak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kondisi = ref.watch(penyediaMuatGlobal);
    return Stack(
      children: [
        anak,
        if (kondisi.aktif)
          _DialogMuat(
            judul: kondisi.judul,
            pesan: kondisi.pesan,
          ),
      ],
    );
  }
}

class _DialogMuat extends StatelessWidget {
  const _DialogMuat({this.judul, this.pesan});

  final String? judul;
  final String? pesan;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: const ModalBarrier(
                dismissible: false,
                color: Color(0x52000000),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.fromLTRB(28, 30, 28, 26),
                decoration: BoxDecoration(
                  color: Warna.permukaan,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingAnimationWidget.fourRotatingDots(
                      color: Warna.primer,
                      size: 46,
                    ),
                    const SizedBox(height: Jarak.xl),
                    Text(
                      judul ?? 'Mohon Tunggu',
                      textAlign: TextAlign.center,
                      style: context.teks.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (pesan != null) ...[
                      const SizedBox(height: Jarak.sm),
                      Text(
                        pesan!,
                        textAlign: TextAlign.center,
                        style: context.teks.bodySmall?.copyWith(
                          color: Warna.teksKedua,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 160.ms)
                  .scale(
                    begin: const Offset(0.92, 0.92),
                    end: const Offset(1, 1),
                    duration: 220.ms,
                    curve: Curves.easeOutBack,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
