import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/errors/kesalahan.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/models/jenis_layanan.dart';
import '../../../shared/widgets/kondisi_galat.dart';
import '../../../shared/widgets/kondisi_kosong.dart';
import '../../services/providers/penyedia_layanan.dart';

class HalamanPanduan extends ConsumerWidget {
  const HalamanPanduan({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Warna.latar,
        appBar: AppBar(
          title: Text(t.panduanPengguna),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: t.tabMemulai),
              Tab(text: t.tabLayanan),
              Tab(text: t.tabKeamanan),
            ],
            indicatorColor: Warna.primer,
            labelColor: Warna.primer,
            unselectedLabelColor: Warna.teksKedua,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Warna.garis,
          ),
        ),
        body: const SafeArea(
          top: false,
          child: TabBarView(
            children: [
              _TabMemulai(),
              _TabLayanan(),
              _TabKeamanan(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabMemulai extends StatelessWidget {
  const _TabMemulai();

  static const _langkah = <_Langkah>[
    _Langkah(
      ikon: HugeIcons.strokeRoundedUserAdd01,
      judul: '1. Daftar Akun',
      isi: 'Buka halaman Daftar, isi NIK 16 digit, nama lengkap sesuai KTP, email aktif, nomor HP, dan kata sandi yang kuat (minimal 8 karakter, ada huruf besar dan angka).',
    ),
    _Langkah(
      ikon: HugeIcons.strokeRoundedSecurityCheck,
      judul: '2. Verifikasi Akun',
      isi: 'Setelah mendaftar, masukkan kode 6 digit yang dikirim ke email Anda. Jika tidak menerima kode, ketuk "Kirim ulang kode" setelah waktu hitung mundur selesai.',
    ),
    _Langkah(
      ikon: HugeIcons.strokeRoundedHome01,
      judul: '3. Jelajahi Beranda',
      isi: 'Di beranda Anda akan melihat ringkasan status permohonan, pintasan layanan, serta pengumuman penting dari Disdukcapil.',
    ),
    _Langkah(
      ikon: HugeIcons.strokeRoundedFile02,
      judul: '4. Ajukan Layanan',
      isi: 'Buka menu Layanan, pilih jenis layanan, baca petunjuk, lalu ketuk "Ajukan Sekarang" untuk mengisi formulir dan mengunggah dokumen.',
    ),
    _Langkah(
      ikon: HugeIcons.strokeRoundedClock01,
      judul: '5. Pantau Status',
      isi: 'Status permohonan diperbarui secara berkala. Buka menu Riwayat untuk melihat semua permohonan Anda, atau ketuk pemberitahuan saat ada pembaruan.',
    ),
    _Langkah(
      ikon: HugeIcons.strokeRoundedDownload01,
      judul: '6. Unduh Hasil',
      isi: 'Jika permohonan telah Selesai, tombol "Unduh Dokumen Hasil" akan tersedia di detail permohonan.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(Jarak.layarH, Jarak.md, Jarak.layarH, Jarak.xxl),
      itemCount: _langkah.length,
      separatorBuilder: (_, _) => const SizedBox(height: Jarak.md),
      itemBuilder: (_, i) => _KartuLangkah(langkah: _langkah[i]),
    );
  }
}

class _TabLayanan extends ConsumerWidget {
  const _TabLayanan();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final daftar = ref.watch(penyediaDaftarLayanan(const FilterDaftarLayanan()));
    return daftar.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => KondisiGalat(
        pesan: pesanRamah(e, fallback: t.terjadiKesalahan, teks: t),
        saatCobaLagi: () => ref.invalidate(
          penyediaDaftarLayanan(const FilterDaftarLayanan()),
        ),
      ),
      data: (layanan) {
        if (layanan.isEmpty) {
          return KondisiKosong(judul: t.tidakAdaLayanan);
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(Jarak.layarH, Jarak.md, Jarak.layarH, Jarak.xxl),
          itemCount: layanan.length,
          separatorBuilder: (_, _) => const SizedBox(height: Jarak.md),
          itemBuilder: (_, i) => _KartuLayananPanduan(layanan: layanan[i]),
        );
      },
    );
  }
}

class _KartuLayananPanduan extends ConsumerWidget {
  const _KartuLayananPanduan({required this.layanan});

  final RingkasanLayanan layanan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: Jarak.md),
      childrenPadding: const EdgeInsets.fromLTRB(Jarak.md, 0, Jarak.md, Jarak.md),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sudut.md),
        side: const BorderSide(color: Warna.garis),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sudut.md),
        side: const BorderSide(color: Warna.garis),
      ),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Warna.netral100,
          borderRadius: BorderRadius.circular(Sudut.sm),
        ),
        child: Icon(layanan.ikon, size: 20),
      ),
      title: Text(t.katalog(layanan.nama), style: context.teks.titleSmall),
      subtitle: Text(
        t.katalog(layanan.deskripsiTampil),
        style: context.teks.bodySmall?.copyWith(color: Warna.teksKedua),
      ),
      children: [_RincianLayananPanduan(kode: layanan.kode)],
    );
  }
}

