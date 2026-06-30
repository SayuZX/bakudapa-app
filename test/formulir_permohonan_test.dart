import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bakudapa_mobile/core/theme/tema.dart';
import 'package:bakudapa_mobile/features/services/domain/detail_layanan.dart';
import 'package:bakudapa_mobile/features/services/domain/repositori_layanan.dart';
import 'package:bakudapa_mobile/features/services/presentation/halaman_formulir_permohonan.dart';
import 'package:bakudapa_mobile/features/services/providers/penyedia_layanan.dart';
import 'package:bakudapa_mobile/shared/models/jenis_layanan.dart';
import 'package:bakudapa_mobile/shared/providers/penyedia_bahasa.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _skemaServer(String kode) => {
      'kode': kode,
      'nama': 'Layanan Uji',
      'estimasi_menit': 10,
      'formulir': [
        {
          'judul': 'Data Pemohon',
          'ruas': [
            {
              'kunci': 'nama_pemohon',
              'label': 'Nama Pemohon',
              'tipe': 'teks',
              'wajib': true,
              'panjang_maks': 60,
            },
            {
              'kunci': 'jenis_kelamin',
              'label': 'Jenis Kelamin',
              'tipe': 'pilihan',
              'wajib': true,
              'placeholder': 'Pilih jenis kelamin',
              'pilihan': [
                {'nilai': 'L', 'label': 'Laki-laki'},
                {'nilai': 'P', 'label': 'Perempuan'},
              ],
            },
            {
              'kunci': 'tanggal_lahir',
              'label': 'Tanggal Lahir',
              'tipe': 'tanggal',
              'wajib': true,
            },
          ],
        },
      ],
      'persyaratan': [
        {'teks': 'Kartu Keluarga (KK)', 'wajib': true},
      ],
    };

class _RepositoriLayananUji implements RepositoriLayanan {
  @override
  Future<List<RingkasanLayanan>> mintaDaftar({String? cari, String? kategori}) async =>
      const [];

  @override
  Future<DetailLayanan> mintaDetail(String kodeLayanan) async =>
      DetailLayanan.dariJson(_skemaServer(kodeLayanan), kode: kodeLayanan);
}

Future<ProviderContainer> _pasangFormulir(
  WidgetTester tester,
  JenisLayanan jenis,
) async {
  final wadah = ProviderContainer(
    overrides: [
      penyediaRepositoriLayanan.overrideWithValue(_RepositoriLayananUji()),
    ],
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
        home: HalamanFormulirPermohonan(
          ringkasan: RingkasanLayanan.dariJenis(jenis),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 600));
  return wadah;
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('ganti bahasa langsung mengubah seluruh teks formulir',
      (tester) async {
    final wadah = await _pasangFormulir(tester, JenisLayanan.kia);

    expect(find.text('Langkah 1 dari 3'), findsOneWidget);
    expect(find.text('Jenis Kelamin'), findsOneWidget);

    await wadah.read(penyediaBahasa.notifier).ubah(KodeBahasa.en);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Step 1 of 3'), findsOneWidget);
    expect(find.text('Gender'), findsOneWidget);
    expect(find.text('Langkah 1 dari 3'), findsNothing);

    await wadah.read(penyediaBahasa.notifier).ubah(KodeBahasa.id);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Langkah 1 dari 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'field pilihan/tanggal: hint tunggal tanpa tumpukan, nilai tampil setelah dipilih',
      (tester) async {
    await _pasangFormulir(tester, JenisLayanan.aktaKelahiran);

    expect(find.text('Langkah 1 dari 3'), findsOneWidget);
    expect(find.text('Jenis Kelamin'), findsOneWidget);
    expect(find.text('Pilih jenis kelamin'), findsOneWidget);
    expect(find.text('Jenis Kelamin *'), findsNothing);

    await tester.tap(
      find
          .ancestor(
            of: find.text('Pilih jenis kelamin'),
            matching: find.byType(InkWell),
          )
          .first,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Laki-laki'), findsOneWidget);

    await tester.tap(find.text('Laki-laki'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final nilaiDiField = find.descendant(
      of: find.byType(InputDecorator),
      matching: find.text('Laki-laki'),
    );
    expect(nilaiDiField, findsOneWidget);

    expect(find.text('Pilih Tanggal Lahir'), findsOneWidget);
    await tester.tap(
      find
          .ancestor(
            of: find.text('Pilih Tanggal Lahir'),
            matching: find.byType(InkWell),
          )
          .first,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('validasi langkah menahan lanjut saat isian wajib kosong',
      (tester) async {
    await _pasangFormulir(tester, JenisLayanan.kia);

    expect(find.text('Langkah 1 dari 3'), findsOneWidget);
    await tester.tap(find.text('Lanjut'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Langkah 1 dari 3'), findsOneWidget);
    expect(find.text('Nama Pemohon wajib diisi.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
