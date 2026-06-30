import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/router/navigasi_aman.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/providers/penyedia_otentikasi.dart';

class HalamanProfil extends ConsumerWidget {
  const HalamanProfil({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final pengguna = ref.watch(penyediaOtentikasi).pengguna;

    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(title: Text(t.tabProfil)),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          Jarak.layarH,
          Jarak.sm,
          Jarak.layarH,
          Jarak.xxxl,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(Jarak.xl),
            decoration: BoxDecoration(
              color: Warna.permukaan,
              borderRadius: BorderRadius.circular(Sudut.lg),
              border: Border.all(color: Warna.garis),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Warna.primerLembut,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    pengguna?.inisial ?? '?',
                    style: context.teks.titleLarge?.copyWith(
                      color: Warna.primerGelap,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: Jarak.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pengguna?.namaLengkap ?? '—',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.teks.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (pengguna?.username != null &&
                          pengguna!.username!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '@${pengguna.username}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.teks.bodySmall?.copyWith(
                            color: Warna.primer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        pengguna?.surel ?? pengguna?.nik ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.teks.bodySmall?.copyWith(
                          color: Warna.teksKedua,
                        ),
                      ),
                      if (pengguna?.domisili != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              HugeIcons.strokeRoundedLocation01,
                              size: 13,
                              color: Warna.teksKetiga,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                pengguna!.domisili!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.teks.bodySmall?.copyWith(
                                  color: Warna.teksKetiga,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (pengguna?.terverifikasi == true) ...[
                        const SizedBox(height: Jarak.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Warna.suksesLembut,
                            borderRadius: BorderRadius.circular(Sudut.pil),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                HugeIcons.strokeRoundedCheckmarkBadge02,
                                size: 13,
                                color: Warna.sukses,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                t.akunTerverifikasi,
                                style: context.teks.labelSmall?.copyWith(
                                  color: Warna.sukses,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 280.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: Jarak.xl),
          _MenuProfil(
            barisan: [
              _ItemMenu(
                ikon: HugeIcons.strokeRoundedUserEdit01,
                label: t.dataPribadi,
                keterangan: t.dataPribadiSub,
                saatKetuk: () => context.pushAman(NamaRute.editProfil),
              ),
              _ItemMenu(
                ikon: HugeIcons.strokeRoundedSetting06,
                label: t.pengaturan,
                keterangan: t.pengaturanSub,
                saatKetuk: () => context.pushAman(NamaRute.pengaturan),
              ),
              _ItemMenu(
                ikon: HugeIcons.strokeRoundedCustomerService01,
                label: t.pusatBantuan,
                keterangan: t.pusatBantuanSub,
                saatKetuk: () => context.pushAman(NamaRute.bantuan),
              ),
              _ItemMenu(
                ikon: HugeIcons.strokeRoundedBook02,
                label: t.panduanPengguna,
                keterangan: t.panduanLayananSub,
                saatKetuk: () => context.pushAman(NamaRute.panduan),
              ),
            ],
          ).animate(delay: 60.ms).fadeIn(duration: 280.ms),
          const SizedBox(height: Jarak.xl),
          _MenuProfil(
            barisan: [
              _ItemMenu(
                ikon: HugeIcons.strokeRoundedShield01,
                label: t.kebijakanPrivasi,
                saatKetuk: () => context.pushAman(NamaRute.kebijakanPrivasi),
              ),
              _ItemMenu(
                ikon: HugeIcons.strokeRoundedFileAttachment,
                label: t.syaratKetentuan,
                saatKetuk: () => context.pushAman(NamaRute.syaratKetentuan),
              ),
            ],
          ).animate(delay: 120.ms).fadeIn(duration: 280.ms),
        ],
      ),
    );
  }
}

class _ItemMenu {
  const _ItemMenu({
    required this.ikon,
    required this.label,
    this.keterangan,
    required this.saatKetuk,
  });

  final IconData ikon;
  final String label;
  final String? keterangan;
  final VoidCallback saatKetuk;
}

class _MenuProfil extends StatelessWidget {
  const _MenuProfil({required this.barisan});

  final List<_ItemMenu> barisan;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Warna.permukaan,
        borderRadius: BorderRadius.circular(Sudut.lg),
        border: Border.all(color: Warna.garis),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < barisan.length; i++) ...[
            if (i > 0) const Divider(indent: 64, color: Warna.pemisah),
            InkWell(
              onTap: barisan[i].saatKetuk,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Jarak.lg,
                  vertical: Jarak.md,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Warna.netral50,
                        borderRadius: BorderRadius.circular(Sudut.sm),
                      ),
                      child: Icon(
                        barisan[i].ikon,
                        size: 19,
                        color: Warna.teksUtama,
                      ),
                    ),
                    const SizedBox(width: Jarak.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            barisan[i].label,
                            style: context.teks.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (barisan[i].keterangan != null)
                            Text(
                              barisan[i].keterangan!,
                              style: context.teks.labelSmall?.copyWith(
                                color: Warna.teksKetiga,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(
                      HugeIcons.strokeRoundedArrowRight01,
                      size: 17,
                      color: Warna.teksKetiga,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
