import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bakudapa_mobile/core/errors/kesalahan.dart';
import 'package:bakudapa_mobile/core/theme/tema.dart';
import 'package:bakudapa_mobile/features/perangkat/domain/repositori_perangkat.dart';
import 'package:bakudapa_mobile/features/perangkat/presentation/halaman_perangkat_aktif.dart';
import 'package:bakudapa_mobile/shared/models/perangkat_aktif.dart';
import 'package:bakudapa_mobile/shared/providers/penyedia_repositori.dart';

class _RepositoriPerangkatUji implements RepositoriPerangkat {
  _RepositoriPerangkatUji(this._daftar, {this.galat = false});

  final List<PerangkatAktif> _daftar;
  final bool galat;
  final List<String> dicabut = [];

  @override
  Future<List<PerangkatAktif>> mintaDaftar() async {
    if (galat) throw const KesalahanServer('gagal muat');
    return List.of(_daftar);
  }

  @override
  Future<List<PerangkatAktif>> mintaRiwayat() async {
    if (galat) throw const KesalahanServer('gagal muat');
    return List.of(_daftar);
  }

  @override
  Future<void> cabut(String sesiId) async {
    dicabut.add(sesiId);
    _daftar.removeWhere((p) => p.sesiId == sesiId);
  }
}

Future<ProviderContainer> _pasang(
  WidgetTester tester,
  RepositoriPerangkat repo,
) async {
  final wadah = ProviderContainer(
    overrides: [penyediaRepositoriPerangkat.overrideWithValue(repo)],
  );
  addTearDown(wadah.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: wadah,
      child: MaterialApp(
        theme: Tema.terang(),
        locale: const Locale('id', 'ID'),
        supportedLocales: const [Locale('id', 'ID')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const HalamanPerangkatAktif(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
  return wadah;
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('menampilkan daftar perangkat aktif', (tester) async {
    await _pasang(
      tester,
      _RepositoriPerangkatUji([
        const PerangkatAktif(
          sesiId: 'a',
          perangkat: 'Pixel 8',
          os: 'Android 15',
          label: 'Pixel 8 · Android 15',
        ),
        const PerangkatAktif(
          sesiId: 'b',
          perangkat: 'iPhone 15',
          os: 'iOS 18',
          label: 'iPhone 15 · iOS 18',
          iniPerangkatSaatIni: true,
        ),
      ]),
    );

    expect(find.text('Pixel 8 · Android 15'), findsOneWidget);
    expect(find.text('iPhone 15 · iOS 18'), findsOneWidget);
    expect(find.text('Perangkat ini'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty state saat tidak ada perangkat lain', (tester) async {
    await _pasang(tester, _RepositoriPerangkatUji([]));
    expect(find.text('Tidak ada perangkat lain'), findsOneWidget);
  });

  testWidgets('error state menampilkan tombol coba lagi', (tester) async {
    await _pasang(tester, _RepositoriPerangkatUji([], galat: true));
    expect(find.text('Coba Lagi'), findsOneWidget);
  });

  testWidgets('logout perangkat: dialog konfirmasi lalu cabut', (tester) async {
    final repo = _RepositoriPerangkatUji([
      const PerangkatAktif(sesiId: 'a', perangkat: 'Pixel 8', os: 'Android 15'),
    ]);
    await _pasang(tester, repo);

    await tester.tap(find.byTooltip('Logout Perangkat'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Logout Perangkat?'), findsOneWidget);

    await tester.tap(find.text('Logout Perangkat').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(repo.dicabut, contains('a'));
    expect(tester.takeException(), isNull);
  });
}
