import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'aplikasi.dart';
import 'core/dialogs/dialog_aplikasi.dart';
import 'core/network/klien_jaringan.dart';
import 'core/services/migrasi_kunci_simpanan.dart';
import 'shared/providers/penyedia_otentikasi.dart';
import 'shared/widgets/mesin_restart.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
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
    await DialogAplikasi.tampilkanAlert<void>(
      judul: 'Sesi Berakhir',
      pesan:
          'Sesi Anda telah berakhir untuk menjaga keamanan akun. Silakan masuk kembali untuk melanjutkan.',
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
