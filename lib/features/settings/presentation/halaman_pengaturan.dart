import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/activity/layanan_pencatat_aktivitas.dart';
import '../../../core/config/info_versi.dart';
import '../../../core/dialogs/dialog_aplikasi.dart';
import '../../../core/location/layanan_jejak_lokasi.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/router/navigasi_aman.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/models/pengguna.dart';
import '../../../shared/providers/penyedia_bahasa.dart';
import '../../../shared/providers/penyedia_muat_global.dart';
import '../../../shared/providers/penyedia_otentikasi.dart';
import '../../../shared/widgets/lembar_pilih_bahasa.dart';

class HalamanPengaturan extends ConsumerWidget {
  const HalamanPengaturan({super.key});

  Future<void> _keluar(BuildContext context, WidgetRef ref) async {
    final t = ref.read(teksProvider);
    final yakin = await DialogAplikasi.tampilkanKonfirmasi(
      context: context,
      judul: t.keluarAkunJudul,
      pesan: t.keluarAkunPesan,
      labelKonfirmasi: t.keluar,
      labelBatal: t.batal,
      destruktif: true,
      nada: NadaDialog.bahaya,
    );
    if (!yakin || !context.mounted) return;
    await ref.read(penyediaMuatGlobal.notifier).jalankan(
          () => ref.read(penyediaOtentikasi.notifier).keluar(),
          judul: t.keluarAkun,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final pengguna = ref.watch(penyediaOtentikasi).pengguna;
    final bahasa = ref.watch(penyediaBahasa);
    final versiAplikasi = ref.watch(penyediaVersiAplikasi).valueOrNull;

    var indeks = 0;
    Widget animasi(Widget anak) => anak
        .animate(delay: (50 * indeks++).ms)
        .fadeIn(duration: 280.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.06, end: 0, duration: 320.ms, curve: Curves.easeOutCubic);

    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(title: Text(t.pengaturan)),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          Jarak.layarH,
          Jarak.lg,
          Jarak.layarH,
          Jarak.xxxl,
        ),
        children: [
          animasi(_KartuIdentitas(pengguna: pengguna)),
          const SizedBox(height: Jarak.xl),
          animasi(
            _KartuSeksi(
              judul: t.seksiAkun,
              baris: [
                _BarisPengaturan(
                  ikon: HugeIcons.strokeRoundedUserCircle,
                  judul: t.dataPribadi,
                  keterangan: pengguna?.namaLengkap,
                  saatKetuk: () => context.pushAman(NamaRute.editProfil),
                ),
                _BarisPengaturan(
                  ikon: HugeIcons.strokeRoundedMail01,
                  judul: t.email,
                  keterangan: pengguna?.surel ?? '—',
                ),
                _BarisPengaturan(
                  ikon: HugeIcons.strokeRoundedId,
                  judul: t.nikLabel,
                  keterangan: _samarkanNik(pengguna?.nik),
                ),
              ],
            ),
          ),
          const SizedBox(height: Jarak.xl),
          animasi(
            _KartuSeksi(
              judul: t.seksiKeamanan,
              baris: [
                _BarisPengaturan(
                  ikon: HugeIcons.strokeRoundedLockPassword,
                  judul: t.gantiKataSandiJudul,
                  keterangan: t.gantiKataSandiSub,
                  saatKetuk: () => context.pushAman(NamaRute.gantiKataSandi),
                ),
                _BarisPengaturan(
                  ikon: HugeIcons.strokeRoundedSmartPhone01,
                  judul: t.perangkatAktif,
                  keterangan: t.kelolaPerangkat,
                  saatKetuk: () =>
                      context.pushAman(NamaRute.pengaturanPerangkatAktif),
                ),
              ],
            ),
          ),
          const SizedBox(height: Jarak.xl),
          animasi(
            _KartuSeksi(
              judul: t.seksiPreferensi,
              baris: [
                _BarisPengaturan(
                  ikon: HugeIcons.strokeRoundedGlobal,
                  judul: t.bahasa,
                  keterangan: bahasa.label,
                  saatKetuk: () => LembarPilihBahasa.tampilkan(context),
                ),
                const _BarisSakelarLokasi(),
              ],
            ),
          ),
          const SizedBox(height: Jarak.xl),
          animasi(
            _KartuSeksi(
              judul: t.seksiTentang,
              baris: [
                _BarisPengaturan(
                  ikon: HugeIcons.strokeRoundedShield01,
                  judul: t.kebijakanPrivasi,
                  saatKetuk: () => context.pushAman(NamaRute.kebijakanPrivasi),
                ),
                _BarisPengaturan(
                  ikon: HugeIcons.strokeRoundedDocumentValidation,
                  judul: t.kebijakanLayanan,
                  saatKetuk: () => context.pushAman(NamaRute.kebijakanLayanan),
                ),
                _BarisPengaturan(
                  ikon: HugeIcons.strokeRoundedFileAttachment,
                  judul: t.syaratKetentuan,
                  saatKetuk: () => context.pushAman(NamaRute.syaratKetentuan),
                ),
                _BarisPengaturan(
                  ikon: HugeIcons.strokeRoundedSecurityCheck,
                  judul: t.penafianSistem,
                  saatKetuk: () => context.pushAman(NamaRute.penafianSistem),
                ),
                _BarisPengaturan(
                  ikon: HugeIcons.strokeRoundedFingerPrint,
                  judul: t.pemrosesanDataBiometrik,
                  saatKetuk: () =>
                      context.pushAman(NamaRute.kebijakanBiometrik),
                ),
                _BarisPengaturan(
                  ikon: HugeIcons.strokeRoundedCheckmarkBadge02,
                  judul: t.pernyataanKebenaranData,
                  saatKetuk: () =>
                      context.pushAman(NamaRute.pernyataanKebenaranData),
                ),
                _BarisPengaturan(
                  ikon: HugeIcons.strokeRoundedCustomerService01,
                  judul: t.pusatBantuan,
                  saatKetuk: () => context.pushAman(NamaRute.bantuan),
                ),
                _BarisPengaturan(
                  ikon: HugeIcons.strokeRoundedInformationCircle,
                  judul: t.versiAplikasi,
                  keterangan: versiAplikasi,
                ),
              ],
            ),
          ),
          const SizedBox(height: Jarak.xl),
          animasi(
            _KartuSeksi(
              baris: [
                _BarisPengaturan(
                  ikon: HugeIcons.strokeRoundedLogout03,
                  judul: t.keluarAkun,
                  destruktif: true,
                  saatKetuk: () => _keluar(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _samarkanNik(String? nik) {
    if (nik == null || nik.length < 8) return nik ?? '—';
    return '${nik.substring(0, 4)}••••••••${nik.substring(nik.length - 4)}';
  }
}

class _KartuIdentitas extends ConsumerWidget {
  const _KartuIdentitas({required this.pengguna});

  final Pengguna? pengguna;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final terverifikasi = pengguna?.terverifikasi == true;
    final sekunder = pengguna?.username != null && pengguna!.username!.isNotEmpty
        ? '@${pengguna!.username}'
        : pengguna?.surel ?? pengguna?.nik ?? '';

    return Container(
      padding: const EdgeInsets.all(Jarak.lg),
      decoration: BoxDecoration(
        color: Warna.permukaan,
        borderRadius: BorderRadius.circular(Sudut.lg),
        border: Border.all(color: Warna.garis),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
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
                if (sekunder.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    sekunder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.teks.bodySmall?.copyWith(
                      color: Warna.teksKedua,
                    ),
                  ),
                ],
                const SizedBox(height: Jarak.sm),
                _LencanaVerifikasi(
                  terverifikasi: terverifikasi,
                  label: terverifikasi
                      ? t.akunTerverifikasi
                      : t.belumTerverifikasi,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LencanaVerifikasi extends StatelessWidget {
  const _LencanaVerifikasi({
    required this.terverifikasi,
    required this.label,
  });

  final bool terverifikasi;
  final String label;

  @override
  Widget build(BuildContext context) {
    final warna = terverifikasi ? Warna.sukses : Warna.tunda;
    final latar = terverifikasi ? Warna.suksesLembut : Warna.tundaLembut;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: latar,
        borderRadius: BorderRadius.circular(Sudut.pil),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            terverifikasi
                ? HugeIcons.strokeRoundedCheckmarkBadge02
                : HugeIcons.strokeRoundedAlert02,
            size: 13,
            color: warna,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.teks.labelSmall?.copyWith(
              color: warna,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _KartuSeksi extends StatelessWidget {
  const _KartuSeksi({this.judul, required this.baris});

  final String? judul;
  final List<Widget> baris;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (judul != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(Jarak.sm, 0, Jarak.sm, Jarak.sm),
            child: Text(
              judul!,
              style: context.teks.labelMedium?.copyWith(
                color: Warna.teksKetiga,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Warna.permukaan,
            borderRadius: BorderRadius.circular(Sudut.lg),
            border: Border.all(color: Warna.garis),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < baris.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, indent: 52, color: Warna.pemisah),
                baris[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BarisPengaturan extends StatelessWidget {
  const _BarisPengaturan({
    required this.ikon,
    required this.judul,
    this.keterangan,
    this.saatKetuk,
    this.ekor,
    this.destruktif = false,
  });

  final IconData ikon;
  final String judul;
  final String? keterangan;
  final VoidCallback? saatKetuk;
  final Widget? ekor;
  final bool destruktif;

  @override
  Widget build(BuildContext context) {
    final warnaIkon = destruktif ? Warna.bahaya : Warna.primer;
    final warnaJudul = destruktif ? Warna.bahaya : Warna.teksUtama;

    return InkWell(
      onTap: saatKetuk,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Jarak.lg,
          vertical: 14,
        ),
        child: Row(
          children: [
            Icon(ikon, size: 21, color: warnaIkon),
            const SizedBox(width: Jarak.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: context.teks.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: warnaJudul,
                    ),
                  ),
                  if (keterangan != null && keterangan!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        keterangan!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.teks.bodySmall?.copyWith(
                          color: Warna.teksKetiga,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (ekor != null)
              ekor!
            else if (saatKetuk != null)
              const Icon(
                HugeIcons.strokeRoundedArrowRight01,
                size: 17,
                color: Warna.teksKetiga,
              ),
          ],
        ),
      ),
    );
  }
}

class _BarisSakelarLokasi extends ConsumerStatefulWidget {
  const _BarisSakelarLokasi();

  @override
  ConsumerState<_BarisSakelarLokasi> createState() =>
      _BarisSakelarLokasiState();
}

class _BarisSakelarLokasiState extends ConsumerState<_BarisSakelarLokasi> {
  bool _aktif = false;

  @override
  void initState() {
    super.initState();
    LayananPencatatAktivitas.instance.bacaIzinLokasi().then((nilai) {
      if (mounted) setState(() => _aktif = nilai);
    });
  }

  Future<void> _ubah(bool nilai) async {
    final t = ref.read(teksProvider);
    if (!nilai) {
      await LayananPencatatAktivitas.instance.aturIzinLokasi(false);
      if (mounted) setState(() => _aktif = false);
      return;
    }

    final setuju = await DialogAplikasi.tampilkanKonfirmasi(
      context: context,
      judul: t.aktivitasLokasiJudul,
      pesan: t.aktivitasLokasiPenjelasan,
      labelKonfirmasi: t.lanjutkan,
      labelBatal: t.batal,
    );
    if (!setuju || !mounted) return;

    final hasil = await LayananJejakLokasi.instance.mintaIzinJikaPerlu();
    if (hasil != HasilIzinLokasi.diberikan) {
      if (!mounted) return;
      await DialogAplikasi.tampilkanAlert<void>(
        context: context,
        judul: t.aktivitasLokasiJudul,
        pesan: t.aktivitasLokasiDitolak,
      );
      return;
    }

    await LayananPencatatAktivitas.instance.aturIzinLokasi(true);
    if (mounted) setState(() => _aktif = true);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);
    return _BarisPengaturan(
      ikon: HugeIcons.strokeRoundedLocation01,
      judul: t.aktivitasLokasiJudul,
      keterangan: t.aktivitasLokasiSub,
      ekor: Switch(
        value: _aktif,
        onChanged: _ubah,
        activeThumbColor: Warna.putih,
        activeTrackColor: Warna.primer,
      ),
    );
  }
}
