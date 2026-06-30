import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/router/navigasi_aman.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/models/jenis_layanan.dart';
import '../../../shared/models/permohonan.dart';
import '../../../shared/providers/penyedia_otentikasi.dart';
import '../../../shared/providers/penyedia_pemberitahuan.dart';
import '../../../shared/providers/penyedia_permohonan.dart';
import '../../applications/presentation/widgets/baris_permohonan.dart';
import 'widgets/kartu_ringkasan.dart';
import 'widgets/kerangka_beranda.dart';
import 'widgets/lembar_pilih_jalur_akta.dart';
import 'widgets/petak_layanan.dart';

class HalamanBeranda extends ConsumerWidget {
  const HalamanBeranda({super.key});

  String _sapaan(Teks t) {
    final jam = DateTime.now().hour;
    if (jam < 11) return t.selamatPagi;
    if (jam < 15) return t.selamatSiang;
    if (jam < 18) return t.selamatSore;
    return t.selamatMalam;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final pengguna = ref.watch(penyediaOtentikasi).pengguna;
    final riwayat = ref.watch(penyediaPengaturRiwayat);
    final ringkasan = ref.watch(penyediaRingkasanStatus);
    final belumDibaca = ref.watch(penyediaJumlahBelumDibaca);
    final muatAwal = riwayat.isLoading && riwayat.valueOrNull == null;

    return Scaffold(
      backgroundColor: Warna.latar,
      body: RefreshIndicator(
        color: Warna.primer,
        onRefresh: () => ref.read(penyediaPengaturRiwayat.notifier).segarkan(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: _Kepala(
                sapaan: _sapaan(t),
                nama: pengguna?.namaLengkap ?? t.wargaMalut,
                inisial: pengguna?.inisial ?? '?',
                jumlahNotifikasi: belumDibaca,
              ),
            ),
            if (muatAwal)
              const SliverToBoxAdapter(child: KerangkaBeranda())
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Jarak.layarH,
                    Jarak.xs,
                    Jarak.layarH,
                    Jarak.xxl,
                  ),
                  child: KartuRingkasan(
                    ringkasan: ringkasan,
                    memuat: riwayat.isLoading,
                    saatKetuk: () => context.go(NamaRute.riwayat),
                  )
                      .animate()
                      .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
                      .slideY(
                        begin: 0.06,
                        end: 0,
                        duration: 360.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Jarak.layarH),
                  child: _JudulBagian(
                    judul: t.layananKependudukan,
                    aksi: t.lihatSemua,
                    saatAksi: () => context.pushAman(NamaRute.layanan),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Jarak.layarH,
                    Jarak.md,
                    Jarak.layarH,
                    Jarak.xxl,
                  ),
                  child: _GridLayanan(
                    saatPilih: (jenis) => _bukaLayanan(context, jenis),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Jarak.layarH),
                  child: _JudulBagian(
                    judul: t.permohonanTerakhir,
                    aksi:
                        riwayat.valueOrNull?.isNotEmpty == true ? t.semua : null,
                    saatAksi: () => context.go(NamaRute.riwayat),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  Jarak.layarH,
                  Jarak.md,
                  Jarak.layarH,
                  Jarak.xxxl,
                ),
                sliver: _DaftarTerakhir(riwayat: riwayat),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _bukaLayanan(BuildContext context, JenisLayanan jenis) {
    if (jenis == JenisLayanan.aktaKelahiran) {
      LembarPilihJalurAkta.tampilkan(context);
      return;
    }
    context.pushAman(
      NamaRute.layananAwal,
      extra: RingkasanLayanan.dariJenis(jenis),
    );
  }
}

class _Kepala extends StatelessWidget {
  const _Kepala({
    required this.sapaan,
    required this.nama,
    required this.inisial,
    required this.jumlahNotifikasi,
  });

  final String sapaan;
  final String nama;
  final String inisial;
  final int jumlahNotifikasi;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Warna.latar,
      padding: EdgeInsets.fromLTRB(
        Jarak.layarH,
        context.aman.top + Jarak.lg,
        Jarak.layarH,
        Jarak.xl,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Warna.primerLembut,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              inisial,
              style: context.teks.titleSmall?.copyWith(
                color: Warna.primerGelap,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: Jarak.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sapaan,
                  style: context.teks.bodySmall?.copyWith(
                    color: Warna.teksKetiga,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.teks.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Jarak.sm),
          _TombolIkonKepala(
            ikon: HugeIcons.strokeRoundedNotification01,
            lencana: jumlahNotifikasi,
            saatTekan: () => context.go(NamaRute.pemberitahuan),
          ),
        ],
      ),
    );
  }
}

class _TombolIkonKepala extends StatelessWidget {
  const _TombolIkonKepala({
    required this.ikon,
    required this.saatTekan,
    this.lencana = 0,
  });

