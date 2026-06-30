import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/network/penjaga_jaringan.dart';
import '../../../../core/router/nama_rute.dart';
import '../../../../core/system/penjaga_maintenance.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/penyamaran.dart';
import '../../../../core/utils/validasi.dart';
import '../../../../shared/models/wilayah.dart';
import '../../../../shared/providers/penyedia_bahasa.dart';
import '../../../../shared/providers/penyedia_muat_global.dart';
import '../../../../shared/widgets/kotak_isian.dart';
import '../../../../shared/widgets/kotak_isian_sensitif.dart';
import '../../../../shared/widgets/pemilih_domisili.dart';
import '../../data/model/data_registrasi.dart';
import '../../providers/penyedia_registrasi.dart';
import '../widgets/stepper_registrasi.dart';

class HalamanIdentitasRegistrasi extends ConsumerStatefulWidget {
  const HalamanIdentitasRegistrasi({super.key});

  @override
  ConsumerState<HalamanIdentitasRegistrasi> createState() =>
      _HalamanIdentitasRegistrasiState();
}

class _HalamanIdentitasRegistrasiState
    extends ConsumerState<HalamanIdentitasRegistrasi> {
  final _kunci = GlobalKey<FormState>();
  final _nik = TextEditingController();
  final _nama = TextEditingController();
  final _tempat = TextEditingController();
  final _hp = TextEditingController();
  final _surel = TextEditingController();
  DateTime? _tanggal;
  JenisKelamin? _kelamin;
  Wilayah? _kabupaten;
  Wilayah? _kecamatan;
  Wilayah? _desa;

  @override
  void initState() {
    super.initState();
    final s = ref.read(penyediaRegistrasi).sesi.identitas;
    _nik.text = s.nomorIdentitas;
    _nama.text = s.namaLengkap;
    _tempat.text = s.tempatLahir;
    // Strip +62 prefix kalau ada (saat user kembali ke halaman ini)
    _hp.text = s.noHp
        .replaceFirst(RegExp(r'^\+62'), '')
        .replaceFirst(RegExp(r'^0+'), '');
    _surel.text = s.surel;
    _tanggal = s.tanggalLahir;
    _kelamin = s.jenisKelamin;
    if (s.kabupatenKode.isNotEmpty) {
      _kabupaten = Wilayah(kode: s.kabupatenKode, nama: s.kabupatenNama);
    }
    if (s.kecamatanKode.isNotEmpty) {
      _kecamatan = Wilayah(kode: s.kecamatanKode, nama: s.kecamatanNama);
    }
    if (s.desaKode.isNotEmpty) {
      _desa = Wilayah(kode: s.desaKode, nama: s.desaNama);
    }
  }

  @override
  void dispose() {
    _nik.dispose();
    _nama.dispose();
    _tempat.dispose();
    _hp.dispose();
    _surel.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final sekarang = DateTime.now();
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggal ?? DateTime(sekarang.year - 25),
      firstDate: DateTime(1900),
      lastDate: sekarang,
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Warna.primer),
        ),
        child: child!,
      ),
    );
    if (hasil != null) setState(() => _tanggal = hasil);
  }

  Future<void> _lanjut() async {
    final t = ref.read(teksProvider);
    if (!(_kunci.currentState?.validate() ?? false)) return;
    if (_tanggal == null) {
      context.tampilkanGalat(t.tanggalLahirWajib);
      return;
    }
    if (_kelamin == null) {
      context.tampilkanGalat(t.jenisKelaminWajib);
      return;
    }
    if (_kabupaten == null || _kecamatan == null || _desa == null) {
      context.tampilkanGalat(t.wilayahWajib);
      return;
    }

    final jaringanOk = await PenjagaJaringan.cekUntukAksi(
      context: context,
      ref: ref,
    );
    if (!mounted || !jaringanOk) return;
    final maintenanceOk = await PenjagaMaintenance.cekUntukAksi(
      context: context,
      ref: ref,
    );
    if (!mounted || !maintenanceOk) return;

    final aksi = ref.read(penyediaRegistrasi.notifier);
    final muat = ref.read(penyediaMuatGlobal.notifier);
    final hpInput =
        _hp.text.trim().replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp(r'^0+'), '');
    aksi.perbaruiIdentitas(IdentitasRegistrasi(
      nomorIdentitas: _nik.text.trim(),
      namaLengkap: _nama.text.trim(),
      tanggalLahir: _tanggal,
      tempatLahir: _tempat.text.trim(),
      jenisKelamin: _kelamin,
      noHp: '+62$hpInput',
      surel: _surel.text.trim(),
      kabupatenKode: _kabupaten!.kode,
      kabupatenNama: _kabupaten!.nama,
      kecamatanKode: _kecamatan!.kode,
      kecamatanNama: _kecamatan!.nama,
      desaKode: _desa!.kode,
      desaNama: _desa!.nama,
    ));

    final ok = await muat.jalankan<bool>(
      () => aksi.kirimIdentitas(),
      judul: t.mohonTunggu,
      pesan: t.menyimpanIdentitas,
    );
    if (!mounted) return;
    if (ok) {
      aksi.ubahLangkah(LangkahRegistrasi.fotoDokumen);
      context.push(NamaRute.daftarFotoDokumen);
    } else {
      final pesan = ref.read(penyediaRegistrasi).pesanGalat ??
          t.gagalMemprosesIdentitas;
      context.tampilkanGalat(pesan);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kondisi = ref.watch(penyediaRegistrasi);
    final t = ref.watch(teksProvider);

    return Scaffold(
      backgroundColor: Warna.permukaan,
      appBar: AppBar(
        title: Text(t.registrasi),
        leading: IconButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(NamaRute.masuk),
          icon: const Icon(HugeIcons.strokeRoundedArrowLeft01),
        ),
      ),
      body: Column(
        children: [
          StepperRegistrasi(
            langkahAktif: LangkahRegistrasi.identitas,
            judulLangkah: t.dataIdentitas,
          ),
          Expanded(
            child: Form(
              key: _kunci,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  Text(
                    t.dataIdentitasDasar,
                    style: context.teks.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.pastikanDataSesuaiKtp,
                    style: context.teks.bodyMedium?.copyWith(
                      color: Warna.teksKedua,
                    ),
                  ),
                  const SizedBox(height: Jarak.xl),
                  KotakIsianSensitif(
                    label: t.nik,
                    petunjuk: t.hintNik,
                    pengatur: _nik,
                    penyamar: Penyamaran.nik,
                    tipeMasukan: TextInputType.number,
                    aksiMasukan: TextInputAction.next,
                    formatter: [HanyaDigitFormatter(panjangMaks: 16)],
                    ikonAwal: HugeIcons.strokeRoundedIdentityCard,
                    validator: Validasi.nik,
                    wajib: true,
                  ),
                  const SizedBox(height: Jarak.lg),
                  KotakIsian(
                    label: t.namaLengkap,
                    petunjuk: t.hintNamaSesuaiKtp,
                    pengatur: _nama,
                    aksiMasukan: TextInputAction.next,
                    ikonAwal: HugeIcons.strokeRoundedUser,
                    validator: (v) =>
                        Validasi.wajib(v, label: t.namaLengkapLabel),
                    wajib: true,
                  ),
                  const SizedBox(height: Jarak.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _IsianTanggal(
                          tanggal: _tanggal,
                          onTap: _pilihTanggal,
                        ),
                      ),
                      const SizedBox(width: Jarak.md),
                      Expanded(
                        child: _DropdownKelamin(
                          nilai: _kelamin,
                          onChanged: (v) => setState(() => _kelamin = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Jarak.lg),
                  KotakIsian(
                    label: t.tempatLahir,
                    petunjuk: t.hintTempatLahir,
                    pengatur: _tempat,
                    aksiMasukan: TextInputAction.next,
                    ikonAwal: HugeIcons.strokeRoundedLocation01,
                    validator: (v) =>
                        Validasi.wajib(v, label: t.tempatLahirLabel),
                    wajib: true,
                  ),
                  const SizedBox(height: Jarak.xl),
                  PemilihDomisili(
                    label: t.alamatDomisili,
                    kabupaten: _kabupaten,
                    kecamatan: _kecamatan,
                    desa: _desa,
                    wajib: true,
                    saatPilih: (h) => setState(() {
                      _kabupaten = h.kabupaten;
                      _kecamatan = h.kecamatan;
                      _desa = h.desa;
                    }),
                  ),
                  const SizedBox(height: Jarak.lg),
                  KotakIsian(
                    label: t.nomorHp,
                    petunjuk: t.hintNoHp,
                    bantuan: t.bantuanNoHpTanpaNol,
                    pengatur: _hp,
                    tipeMasukan: TextInputType.phone,
                    aksiMasukan: TextInputAction.done,
                    prefiks: '+62 ',
                    formatter: [
                      FilteringTextInputFormatter.digitsOnly,
                      HanyaDigitFormatter(panjangMaks: 13),
                    ],
                    ikonAwal: HugeIcons.strokeRoundedSmartPhone01,
                    validator: Validasi.noHpTanpaPrefiks,
                    wajib: true,
                  ),
                  const SizedBox(height: Jarak.lg),
                  KotakIsian(
                    label: t.email,
                    petunjuk: t.hintEmail,
                    pengatur: _surel,
                    tipeMasukan: TextInputType.emailAddress,
                    aksiMasukan: TextInputAction.done,
                    ikonAwal: HugeIcons.strokeRoundedMail01,
                    validator: Validasi.surel,
                    wajib: true,
                  ),
                ],
              ),
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
                  onPressed: kondisi.memuat ? null : _lanjut,
                  style: FilledButton.styleFrom(
                    backgroundColor: Warna.primer,
                    disabledBackgroundColor: Warna.netral200,
                    foregroundColor: Colors.white,
                    elevation: 0,
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
                      : Text(t.lanjutkan),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IsianTanggal extends ConsumerWidget {
  const _IsianTanggal({required this.tanggal, required this.onTap});
  final DateTime? tanggal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final bahasa = ref.watch(penyediaBahasa);
    final lokalDateFmt = bahasa == KodeBahasa.en ? 'd MMMM yyyy' : 'd MMMM yyyy';
    final lokal = bahasa == KodeBahasa.en ? 'en_US' : 'id_ID';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(t.tanggalLahir, style: context.teks.titleSmall),
            const SizedBox(width: 4),
            Text('*',
                style: context.teks.titleSmall?.copyWith(color: Warna.bahaya)),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Warna.netral25,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Warna.garis),
            ),
            child: Row(
              children: [
                const Icon(HugeIcons.strokeRoundedCalendar01,
                    size: 18, color: Warna.teksKedua),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tanggal == null
                        ? t.pilihTanggal
                        : DateFormat(lokalDateFmt, lokal).format(tanggal!),
                    style: context.teks.bodyMedium?.copyWith(
                      color: tanggal == null ? Warna.teksKetiga : Warna.teksUtama,
                      fontWeight: tanggal == null ? FontWeight.w400 : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownKelamin extends ConsumerWidget {
  const _DropdownKelamin({required this.nilai, required this.onChanged});
  final JenisKelamin? nilai;
  final ValueChanged<JenisKelamin?> onChanged;

  String _labelKelamin(JenisKelamin j, Teks t) {
    switch (j) {
      case JenisKelamin.lakiLaki:
        return t.lakiLaki;
      case JenisKelamin.perempuan:
        return t.perempuan;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(t.jenisKelamin, style: context.teks.titleSmall),
            const SizedBox(width: 4),
            Text('*',
                style: context.teks.titleSmall?.copyWith(color: Warna.bahaya)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Warna.netral25,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Warna.garis),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<JenisKelamin>(
              value: nilai,
              isExpanded: true,
              hint: Text(
                t.pilih,
                style: context.teks.bodyMedium?.copyWith(color: Warna.teksKetiga),
              ),
              icon: const Icon(HugeIcons.strokeRoundedArrowDown01, size: 18),
              items: JenisKelamin.values
                  .map((j) => DropdownMenuItem(
                        value: j,
                        child: Text(_labelKelamin(j, t)),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