class _RincianLayananPanduan extends ConsumerWidget {
  const _RincianLayananPanduan({required this.kode});

  final String kode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final detail = ref.watch(penyediaDetailLayanan(kode));
    return detail.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: Jarak.md),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          pesanRamah(e, fallback: t.terjadiKesalahan, teks: t),
          style: context.teks.bodySmall?.copyWith(color: Warna.bahaya),
        ),
      ),
      data: (layanan) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (k, syarat) in t.daftarKatalog(layanan.persyaratanTeks).indexed) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Warna.primerLembut,
                    borderRadius: BorderRadius.circular(Sudut.pil),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${k + 1}',
                    style: context.teks.labelSmall?.copyWith(
                      color: Warna.primer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: Jarak.sm),
                Expanded(
                  child: Text(syarat, style: context.teks.bodyMedium),
                ),
              ],
            ),
            const SizedBox(height: Jarak.sm),
          ],
          if (layanan.slotDokumen.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              t.dokumenDisiapkan,
              style: context.teks.titleSmall?.copyWith(color: Warna.teksKedua),
            ),
            const SizedBox(height: Jarak.sm),
            for (final b in layanan.slotDokumen)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(HugeIcons.strokeRoundedCheckmarkCircle02,
                        color: Warna.sukses, size: 16),
                    const SizedBox(width: Jarak.sm),
                    Expanded(
                      child: Text(
                        '${t.katalog(b.label)}${b.wajib ? '' : ' (${t.opsional})'}',
                        style: context.teks.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _TabKeamanan extends StatelessWidget {
  const _TabKeamanan();

  static const _tips = <_Langkah>[
    _Langkah(
      ikon: HugeIcons.strokeRoundedLockPassword,
      judul: 'Jaga Kerahasiaan Kata Sandi',
      isi: 'Jangan pernah membagikan kata sandi, OTP, atau kode verifikasi kepada siapa pun, termasuk yang mengaku petugas Disdukcapil.',
    ),
    _Langkah(
      ikon: HugeIcons.strokeRoundedFingerPrintScan,
      judul: 'Aktifkan Biometrik',
      isi: 'Gunakan sidik jari atau wajah pada pengaturan untuk mempersulit akses oleh orang lain.',
    ),
    _Langkah(
      ikon: HugeIcons.strokeRoundedAlertCircle,
      judul: 'Waspadai Penipuan',
      isi: 'BAKUDAPA tidak meminta pembayaran melalui rekening pribadi. Jika diminta, laporkan melalui Pengaduan Masyarakat.',
    ),
    _Langkah(
      ikon: HugeIcons.strokeRoundedLogout01,
      judul: 'Keluar Saat Selesai',
      isi: 'Jika menggunakan HP bersama, pastikan keluar dari akun setelah selesai. Sesi otomatis berakhir setelah 10 menit tidak aktif.',
    ),
    _Langkah(
      ikon: HugeIcons.strokeRoundedShieldUser,
      judul: 'Perbarui Aplikasi',
      isi: 'Selalu gunakan versi terbaru untuk mendapat pembaruan keamanan.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(Jarak.layarH, Jarak.md, Jarak.layarH, Jarak.xxl),
      itemCount: _tips.length,
      separatorBuilder: (_, _) => const SizedBox(height: Jarak.md),
      itemBuilder: (_, i) => _KartuLangkah(langkah: _tips[i]),
    );
  }
}

class _Langkah {
  const _Langkah({required this.ikon, required this.judul, required this.isi});
  final IconData ikon;
  final String judul;
  final String isi;
}

class _KartuLangkah extends StatelessWidget {
  const _KartuLangkah({required this.langkah});
  final _Langkah langkah;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Jarak.lg),
      decoration: BoxDecoration(
        color: Warna.permukaan,
        border: Border.all(color: Warna.garis),
        borderRadius: BorderRadius.circular(Sudut.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Warna.primerLembut,
              borderRadius: BorderRadius.circular(Sudut.md),
            ),
            child: Icon(langkah.ikon, color: Warna.primer, size: 22),
          ),
          const SizedBox(width: Jarak.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(langkah.judul, style: context.teks.titleSmall),
                const SizedBox(height: 4),
                Text(
                  langkah.isi,
                  style: context.teks.bodyMedium?.copyWith(color: Warna.teksKedua, height: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
