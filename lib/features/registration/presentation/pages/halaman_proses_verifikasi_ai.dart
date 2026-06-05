import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../core/dialogs/dialog_aplikasi.dart';
import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/router/nama_rute.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../providers/penyedia_registrasi.dart';

class HalamanProsesVerifikasiAi extends ConsumerStatefulWidget {
  const HalamanProsesVerifikasiAi({super.key});

  @override
  ConsumerState<HalamanProsesVerifikasiAi> createState() =>
      _HalamanProsesVerifikasiAiState();
}

class _HalamanProsesVerifikasiAiState
    extends ConsumerState<HalamanProsesVerifikasiAi> {
  bool _sudahJalan = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(penyediaRegistrasi, (_, _) {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _sudahJalan) return;
      _sudahJalan = true;
      _kirimDanVerifikasi();
    });
  }

  Future<void> _kirimDanVerifikasi() async {
    final t = ref.read(teksProvider);
    final ok = await ref.read(penyediaRegistrasi.notifier).finalkan();
    if (!mounted) return;
    if (ok) {
      context.go(NamaRute.daftarSukses);
    } else {
      final pesan = ref.read(penyediaRegistrasi).pesanGalat ??
          t.gagalMengirimRegistrasi;
      await DialogAplikasi.tampilkanAlert<void>(
        context: context,
        judul: t.registrasiDitolak,
        pesan: pesan,
        nada: NadaDialog.bahaya,
      );
      if (!mounted) return;
      context.go(NamaRute.daftarKebijakan);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Warna.permukaan,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Jarak.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 3),
                Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    color: Warna.merahUtama,
                    size: 64,
                  ),
                ),
                const SizedBox(height: Jarak.xxl),
                Text(
                  t.prosesVerifikasiAiJudul,
                  textAlign: TextAlign.center,
                  style: context.teks.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: Jarak.sm),
                Text(
                  t.prosesVerifikasiAiSub,
                  textAlign: TextAlign.center,
                  style: context.teks.bodyMedium?.copyWith(
                    color: Warna.teksKedua,
                    height: 1.6,
                  ),
                ),
                const Spacer(flex: 4),
                Text(
                  t.jangantutupHalamanIni,
                  textAlign: TextAlign.center,
                  style: context.teks.labelSmall?.copyWith(
                    color: Warna.teksKedua,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: Jarak.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
