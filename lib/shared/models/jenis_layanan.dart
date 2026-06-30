import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

enum JenisLayanan {
  aktaKelahiran(
    slug: 'birth-cert',
    nama: 'Akta Kelahiran',
    namaSingkat: 'Akta Lahir',
    deskripsi: 'Pencatatan kelahiran dan penerbitan akta untuk anak yang sudah memiliki NIK.',
    ikon: HugeIcons.strokeRoundedBaby01,
    kategoriDokumen: 'Akta Kelahiran',
  ),
  aktaKelahiranTanpaNik(
    slug: 'birth-cert-no-nik',
    nama: 'Akta Kelahiran (Tanpa NIK)',
    namaSingkat: 'Akta Lahir',
    deskripsi: 'Permohonan akta kelahiran untuk anak yang belum memiliki NIK.',
    ikon: HugeIcons.strokeRoundedBaby01,
    kategoriDokumen: 'Akta Kelahiran',
  ),
  aktaKematian(
    slug: 'death-cert',
    nama: 'Akta Kematian',
    namaSingkat: 'Akta Kematian',
    deskripsi: 'Pelaporan kematian dan penerbitan akta kematian.',
    ikon: HugeIcons.strokeRoundedDocumentValidation,
    kategoriDokumen: 'Akta Kematian',
  ),
  kkTambahAnak(
    slug: 'family-card-add-child',
    nama: 'KK — Tambah Anak',
    namaSingkat: 'KK Tambah Anak',
    deskripsi: 'Penambahan anggota keluarga (anak) dalam Kartu Keluarga.',
    ikon: HugeIcons.strokeRoundedUserAdd01,
    kategoriDokumen: 'Kartu Keluarga',
  ),
  kkCetakUlang(
    slug: 'family-card-reprint',
    nama: 'KK — Cetak Ulang',
    namaSingkat: 'KK Cetak Ulang',
    deskripsi: 'Pencetakan ulang Kartu Keluarga yang rusak atau hilang.',
    ikon: HugeIcons.strokeRoundedPrinter,
    kategoriDokumen: 'Kartu Keluarga',
  ),
  kkPerubahanBiodata(
    slug: 'family-card-biodata-change',
    nama: 'KK — Perubahan Biodata',
    namaSingkat: 'KK Ubah Biodata',
    deskripsi: 'Perubahan elemen data pada Kartu Keluarga.',
    ikon: HugeIcons.strokeRoundedUserEdit01,
    kategoriDokumen: 'Kartu Keluarga',
  ),
  kia(
    slug: 'child-id-card',
    nama: 'KIA (Kartu Identitas Anak)',
    namaSingkat: 'KIA',
    deskripsi: 'Penerbitan Kartu Identitas Anak untuk usia 0–17 tahun.',
    ikon: HugeIcons.strokeRoundedIdentityCard,
    kategoriDokumen: 'KIA',
  );

  const JenisLayanan({
    required this.slug,
    required this.nama,
    required this.namaSingkat,
    required this.deskripsi,
    required this.ikon,
    required this.kategoriDokumen,
  });

  final String slug;
  final String nama;
  final String namaSingkat;
  final String deskripsi;
  final IconData ikon;
  final String kategoriDokumen;

  static JenisLayanan? dariSlug(String? slug) {
    if (slug == null) return null;
    for (final jenis in JenisLayanan.values) {
      if (jenis.slug == slug) return jenis;
    }
    return null;
  }

  static String labelSlug(String slug) {
    final jenis = dariSlug(slug);
    if (jenis != null) return jenis.nama;
    const label = {
      'marriage-cert': 'Akta Perkawinan',
      'divorce-cert': 'Akta Perceraian',
      'ektp': 'e-KTP',
      'ktp-print': 'Pencetakan KTP',
      'family-card-join': 'KK — Numpang KK',
      'family-card-split': 'KK — Pisah KK',
      'relocation': 'Pindah Keluar',
      'arrival': 'Kedatangan Penduduk',
      'data-consolidation': 'Konsolidasi Data',
    };
    return label[slug] ?? slug;
  }
}

class RingkasanLayanan {
  const RingkasanLayanan({
    required this.kode,
    required this.nama,
    this.kategori,
    this.deskripsi,
  });

  final String kode;
  final String nama;
  final String? kategori;
  final String? deskripsi;

  JenisLayanan? get jenis => JenisLayanan.dariSlug(kode);

  IconData get ikon => jenis?.ikon ?? HugeIcons.strokeRoundedFile02;

  String get namaSingkat => jenis?.namaSingkat ?? nama;

  String get deskripsiTampil =>
      (deskripsi != null && deskripsi!.isNotEmpty)
          ? deskripsi!
          : (jenis?.deskripsi ?? '');

  factory RingkasanLayanan.dariJenis(JenisLayanan jenis) => RingkasanLayanan(
        kode: jenis.slug,
        nama: jenis.nama,
        kategori: jenis.kategoriDokumen,
        deskripsi: jenis.deskripsi,
      );

  factory RingkasanLayanan.dariKode(String kode) =>
      RingkasanLayanan(kode: kode, nama: JenisLayanan.labelSlug(kode));

  factory RingkasanLayanan.dariJson(Map<String, dynamic> json) {
    String teks(List<String> kunci) {
      for (final k in kunci) {
        final nilai = json[k];
        if (nilai != null && nilai.toString().trim().isNotEmpty) {
          return nilai.toString().trim();
        }
      }
      return '';
    }

    final kode = teks(const ['kode', 'slug', 'id']);
    final nama = teks(const ['nama', 'nama_layanan', 'title', 'name']);
    final kategori = teks(const ['kategori', 'category', 'kelompok']);
    final deskripsi =
        teks(const ['deskripsi', 'description', 'keterangan', 'ringkasan']);
    return RingkasanLayanan(
      kode: kode,
      nama: nama.isNotEmpty ? nama : JenisLayanan.labelSlug(kode),
      kategori: kategori.isEmpty ? null : kategori,
      deskripsi: deskripsi.isEmpty ? null : deskripsi,
    );
  }
}
