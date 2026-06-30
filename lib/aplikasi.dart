import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'core/theme/warna.dart';

import 'core/activity/layanan_pencatat_aktivitas.dart';
import 'core/config/branding.dart';
import 'core/dialogs/dialog_aplikasi.dart';
import 'core/localization/teks.dart';
import 'core/network/klien_jaringan.dart';
import 'core/router/nama_rute.dart';
import 'core/router/rute_aplikasi.dart';
import 'core/security/layanan_audit_keamanan.dart';
import 'core/services/layanan_tautan_dalam.dart';
import 'core/system/layanan_konfigurasi_sistem.dart';
import 'shared/providers/penyedia_otentikasi.dart';
import 'core/theme/tema.dart';
import 'core/utils/format.dart';
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

class _AplikasiBakudapaState extends ConsumerState<AplikasiBakudapa>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() => LayananKonfigurasiSistem.instance.ambil());
    LayananAuditKeamanan.instance.mulaiPemantauanKonektivitas();
    Future.microtask(() => LayananAuditKeamanan.instance.flushAntrean());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LayananTautanDalam.instance.mulai(_tanganiTautan);
    });
  }

  @override
  void dispose() {
    LayananTautanDalam.instance.hentikan();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _tanganiTautan(Uri tautan) {
    if (!mounted) return;
    final token = LayananTautanDalam.tokenResetDari(tautan);
    if (token == null) return;
    ref.read(penyediaRuteAplikasi).push(
          NamaRute.resetKataSandiBaru,
          extra: token,
        );
  }

  bool _dilatarBelakang = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      LayananPencatatAktivitas.instance.flush();
    }
    final sembunyikan = state != AppLifecycleState.resumed;
    if (sembunyikan != _dilatarBelakang) {
      setState(() => _dilatarBelakang = sembunyikan);
    }
    super.didChangeAppLifecycleState(state);
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
    Format.pasang(bahasa.locale.toString(), teks);

    final peringatanVpn = ref.watch(
      penyediaOtentikasi.select((k) => k.peringatanVpn),
    );
    if (peringatanVpn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final ctx = DialogAplikasi.kunciNavigatorRoot.currentContext;
        if (ctx != null && ctx.mounted) {
          DialogAplikasi.tampilkanToast(
            ctx,
            teks.vpnAktifInformasi,
            nada: NadaDialog.peringatan,
          );
        }
        ref.read(penyediaOtentikasi.notifier).tandaiPeringatanVpnDitampilkan();
      });
    }

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
            child: Stack(
              children: [
                OverlayMuatGlobal(
                  anak: child ?? const SizedBox.shrink(),
                ),
                if (_dilatarBelakang && !kDebugMode)
                  const Positioned.fill(child: _LapisanPrivasi()),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LapisanPrivasi extends StatelessWidget {
  const _LapisanPrivasi();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Warna.permukaan,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'assets/images/logo-malut.svg',
        width: 96,
        height: 96,
        fit: BoxFit.contain,
      ),
    );
  }
}
