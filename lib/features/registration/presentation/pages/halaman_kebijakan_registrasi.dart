import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/network/penjaga_jaringan.dart';
import '../../../../core/router/nama_rute.dart';
import '../../../../core/system/penjaga_maintenance.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
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
    required String jalur,
    required ValueChanged<bool> saatBerubah,
  }) async {
    final hasil = await context.push<bool>(jalur);
    if (hasil == true && mounted) {
      saatBerubah(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kondisi = ref.watch(penyediaRegistrasi);
    final t = ref.watch(teksProvider);
    final p = kondisi.sesi.persetujuan;
    final aksi = ref.read(penyediaRegistrasi.notifier);

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
                  jalur: NamaRute.kebijakanPrivasiSetuju,
                  saatBerubah: (v) =>
                      aksi.perbaruiPersetujuan(p.salin(privasi: v)),
                  saatBaca: (cb) => _bacaDanSetujui(
                    jalur: NamaRute.kebijakanPrivasiSetuju,
                    saatBerubah: cb,
                  ),
                ),
                _IsianPersetujuan(
                  nilai: p.layanan,
                  judul: t.kebijakanLayanan,
                  deskripsi: t.kebijakanLayananDeskripsi,
                  labelBaca: t.bacaKebijakanLayanan,
                  jalur: NamaRute.kebijakanLayananSetuju,
                  saatBerubah: (v) =>
                      aksi.perbaruiPersetujuan(p.salin(layanan: v)),
                  saatBaca: (cb) => _bacaDanSetujui(
                    jalur: NamaRute.kebijakanLayananSetuju,
                    saatBerubah: cb,
                  ),
                ),
                _IsianPersetujuan(
                  nilai: p.penafian,
                  judul: t.penafianSistemJudulLengkap,
                  deskripsi: t.penafianSistemDeskripsi,
                  labelBaca: t.bacaPenafianSistem,
                  jalur: NamaRute.penafianSistemSetuju,
                  saatBerubah: (v) =>
                      aksi.perbaruiPersetujuan(p.salin(penafian: v)),
                  saatBaca: (cb) => _bacaDanSetujui(
                    jalur: NamaRute.penafianSistemSetuju,
                    saatBerubah: cb,
                  ),
                ),
                _IsianPersetujuan(
                  nilai: p.biometrik,
                  judul: t.pemrosesanDataBiometrik,
                  deskripsi: t.pemrosesanDataBiometrikDeskripsi,
                  labelBaca: t.bacaPersetujuanBiometrik,
                  jalur: NamaRute.kebijakanBiometrikSetuju,
                  saatBerubah: (v) =>
                      aksi.perbaruiPersetujuan(p.salin(biometrik: v)),
                  saatBaca: (cb) => _bacaDanSetujui(
                    jalur: NamaRute.kebijakanBiometrikSetuju,
                    saatBerubah: cb,
                  ),
                ),
                _IsianPersetujuan(
                  nilai: p.kebenaranData,
                  judul: t.pernyataanKebenaranData,
                  deskripsi: t.pernyataanKebenaranDataDeskripsi,
                  labelBaca: t.bacaPernyataanKebenaran,
                  jalur: NamaRute.pernyataanKebenaranDataSetuju,
                  saatBerubah: (v) =>
                      aksi.perbaruiPersetujuan(p.salin(kebenaranData: v)),
                  saatBaca: (cb) => _bacaDanSetujui(
                    jalur: NamaRute.pernyataanKebenaranDataSetuju,
                    saatBerubah: cb,
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
                    backgroundColor: Warna.merahUtama,
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
    required this.jalur,
    required this.saatBerubah,
    required this.saatBaca,
  });

  final bool nilai;
  final String judul;
  final String deskripsi;
  final String labelBaca;
  final String jalur;
  final ValueChanged<bool> saatBerubah;
  final void Function(ValueChanged<bool> autoCheck) saatBaca;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Warna.permukaan,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: nilai ? Warna.merahUtama : Warna.garis,
            width: nilai ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              // Tap area judul: kalau belum centang → harus baca dulu.
              // Kalau sudah centang → boleh uncheck langsung.
              onTap: () {
                if (nilai) {
                  saatBerubah(false);
                } else {
                  saatBaca(saatBerubah);
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
                      color: nilai ? Warna.merahUtama : Warna.netral400,
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
              onTap: () => saatBaca(saatBerubah),
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
