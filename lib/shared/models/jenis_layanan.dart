import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

enum JenisLayanan {
  ktpIkd(
    kode: 'ktp_ikd',
    nama: 'KTP-el & IKD',
    deskripsi: 'Cetak ulang dan aktivasi Identitas Kependudukan Digital.',
    ikon: HugeIcons.strokeRoundedIdentityCard,
    bisaOnline: true,
  ),
  kartuKeluarga(
    kode: 'kk',
    nama: 'Kartu Keluarga',
    deskripsi: 'Permohonan baru, perubahan, dan pemecahan KK.',
    ikon: HugeIcons.strokeRoundedUserMultiple,
    bisaOnline: true,
  ),
  kia(
    kode: 'kia',
    nama: 'KIA',
    deskripsi: 'Kartu Identitas Anak untuk warga di bawah 17 tahun.',
    ikon: HugeIcons.strokeRoundedBaby01,
    bisaOnline: true,
  ),
  aktaKelahiran(
    kode: 'akta_lahir',
    nama: 'Akta Kelahiran',
    deskripsi: 'Pencatatan kelahiran dan penerbitan akta.',
    ikon: HugeIcons.strokeRoundedCertificate01,
    bisaOnline: true,
  ),
  aktaKematian(
    kode: 'akta_mati',
    nama: 'Akta Kematian',
    deskripsi: 'Pelaporan kematian dan penerbitan akta.',
    ikon: HugeIcons.strokeRoundedFileNotFound,
    bisaOnline: true,
  ),
  perkawinanPerceraian(
    kode: 'kawin_cerai',
    nama: 'Perkawinan & Perceraian',
    deskripsi: 'Pencatatan perkawinan & perceraian non-muslim.',
    ikon: HugeIcons.strokeRoundedFavourite,
    bisaOnline: false,
  ),
  pindahDatang(
    kode: 'pindah_datang',
    nama: 'Pindah Datang',
    deskripsi: 'Surat Keterangan Pindah WNI (SKPWNI).',
    ikon: HugeIcons.strokeRoundedExchange01,
    bisaOnline: true,
  ),
  konsolidasiData(
    kode: 'konsolidasi',
    nama: 'Konsolidasi Data',
    deskripsi: 'Pemutakhiran data kependudukan terkini.',
    ikon: HugeIcons.strokeRoundedDatabaseSetting,
    bisaOnline: false,
  ),
  legalisir(
    kode: 'legalisir',
    nama: 'Legalisir Dokumen',
    deskripsi: 'Pengesahan salinan dokumen kependudukan.',
    ikon: HugeIcons.strokeRoundedTaskDone02,
    bisaOnline: false,
  ),
  pengaduan(
    kode: 'pengaduan',
    nama: 'Pengaduan Masyarakat',
    deskripsi: 'Sampaikan keluhan, masukan, atau laporan.',
    ikon: HugeIcons.strokeRoundedMegaphone02,
    bisaOnline: true,
  );

  const JenisLayanan({
    required this.kode,
    required this.nama,
    required this.deskripsi,
    required this.ikon,
    required this.bisaOnline,
  });

  final String kode;
  final String nama;
  final String deskripsi;
  final IconData ikon;
  final bool bisaOnline;

  static List<JenisLayanan> get daring =>
      JenisLayanan.values.where((e) => e.bisaOnline).toList();

  static JenisLayanan dariKode(String kode) {
    return JenisLayanan.values.firstWhere(
      (e) => e.kode == kode,
      orElse: () => JenisLayanan.ktpIkd,
    );
  }
}
