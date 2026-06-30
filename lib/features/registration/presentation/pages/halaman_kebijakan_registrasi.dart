import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/enums/jenis_kebijakan.dart';
import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/network/penjaga_jaringan.dart';
import '../../../../core/router/nama_rute.dart';
import '../../../../core/system/penjaga_maintenance.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../help/providers/penyedia_kebijakan.dart';
import '../../data/model/data_registrasi.dart';
import '../../providers/penyedia_registrasi.dart';
import '../widgets/stepper_registrasi.dart';

class HalamanKebijakanRegistrasi extends ConsumerStatefulWidget {
  const HalamanKebijakanRegistrasi({super.key});

  @override
  ConsumerState<HalamanKebijakanRegistrasi> createState() =>
      _HalamanKebijakanRegistrasiState();
}

class _HalamanKebijakanRegistrasiState
    extends ConsumerState<HalamanKebijakanRegistrasi> {
  Future<void> _submit() async {
    final jaringanOk = await PenjagaJaringan.cekUntukAksi(
      context: context,
      ref: ref,
      kekakuan: TingkatKekakuanJaringan.ketat,
    );
    if (!mounted || !jaringanOk) return;
    final maintenanceOk = await PenjagaMaintenance.cekUntukAksi(
      context: context,
      ref: ref,
    );
    if (!mounted || !maintenanceOk) return;
    context.go(NamaRute.daftarProsesVerifikasi);
  }

  Future<void> _bacaDanSetujui({
    required JenisKebijakan jenis,
    required String jalur,
  }) async {
    final hasil = await context.push<bool>(jalur);
    if (hasil != true || !mounted) return;
    String? versi;
    try {
      versi = (await ref.read(penyediaKontenKebijakan(jenis).future)).versi;
    } catch (_) {}
    if (!mounted) return;
    _setujui(jenis, true, versi: versi);
  }

  void _setujui(JenisKebijakan jenis, bool nilai, {String? versi}) {
    final p = ref.read(penyediaRegistrasi).sesi.persetujuan;
    var baru = _terapkan(p, jenis, nilai);
    if (nilai && versi != null && versi.isNotEmpty) {
      baru = baru.salin(versi: {...p.versi, jenis.value: versi});
    }
    ref.read(penyediaRegistrasi.notifier).perbaruiPersetujuan(baru);
  }

  PersetujuanKebijakan _terapkan(
      PersetujuanKebijakan p, JenisKebijakan jenis, bool nilai) {
    switch (jenis) {
      case JenisKebijakan.privasi:
        return p.salin(privasi: nilai);
      case JenisKebijakan.layanan:
        return p.salin(layanan: nilai);
      case JenisKebijakan.penafian:
        return p.salin(penafian: nilai);
      case JenisKebijakan.biometrik:
        return p.salin(biometrik: nilai);
      case JenisKebijakan.kebenaranData:
        return p.salin(kebenaranData: nilai);
      case JenisKebijakan.syaratKetentuan:
        return p;
    }
  }

  @override
  Widget build(BuildContext context) {
    final kondisi = ref.watch(penyediaRegistrasi);
    final t = ref.watch(teksProvider);
    final p = kondisi.sesi.persetujuan;

    return Scaffold(
      backgroundColor: Warna.permukaan,
      appBar: AppBar(
        title: Text(t.persetujuan),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(HugeIcons.strokeRoundedArrowLeft01),
        ),
      ),
      body: Column(
        children: [
          StepperRegistrasi(
            langkahAktif: LangkahRegistrasi.kebijakan,
            judulLangkah: t.persetujuan,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Text(
                  t.persetujuanKebijakan,
                  style: context.teks.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.bukaTautanBacaSetelah,
                  style: context.teks.bodySmall?.copyWith(
                    color: Warna.teksKedua,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: Jarak.xl),
                _IsianPersetujuan(
                  nilai: p.privasi,
                  judul: t.kebijakanPrivasi,
                  deskripsi: t.kebijakanPrivasiDeskripsi,
                  labelBaca: t.bacaKebijakanPrivasi,
                  saatBerubah: (v) => _setujui(JenisKebijakan.privasi, v),
                  saatBaca: () => _bacaDanSetujui(
                    jenis: JenisKebijakan.privasi,
                    jalur: NamaRute.kebijakanPrivasiSetuju,
                  ),
                ),
                _IsianPersetujuan(
                  nilai: p.layanan,
                  judul: t.kebijakanLayanan,
                  deskripsi: t.kebijakanLayananDeskripsi,
                  labelBaca: t.bacaKebijakanLayanan,
                  saatBerubah: (v) => _setujui(JenisKebijakan.layanan, v),
                  saatBaca: () => _bacaDanSetujui(
                    jenis: JenisKebijakan.layanan,
                    jalur: NamaRute.kebijakanLayananSetuju,
                  ),
                ),
                _IsianPersetujuan(
                  nilai: p.penafian,
                  judul: t.penafianSistemJudulLengkap,
                  deskripsi: t.penafianSistemDeskripsi,
                  labelBaca: t.bacaPenafianSistem,
                  saatBerubah: (v) => _setujui(JenisKebijakan.penafian, v),
                  saatBaca: () => _bacaDanSetujui(
                    jenis: JenisKebijakan.penafian,
                    jalur: NamaRute.penafianSistemSetuju,
                  ),
                ),
                _IsianPersetujuan(
                  nilai: p.biometrik,
                  judul: t.pemrosesanDataBiometrik,
                  deskripsi: t.pemrosesanDataBiometrikDeskripsi,
                  labelBaca: t.bacaPersetujuanBiometrik,
                  saatBerubah: (v) => _setujui(JenisKebijakan.biometrik, v),
                  saatBaca: () => _bacaDanSetujui(
                    jenis: JenisKebijakan.biometrik,
                    jalur: NamaRute.kebijakanBiometrikSetuju,
                  ),
                ),
                _IsianPersetujuan(
                  nilai: p.kebenaranData,
                  judul: t.pernyataanKebenaranData,
                  deskripsi: t.pernyataanKebenaranDataDeskripsi,
                  labelBaca: t.bacaPernyataanKebenaran,
                  saatBerubah: (v) =>
                      _setujui(JenisKebijakan.kebenaranData, v),
                  saatBaca: () => _bacaDanSetujui(
                    jenis: JenisKebijakan.kebenaranData,
                    jalur: NamaRute.pernyataanKebenaranDataSetuju,
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: (!p.semua || kondisi.memuat) ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: Warna.primer,
                    disabledBackgroundColor: Warna.netral200,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: kondisi.memuat
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white),
                        )
                      : Text(t.kirimRegistrasi),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IsianPersetujuan extends StatelessWidget {
  const _IsianPersetujuan({
    required this.nilai,
    required this.judul,
    required this.deskripsi,
    required this.labelBaca,
    required this.saatBerubah,
    required this.saatBaca,
  });

  final bool nilai;
  final String judul;
  final String deskripsi;
  final String labelBaca;
  final ValueChanged<bool> saatBerubah;
  final VoidCallback saatBaca;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Warna.permukaan,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: nilai ? Warna.primer : Warna.garis,
            width: nilai ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                if (nilai) {
                  saatBerubah(false);
                } else {
                  saatBaca();
                }
              },
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      nilai
                          ? HugeIcons.strokeRoundedCheckmarkSquare02
                          : HugeIcons.strokeRoundedSquare,
                      color: nilai ? Warna.primer : Warna.netral400,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            judul,
                            style: context.teks.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            deskripsi,
                            style: context.teks.bodySmall?.copyWith(
                              color: Warna.teksKedua,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: saatBaca,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(44, 8, 12, 12),
                child: Row(
                  children: [
                    Text(
                      labelBaca,
                      style: const TextStyle(
                        color: Warna.info,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(HugeIcons.strokeRoundedArrowRight01,
                        size: 14, color: Warna.info),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
