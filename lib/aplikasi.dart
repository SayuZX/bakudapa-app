import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/branding.dart';
import 'core/dialogs/dialog_aplikasi.dart';
import 'core/localization/teks.dart';
import 'core/network/klien_jaringan.dart';
import 'core/router/rute_aplikasi.dart';
import 'core/system/layanan_konfigurasi_sistem.dart';
import 'core/theme/tema.dart';
import 'core/utils/validasi.dart';
import 'shared/providers/penyedia_bahasa.dart';
import 'shared/providers/penyedia_kualitas_jaringan.dart';
import 'shared/providers/penyedia_maintenance.dart';
import 'shared/providers/penyedia_pengelola_sesi.dart';
import 'shared/providers/penyedia_toast_bahasa.dart';
import 'shared/widgets/overlay_muat_global.dart';

class AplikasiBakudapa extends ConsumerStatefulWidget {
  const AplikasiBakudapa({super.key});

  @override
  ConsumerState<AplikasiBakudapa> createState() => _AplikasiBakudapaState();
}

class _AplikasiBakudapaState extends ConsumerState<AplikasiBakudapa> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => LayananKonfigurasiSistem.instance.ambil());
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(penyediaRuteAplikasi);
    final bahasa = ref.watch(penyediaBahasa);
    final teks = ref.watch(teksProvider);
    ref.watch(layananKualitasJaringanProvider);
    ref.watch(layananStatusSistemProvider);
    ref.watch(pemicuPengelolaSesi);
    KlienJaringan.instance.aturBahasa(bahasa.kode);
    Validasi.pasang(teks);

    final perluToast = ref.watch(perluToastBahasaProvider);
    if (perluToast) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final ctx = DialogAplikasi.kunciNavigatorRoot.currentContext;
        if (ctx != null && ctx.mounted) {
          DialogAplikasi.tampilkanToast(
            ctx,
            teks.bahasaBerhasilDiubah,
            nada: NadaDialog.sukses,
          );
        }
        ref.read(perluToastBahasaProvider.notifier).state = false;
      });
    }

    return GestureDetector(
      onTap: () => ref.read(penyediaPengelolaSesi).sentuh(),
      onPanDown: (_) => ref.read(penyediaPengelolaSesi).sentuh(),
      child: MaterialApp.router(
        title: Branding.namaAplikasi,
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        theme: Tema.terang(),
        locale: bahasa.locale,
        supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(textScaler: mq.textScaler.clamp(maxScaleFactor: 1.25)),
            child: OverlayMuatGlobal(
              anak: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}