  final IconData ikon;
  final VoidCallback saatTekan;
  final int lencana;

  @override
  Widget build(BuildContext context) {
    final tombol = Material(
      color: Warna.permukaan,
      shape: const CircleBorder(side: BorderSide(color: Warna.garis)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: saatTekan,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(ikon, size: 21, color: Warna.teksUtama),
        ),
      ),
    );
    if (lencana <= 0) return tombol;
    return Badge(
      label: Text(lencana > 9 ? '9+' : '$lencana'),
      backgroundColor: Warna.bahaya,
      offset: const Offset(-4, 4),
      child: tombol,
    );
  }
}

class _JudulBagian extends StatelessWidget {
  const _JudulBagian({required this.judul, this.aksi, this.saatAksi});

  final String judul;
  final String? aksi;
  final VoidCallback? saatAksi;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            judul,
            style: context.teks.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (aksi != null)
          GestureDetector(
            onTap: saatAksi,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Jarak.xs),
              child: Text(
                aksi!,
                style: context.teks.labelLarge?.copyWith(
                  color: Warna.primer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _GridLayanan extends StatelessWidget {
  const _GridLayanan({required this.saatPilih});

  final void Function(JenisLayanan) saatPilih;

  static const _utama = [
    JenisLayanan.aktaKelahiran,
    JenisLayanan.aktaKematian,
    JenisLayanan.kkTambahAnak,
    JenisLayanan.kkCetakUlang,
    JenisLayanan.kkPerubahanBiodata,
    JenisLayanan.kia,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Warna.permukaan,
        borderRadius: BorderRadius.circular(Sudut.lg),
        border: Border.all(color: Warna.garis),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Jarak.sm,
        vertical: Jarak.lg,
      ),
      child: Column(
        children: [
          for (var baris = 0; baris < 2; baris++) ...[
            if (baris == 1) const SizedBox(height: Jarak.xl),
            Row(
              children: [
                for (var kolom = 0; kolom < 3; kolom++)
                  Expanded(
                    child: PetakLayanan(
                      jenis: _utama[baris * 3 + kolom],
                      saatKetuk: () => saatPilih(_utama[baris * 3 + kolom]),
                    )
                        .animate(delay: ((baris * 3 + kolom) * 40).ms)
                        .fadeIn(duration: 280.ms, curve: Curves.easeOutCubic)
                        .slideY(
                          begin: 0.08,
                          end: 0,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DaftarTerakhir extends ConsumerWidget {
  const _DaftarTerakhir({required this.riwayat});

  final AsyncValue<List<Permohonan>> riwayat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return riwayat.when(
      loading: () => const SliverToBoxAdapter(
        child: Column(
          children: [
            KerangkaBarisPermohonan(),
            SizedBox(height: Jarak.md),
            KerangkaBarisPermohonan(),
          ],
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: _KosongTerakhir(
          pesan: ref.watch(teksProvider).berandaGagalMuat,
          ikon: HugeIcons.strokeRoundedWifiDisconnected01,
        ),
      ),
      data: (daftar) {
        if (daftar.isEmpty) {
          return SliverToBoxAdapter(
            child: _KosongTerakhir(
              pesan: ref.watch(teksProvider).berandaKosong,
              ikon: HugeIcons.strokeRoundedFile02,
            ),
          );
        }
        final tigaTerakhir = daftar.take(3).toList();
        return SliverList.separated(
          itemCount: tigaTerakhir.length,
          separatorBuilder: (_, _) => const SizedBox(height: Jarak.md),
          itemBuilder: (context, indeks) {
            return BarisPermohonan(permohonan: tigaTerakhir[indeks])
                .animate(delay: (indeks * 60).ms)
                .fadeIn(duration: 280.ms, curve: Curves.easeOutCubic)
                .slideY(
                  begin: 0.08,
                  end: 0,
                  duration: 320.ms,
                  curve: Curves.easeOutCubic,
                );
          },
        );
      },
    );
  }
}

class _KosongTerakhir extends StatelessWidget {
  const _KosongTerakhir({required this.pesan, required this.ikon});

  final String pesan;
  final IconData ikon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Jarak.xxl),
      decoration: BoxDecoration(
        color: Warna.permukaan,
        borderRadius: BorderRadius.circular(Sudut.lg),
        border: Border.all(color: Warna.garis),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Warna.netral50,
              shape: BoxShape.circle,
            ),
            child: Icon(ikon, size: 20, color: Warna.teksKetiga),
          ),
          const SizedBox(width: Jarak.lg),
          Expanded(
            child: Text(
              pesan,
              style: context.teks.bodySmall?.copyWith(
                color: Warna.teksKedua,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
