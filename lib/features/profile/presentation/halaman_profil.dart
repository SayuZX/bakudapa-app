import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/dialogs/dialog_aplikasi.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../core/utils/penyamaran.dart';
import '../../../shared/providers/penyedia_otentikasi.dart';

class HalamanProfil extends ConsumerWidget {
  const HalamanProfil({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pengguna = ref.watch(penyediaOtentikasi).pengguna;
    final t = ref.watch(teksProvider);

    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(title: Text(t.profil)),
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
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Warna.merahLembut,
                    child: Text(
                      (pengguna?.namaLengkap.isNotEmpty ?? false)
                          ? pengguna!.namaLengkap.substring(0, 1).toUpperCase()
                          : 'P',
                      style: context.teks.headlineSmall?.copyWith(color: Warna.merahUtama),
                    ),
                  ),
                  const SizedBox(width: Jarak.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pengguna?.namaLengkap ?? t.tanpaNama,
                          style: context.teks.titleMedium,
                        ),
                        Text(
                          pengguna?.nik != null ? Penyamaran.nik(pengguna!.nik) : '-',
                          style: context.teks.bodySmall?.copyWith(color: Warna.teksKedua),
                        ),
                        const SizedBox(height: 4),
                        if (pengguna?.terverifikasi == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Warna.suksesLembut,
                              borderRadius: BorderRadius.circular(Sudut.pil),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(HugeIcons.strokeRoundedCheckmarkCircle02,
                                    size: 12, color: Warna.sukses),
                                const SizedBox(width: 4),
                                Text(t.terverifikasi,
                                    style: context.teks.labelSmall?.copyWith(color: Warna.sukses)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Jarak.xl),
            Text(t.akunDanKeamanan, style: context.teks.titleSmall),
            const SizedBox(height: Jarak.sm),
            _Item(
              ikon: HugeIcons.strokeRoundedUser,
              judul: t.dataPribadi,
              subJudul: t.dataPribadiSub,
              saatKetuk: () {},
            ),
            _Item(
              ikon: HugeIcons.strokeRoundedSecurityCheck,
              judul: t.keamananAkun,
              subJudul: t.keamananAkunSub,
              saatKetuk: () => context.push(NamaRute.pengaturan),
            ),
            _Item(
              ikon: HugeIcons.strokeRoundedNotification01,
              judul: t.pemberitahuan,
              subJudul: t.pemberitahuanSub,
              saatKetuk: () => context.push(NamaRute.pengaturan),
            ),
            const SizedBox(height: Jarak.lg),
            Text(t.bantuanDanInformasi, style: context.teks.titleSmall),
            const SizedBox(height: Jarak.sm),
            _Item(
              ikon: HugeIcons.strokeRoundedBookmark01,
              judul: t.panduanPengguna,
              subJudul: t.tutorialMenggunakanApp,
              saatKetuk: () => context.push(NamaRute.panduan),
            ),
            _Item(
              ikon: HugeIcons.strokeRoundedHelpCircle,
              judul: t.pusatBantuan,
              subJudul: t.hubungiKamiAtauFaq,
              saatKetuk: () => context.push(NamaRute.bantuan),
            ),
            _Item(
              ikon: HugeIcons.strokeRoundedShieldUser,
              judul: t.kebijakanPrivasi,
              subJudul: t.kebijakanPrivasiSub,
              saatKetuk: () => context.push(NamaRute.kebijakanPrivasi),
            ),
            _Item(
              ikon: HugeIcons.strokeRoundedFile02,
              judul: t.kebijakanLayanan,
              subJudul: t.kebijakanLayananSub,
              saatKetuk: () => context.push(NamaRute.kebijakanLayanan),
            ),
            _Item(
              ikon: HugeIcons.strokeRoundedAlert02,
              judul: t.penafianKetersediaanSistem,
              subJudul: t.pernyataanKetersediaan,
              saatKetuk: () => context.push(NamaRute.penafianSistem),
            ),
            const SizedBox(height: Jarak.xl),
            OutlinedButton.icon(
              onPressed: () async {
                final yakin = await DialogAplikasi.tampilkanKonfirmasi(
                  context: context,
                  judul: t.keluarDariAplikasi,
                  pesan: t.andaAkanKeluarSesi,
                  labelBatal: t.batal,
                  labelKonfirmasi: t.keluar,
                  destruktif: true,
                  nada: NadaDialog.peringatan,
                );
                if (yakin && context.mounted) {
                  await ref.read(penyediaOtentikasi.notifier).keluar();
                  if (context.mounted) {
                    context.tampilkanSukses(t.andaTelahKeluar);
                  }
                }
              },
              icon: const Icon(HugeIcons.strokeRoundedLogout01, color: Warna.bahaya, size: 18),
              label: Text(t.keluar, style: context.teks.titleMedium?.copyWith(color: Warna.bahaya)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                side: const BorderSide(color: Warna.bahaya),
              ),
            ),
            const SizedBox(height: Jarak.xl),
            Center(
              child: Text(
                t.versiAplikasi,
                style: context.teks.labelSmall?.copyWith(color: Warna.teksKetiga),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.ikon,
    required this.judul,
    required this.subJudul,
    required this.saatKetuk,
  });
  final IconData ikon;
  final String judul;
  final String subJudul;
  final VoidCallback saatKetuk;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Warna.permukaan,
      borderRadius: BorderRadius.circular(Sudut.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(Sudut.md),
        onTap: saatKetuk,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Jarak.md, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Warna.netral100,
                  borderRadius: BorderRadius.circular(Sudut.sm),
                ),
                child: Icon(ikon, color: Warna.teksUtama, size: 20),
              ),
              const SizedBox(width: Jarak.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(judul, style: context.teks.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      subJudul,
                      style: context.teks.bodySmall?.copyWith(color: Warna.teksKedua),
                    ),
                  ],
                ),
              ),
              const Icon(HugeIcons.strokeRoundedArrowRight01,
                  size: 18, color: Warna.teksKetiga),
            ],
          ),
        ),
      ),
    );
  }
}
