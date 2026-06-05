import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/config/branding.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';

class _Faq {
  const _Faq(this.tanya, this.jawab);
  final String tanya;
  final String jawab;
}

class HalamanBantuan extends ConsumerWidget {
  const HalamanBantuan({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final daftarFaq = <_Faq>[
      _Faq(t.faq1Q, t.faq1A),
      _Faq(t.faq2Q, t.faq2A),
      _Faq(t.faq3Q, t.faq3A),
      _Faq(t.faq4Q, t.faq4A),
      _Faq(t.faq5Q, t.faq5A),
      _Faq(t.faq6Q, t.faq6A),
    ];

    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(title: Text(t.pusatBantuan)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Jarak.layarH, Jarak.md, Jarak.layarH, Jarak.xxl),
          children: [
            Container(
              padding: const EdgeInsets.all(Jarak.lg),
              decoration: BoxDecoration(
                color: Warna.permukaan,
                border: Border.all(color: Warna.garis),
                borderRadius: BorderRadius.circular(Sudut.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.hubungiKami, style: context.teks.titleMedium),
                  const SizedBox(height: Jarak.md),
                  _Kontak(
                    ikon: HugeIcons.strokeRoundedMail01,
                    judul: t.emailResmi,
                    nilai: Branding.emailDukungan,
                  ),
                  const SizedBox(height: Jarak.md),
                  _Kontak(
                    ikon: HugeIcons.strokeRoundedSmartPhone01,
                    judul: t.telepon,
                    nilai: Branding.teleponDukungan,
                  ),
                  const SizedBox(height: Jarak.md),
                  _Kontak(
                    ikon: HugeIcons.strokeRoundedGlobe02,
                    judul: t.situsWeb,
                    nilai: Branding.situsWeb,
                  ),
                  const SizedBox(height: Jarak.md),
                  _Kontak(
                    ikon: HugeIcons.strokeRoundedLocation01,
                    judul: t.alamat,
                    nilai: '${Branding.namaInstansi}, ${Branding.wilayah}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: Jarak.xl),
            Text(t.pertanyaanUmumLengkap, style: context.teks.titleMedium),
            const SizedBox(height: Jarak.md),
            ...daftarFaq.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: Jarak.sm),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: Jarak.md, vertical: 4),
                    childrenPadding: const EdgeInsets.fromLTRB(Jarak.md, 0, Jarak.md, Jarak.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Sudut.md),
                      side: const BorderSide(color: Warna.garis),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Sudut.md),
                      side: const BorderSide(color: Warna.garis),
                    ),
                    title: Text(f.tanya, style: context.teks.titleSmall),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          f.jawab,
                          style: context.teks.bodyMedium?.copyWith(color: Warna.teksKedua),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Kontak extends StatelessWidget {
  const _Kontak({required this.ikon, required this.judul, required this.nilai});
  final IconData ikon;
  final String judul;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Warna.netral100,
            borderRadius: BorderRadius.circular(Sudut.sm),
          ),
          child: Icon(ikon, size: 18),
        ),
        const SizedBox(width: Jarak.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(judul, style: context.teks.labelMedium?.copyWith(color: Warna.teksKedua)),
              Text(nilai, style: context.teks.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
