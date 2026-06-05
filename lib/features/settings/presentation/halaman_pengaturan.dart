import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/storage_keys.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/providers/penyedia_bahasa.dart';
import '../../../shared/widgets/lembar_pilih_bahasa.dart';

class HalamanPengaturan extends ConsumerStatefulWidget {
  const HalamanPengaturan({super.key});

  @override
  ConsumerState<HalamanPengaturan> createState() => _HalamanPengaturanState();
}

class _HalamanPengaturanState extends ConsumerState<HalamanPengaturan> {
  bool _notif = true;
  bool _biometrik = false;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    final pref = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notif = pref.getBool(StorageKeys.notifikasiAktif) ?? true;
      _biometrik = pref.getBool(StorageKeys.biometrikAktif) ?? false;
    });
  }

  Future<void> _simpan(String kunci, bool nilai) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(kunci, nilai);
  }

  Future<void> _pilihBahasa() async {
    await LembarPilihBahasa.tampilkan(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);
    final bahasa = ref.watch(penyediaBahasa);
    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(title: Text(t.pengaturan)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Jarak.layarH, Jarak.md, Jarak.layarH, Jarak.xxl),
          children: [
            Text(t.bahasa, style: context.teks.titleSmall),
            const SizedBox(height: Jarak.sm),
            _Item(
              ikon: HugeIcons.strokeRoundedLanguageSquare,
              judul: t.bahasa,
              subJudul: bahasa.label,
              saatKetuk: _pilihBahasa,
            ),
            const SizedBox(height: Jarak.lg),
            Text(t.pemberitahuan, style: context.teks.titleSmall),
            const SizedBox(height: Jarak.sm),
            _Saklar(
              ikon: HugeIcons.strokeRoundedNotification01,
              judul: t.pemberitahuan,
              subJudul: t.pemberitahuanSub,
              nilai: _notif,
              saatBerubah: (v) {
                setState(() => _notif = v);
                _simpan(StorageKeys.notifikasiAktif, v);
              },
            ),
            const SizedBox(height: Jarak.lg),
            Text(t.keamananAkun, style: context.teks.titleSmall),
            const SizedBox(height: Jarak.sm),
            _Saklar(
              ikon: HugeIcons.strokeRoundedFingerPrintScan,
              judul: t.masukDenganBiometrik,
              subJudul: t.keamananAkunSub,
              nilai: _biometrik,
              saatBerubah: (v) {
                setState(() => _biometrik = v);
                _simpan(StorageKeys.biometrikAktif, v);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Saklar extends StatelessWidget {
  const _Saklar({
    required this.ikon,
    required this.judul,
    required this.subJudul,
    required this.nilai,
    required this.saatBerubah,
  });
  final IconData ikon;
  final String judul;
  final String subJudul;
  final bool nilai;
  final ValueChanged<bool> saatBerubah;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Jarak.md, vertical: 10),
      decoration: BoxDecoration(
        color: Warna.permukaan,
        border: Border.all(color: Warna.garis),
        borderRadius: BorderRadius.circular(Sudut.md),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Warna.netral100,
              borderRadius: BorderRadius.circular(Sudut.sm),
            ),
            child: Icon(ikon, size: 20),
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
          Switch.adaptive(value: nilai, onChanged: saatBerubah),
        ],
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Jarak.md, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Warna.garis),
            borderRadius: BorderRadius.circular(Sudut.md),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Warna.netral100,
                  borderRadius: BorderRadius.circular(Sudut.sm),
                ),
                child: Icon(ikon, size: 20),
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
