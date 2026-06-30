import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/config/storage_keys.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/widgets/tombol_garis.dart';
import '../../../shared/widgets/tombol_utama.dart';

class _Slide {
  const _Slide({required this.judul, required this.deskripsi, required this.ikon});
  final String judul;
  final String deskripsi;
  final IconData ikon;
}

class HalamanOnboarding extends ConsumerStatefulWidget {
  const HalamanOnboarding({super.key});

  @override
  ConsumerState<HalamanOnboarding> createState() => _HalamanOnboardingState();
}

class _HalamanOnboardingState extends ConsumerState<HalamanOnboarding> {
  final PageController _pengaturHalaman = PageController();
  int _indeks = 0;

  @override
  void dispose() {
    _pengaturHalaman.dispose();
    super.dispose();
  }

  Future<void> _selesai() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(StorageKeys.onboardingTerlihat, true);
    if (!mounted) return;
    context.go(NamaRute.masuk);
  }

  void _berikut(int total) {
    if (_indeks == total - 1) {
      _selesai();
    } else {
      _pengaturHalaman.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  List<_Slide> _slideList(Teks t) {
    return [
      _Slide(
        judul: t.onboardingJudul1,
        deskripsi: t.onboardingDesc1,
        ikon: HugeIcons.strokeRoundedSmartPhone01,
      ),
      _Slide(
        judul: t.onboardingJudul2,
        deskripsi: t.onboardingDesc2,
        ikon: HugeIcons.strokeRoundedSecurityCheck,
      ),
      _Slide(
        judul: t.onboardingJudul3,
        deskripsi: t.onboardingDesc3,
        ikon: HugeIcons.strokeRoundedClock01,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);
    final slide = _slideList(t);
    return Scaffold(
      backgroundColor: Warna.permukaan,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Jarak.sm, vertical: Jarak.sm),
                child: TextButton(
                  onPressed: _selesai,
                  child: Text(t.lewati),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pengaturHalaman,
                itemCount: slide.length,
                onPageChanged: (i) => setState(() => _indeks = i),
                itemBuilder: (_, i) {
                  final s = slide[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Jarak.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Warna.primerLembut,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(s.ikon, size: 44, color: Warna.primer),
                        ),
                        const SizedBox(height: Jarak.xxl),
                        Text(s.judul, style: context.teks.headlineMedium),
                        const SizedBox(height: Jarak.md),
                        Text(
                          s.deskripsi,
                          style: context.teks.bodyLarge?.copyWith(color: Warna.teksKedua),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Jarak.xxl),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pengaturHalaman,
                    count: slide.length,
                    effect: const ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                      activeDotColor: Warna.primer,
                      dotColor: Warna.netral200,
                    ),
                  ),
                  const SizedBox(height: Jarak.xl),
                  TombolUtama(
                    label: _indeks == slide.length - 1 ? t.mulaiSekarang : t.lanjut,
                    saatTekan: () => _berikut(slide.length),
                  ),
                  const SizedBox(height: Jarak.sm),
                  TombolGaris(
                    label: t.sayaSudahMemilikiAkun,
                    saatTekan: () => context.go(NamaRute.masuk),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
