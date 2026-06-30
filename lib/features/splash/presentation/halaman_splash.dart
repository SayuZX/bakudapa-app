import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/config/branding.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/system/layanan_status_sistem.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/providers/penyedia_otentikasi.dart';

class HalamanSplash extends ConsumerWidget {
  const HalamanSplash({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kondisi = ref.watch(penyediaOtentikasi);
    if (kondisi.terblokirOlehKeamanan) {
      return _LayarBlokirKeamanan(kondisi: kondisi);
    }
    return const _LayarMemuat();
  }
}

class _LayarMemuat extends StatefulWidget {
  const _LayarMemuat();

  @override
  State<_LayarMemuat> createState() => _LayarMemuatState();
}

class _LayarMemuatState extends State<_LayarMemuat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kemajuan;

  @override
  void initState() {
    super.initState();
    _kemajuan = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();
    Future.microtask(() => LayananStatusSistem.instance.cek());
  }

  @override
  void dispose() {
    _kemajuan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.permukaan,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Jarak.layarH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 3),
              Center(
                child: Column(
                  children: [
                    _MerekUtama()
                        .animate()
                        .fadeIn(duration: 450.ms)
                        .scale(begin: const Offset(0.94, 0.94)),
                    const SizedBox(height: Jarak.xl),
                    Text(
                      Branding.namaAplikasi,
                      style: context.teks.headlineMedium?.copyWith(
                        letterSpacing: -0.4,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                    const SizedBox(height: Jarak.xs),
                    Text(
                      Branding.tagline,
                      style: context.teks.bodyMedium?.copyWith(
                        color: Warna.teksKedua,
                      ),
                    ).animate().fadeIn(delay: 320.ms, duration: 500.ms),
                  ],
                ),
              ),
              const Spacer(flex: 4),
              _BarKemajuan(animasi: _kemajuan),
              const SizedBox(height: Jarak.md),
              Center(
                child: Text(
                  'Memeriksa keamanan perangkat…',
                  style: context.teks.labelMedium?.copyWith(
                    color: Warna.teksKedua,
                  ),
                ),
              ),
              const SizedBox(height: Jarak.xl),
              Center(
                child: Column(
                  children: [
                    Text(
                      Branding.namaInstansi,
                      style: context.teks.labelMedium,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      Branding.wilayah,
                      style: context.teks.labelSmall?.copyWith(
                        color: Warna.teksKetiga,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Jarak.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _LayarBlokirKeamanan extends ConsumerWidget {
  const _LayarBlokirKeamanan({required this.kondisi});
  final KondisiOtentikasi kondisi;

  _IsiBlokir _isi() {
    switch (kondisi.status) {
      case StatusOtentikasi.perangkatTidakAman:
        return const _IsiBlokir(
          ikon: HugeIcons.strokeRoundedSecurityBlock,
          judul: 'Perangkat Tidak Aman',
          deskripsi:
              'Aplikasi tidak dapat dijalankan karena sistem mendeteksi perangkat telah dimodifikasi atau berada dalam kondisi tidak aman. Demi melindungi data pribadi dan dokumen kependudukan, silakan gunakan perangkat yang aman dan tidak dimodifikasi.',
          tampilkanCobaUlang: false,
          tampilkanKeluar: true,
        );
      case StatusOtentikasi.gagalCekKeamanan:
        return const _IsiBlokir(
          ikon: HugeIcons.strokeRoundedAlert02,
          judul: 'Gagal Memeriksa Keamanan',
          deskripsi:
              'Pemeriksaan keamanan tidak dapat diselesaikan. Pastikan perangkat Anda terhubung ke jaringan yang stabil, lalu coba lagi.',
          tampilkanCobaUlang: true,
          tampilkanKeluar: true,
        );
      default:
        return const _IsiBlokir(
          ikon: HugeIcons.strokeRoundedAlert02,
          judul: 'Terjadi Kesalahan',
          deskripsi: 'Mohon coba beberapa saat lagi.',
          tampilkanCobaUlang: true,
          tampilkanKeluar: true,
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isi = _isi();

    return Scaffold(
      backgroundColor: Warna.permukaan,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Jarak.xxl,
            vertical: Jarak.xl,
          ),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: Warna.bahayaLembut,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(isi.ikon, color: Warna.bahaya, size: 40),
              ),
              const SizedBox(height: Jarak.xxl),
              Text(
                isi.judul,
                textAlign: TextAlign.center,
                style: context.teks.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: Jarak.md),
              Text(
                isi.deskripsi,
                textAlign: TextAlign.center,
                style: context.teks.bodyMedium?.copyWith(
                  color: Warna.teksKedua,
                  height: 1.55,
                ),
              ),
              const Spacer(flex: 3),
              if (isi.tampilkanCobaUlang) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => ref
                        .read(penyediaOtentikasi.notifier)
                        .cobaUlangPemeriksaan(),
                    style: FilledButton.styleFrom(
                      backgroundColor: Warna.primer,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ),
                const SizedBox(height: Jarak.md),
              ],
              if (isi.tampilkanKeluar)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => SystemNavigator.pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Warna.garisTegas, width: 1.2),
                      foregroundColor: Warna.teksUtama,
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Keluar Aplikasi'),
                  ),
                ),
              const SizedBox(height: Jarak.xl),
              Text(
                Branding.namaInstansi,
                style: context.teks.labelMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                Branding.wilayah,
                style: context.teks.labelSmall?.copyWith(
                  color: Warna.teksKetiga,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IsiBlokir {
  const _IsiBlokir({
    required this.ikon,
    required this.judul,
    required this.deskripsi,
    required this.tampilkanCobaUlang,
    required this.tampilkanKeluar,
  });

  final IconData ikon;
  final String judul;
  final String deskripsi;
  final bool tampilkanCobaUlang;
  final bool tampilkanKeluar;
}

class _MerekUtama extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/logo-malut.svg',
      width: 132,
      height: 132,
      fit: BoxFit.contain,
    );
  }
}

class _BarKemajuan extends StatelessWidget {
  const _BarKemajuan({required this.animasi});
  final AnimationController animasi;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animasi,
      builder: (_, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(Sudut.pil),
          child: LinearProgressIndicator(
            value: animasi.value,
            minHeight: 4,
            backgroundColor: Warna.netral100,
            valueColor: const AlwaysStoppedAnimation<Color>(Warna.primer),
          ),
        );
      },
    );
  }
}
