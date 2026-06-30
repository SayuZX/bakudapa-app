import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bakudapa_mobile/core/router/nama_rute.dart';
import 'package:bakudapa_mobile/core/router/navigasi_aman.dart';
import 'package:bakudapa_mobile/core/router/rute_aplikasi.dart';
import 'package:bakudapa_mobile/core/system/model_status_maintenance.dart';
import 'package:bakudapa_mobile/core/theme/tema.dart';
import 'package:bakudapa_mobile/features/applications/presentation/halaman_riwayat.dart';
import 'package:bakudapa_mobile/features/services/presentation/halaman_layanan.dart';
import 'package:bakudapa_mobile/shared/models/jenis_layanan.dart';
import 'package:bakudapa_mobile/shared/models/pengguna.dart';
import 'package:bakudapa_mobile/shared/providers/penyedia_maintenance.dart';
import 'package:bakudapa_mobile/shared/providers/penyedia_otentikasi.dart';

class _PengaturOtentikasiUji extends PengaturOtentikasi {
  _PengaturOtentikasiUji(super.ref) : super(mulaiOtomatis: false) {
    state = const KondisiOtentikasi(
      status: StatusOtentikasi.masuk,
      pengguna: Pengguna(
        id: '1',
        nik: '8201010101010001',
        namaLengkap: 'Penguji Navigasi',
        surel: 'penguji@bakudapa.test',
      ),
    );
  }
}

class _Perangkat {
  _Perangkat(this.router, this.wadah);

  final GoRouter router;
  final ProviderContainer wadah;
  bool _dilepas = false;

  void lepas() {
    if (_dilepas) return;
    _dilepas = true;
    wadah.dispose();
  }
}

Future<_Perangkat> _pasangAplikasi(WidgetTester tester) async {
  final wadah = ProviderContainer(
    overrides: [
      penyediaOtentikasi.overrideWith((ref) => _PengaturOtentikasiUji(ref)),
      statusMaintenanceProvider.overrideWithValue(StatusMaintenance.tidakAktif),
      aliranStatusMaintenanceProvider.overrideWith(
        (ref) => const Stream<StatusMaintenance>.empty(),
      ),
    ],
  );
  final router = wadah.read(penyediaRuteAplikasi);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: wadah,
      child: MaterialApp.router(
        routerConfig: router,
        theme: Tema.terang(),
        locale: const Locale('id', 'ID'),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 700));
  final perangkat = _Perangkat(router, wadah);
  addTearDown(perangkat.lepas);
  return perangkat;
}

Future<void> _tunggu(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _lepasAplikasi(WidgetTester tester, _Perangkat perangkat) async {
  await tester.pumpWidget(const SizedBox.shrink());
  perangkat.lepas();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('boot masuk langsung ke beranda tanpa exception', (tester) async {
    final perangkat = await _pasangAplikasi(tester);
    final router = perangkat.router;
    expect(tester.takeException(), isNull);
    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      NamaRute.beranda,
    );
    await _lepasAplikasi(tester, perangkat);
  });

  testWidgets('berpindah-pindah tab bawah cepat tanpa exception',
      (tester) async {
    final perangkat = await _pasangAplikasi(tester);
    final router = perangkat.router;
    const urutan = [
      NamaRute.riwayat,
      NamaRute.asistenAi,
      NamaRute.pemberitahuan,
      NamaRute.profil,
      NamaRute.beranda,
      NamaRute.profil,
      NamaRute.riwayat,
      NamaRute.beranda,
    ];
    for (final tujuan in urutan) {
      router.go(tujuan);
      await tester.pump(const Duration(milliseconds: 80));
      expect(tester.takeException(), isNull, reason: 'gagal di tab $tujuan');
    }
    await _tunggu(tester);
    expect(tester.takeException(), isNull);
    await _lepasAplikasi(tester, perangkat);
  });

  testWidgets('beranda → tiap permohonan → kembali tanpa exception',
      (tester) async {
    final perangkat = await _pasangAplikasi(tester);
    final router = perangkat.router;
    for (final jenis in JenisLayanan.values) {
      router.push(NamaRute.layananAwal, extra: jenis);
      await _tunggu(tester);
      expect(tester.takeException(), isNull,
          reason: 'gagal membuka awal ${jenis.slug}');

      router.push(NamaRute.formulir, extra: jenis);
      await _tunggu(tester);
      expect(tester.takeException(), isNull,
          reason: 'gagal membuka formulir ${jenis.slug}');

      router.pop();
      await _tunggu(tester);
      router.pop();
      await _tunggu(tester);
      expect(tester.takeException(), isNull,
          reason: 'gagal kembali dari ${jenis.slug}');
    }
    await _lepasAplikasi(tester, perangkat);
  });

  testWidgets('halaman pendukung dibuka bolak-balik tanpa exception',
      (tester) async {
    final perangkat = await _pasangAplikasi(tester);
    final router = perangkat.router;
    const tujuan = [
      NamaRute.layanan,
      NamaRute.pengaturan,
      NamaRute.editProfil,
      NamaRute.gantiKataSandi,
      NamaRute.panduan,
      NamaRute.bantuan,
      '${NamaRute.detailPermohonan}/birth-cert/1',
    ];
    for (final lokasi in tujuan) {
      router.push(lokasi);
      await _tunggu(tester);
      expect(tester.takeException(), isNull, reason: 'gagal membuka $lokasi');
      router.pop();
      await _tunggu(tester);
      expect(tester.takeException(), isNull, reason: 'gagal kembali $lokasi');
    }
    await _lepasAplikasi(tester, perangkat);
  });

  testWidgets(
      'regresi shell ganda: push rute anonim saat login dari halaman pushed',
      (tester) async {
    final perangkat = await _pasangAplikasi(tester);
    final router = perangkat.router;

    router.push(NamaRute.pengaturan);
    await _tunggu(tester);
    expect(tester.takeException(), isNull);

    router.push(NamaRute.lupaKataSandi);
    await _tunggu(tester);
    expect(tester.takeException(), isNull,
        reason: 'push rute anonim saat login tidak boleh menggandakan shell');

    router.pop();
    await _tunggu(tester);
    router.pop();
    await _tunggu(tester);
    expect(tester.takeException(), isNull);
    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      NamaRute.beranda,
    );
    await _lepasAplikasi(tester, perangkat);
  });

  testWidgets('push ganda lokasi sama tertahan pengaman navigasi',
      (tester) async {
    final perangkat = await _pasangAplikasi(tester);
    final router = perangkat.router;

    router.go(NamaRute.riwayat);
    await _tunggu(tester);

    final konteks = tester.element(find.byType(HalamanRiwayat));
    konteks.pushAman(NamaRute.layanan);
    konteks.pushAman(NamaRute.layanan);
    await _tunggu(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(HalamanLayanan), findsOneWidget);

    router.pop();
    await _tunggu(tester);
    expect(tester.takeException(), isNull);
    expect(find.byType(HalamanLayanan), findsNothing);
    expect(find.byType(HalamanRiwayat), findsOneWidget);
    await _lepasAplikasi(tester, perangkat);
  });
}
