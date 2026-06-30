import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'aplikasi.dart';
import 'core/dialogs/dialog_aplikasi.dart';
import 'core/localization/teks.dart';
import 'core/network/klien_jaringan.dart';
import 'core/services/migrasi_kunci_simpanan.dart';
import 'shared/providers/penyedia_otentikasi.dart';
import 'shared/widgets/mesin_restart.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    debugPrint('FlutterError: ${details.exception}');
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform error: $error');
    return true;
  };
  await initializeDateFormatting();
  await MigrasiKunciSimpanan.jalankan();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final wadah = ProviderContainer();
  KlienJaringan.instance.daftarPenanganTidakBerwenang(() async {
    wadah.read(penyediaOtentikasi.notifier).paksaKeluar();
    final t = wadah.read(teksProvider);
    await DialogAplikasi.tampilkanAlert<void>(
      judul: t.sesiBerakhirJudul,
      pesan: t.sesiBerakhirPesan,
      nada: NadaDialog.peringatan,
    );
  });

  runApp(
    UncontrolledProviderScope(
      container: wadah,
      child: MesinRestart(
        key: MesinRestart.kunci,
        anak: const AplikasiBakudapa(),
      ),
    ),
  );
}
