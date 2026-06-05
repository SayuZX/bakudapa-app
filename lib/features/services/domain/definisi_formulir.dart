import '../../../shared/models/jenis_layanan.dart';

enum TipeRuas { teks, angka, nik, noKk, email, telepon, tanggal, areaTeks, pilihan }

class DefinisiRuas {
  const DefinisiRuas({
    required this.nama,
    required this.label,
    required this.tipe,
    this.wajib = true,
    this.petunjuk,
    this.pilihan = const [],
    this.panjangMaks,
  });

  final String nama;
  final String label;
  final TipeRuas tipe;
  final bool wajib;
  final String? petunjuk;
  final List<String> pilihan;
  final int? panjangMaks;
}

class DefinisiBerkas {
  const DefinisiBerkas({required this.nama, required this.label, this.wajib = true});
  final String nama;
  final String label;
  final bool wajib;
}

class DefinisiFormulir {
  const DefinisiFormulir({
    required this.ruas,
    required this.berkas,
    required this.langkahPanduan,
  });
  final List<DefinisiRuas> ruas;
  final List<DefinisiBerkas> berkas;
  final List<String> langkahPanduan;
}

class KatalogFormulir {
  const KatalogFormulir._();

  static DefinisiFormulir untuk(JenisLayanan jenis) {
    switch (jenis) {
      case JenisLayanan.ktpIkd:
        return const DefinisiFormulir(
          ruas: [
            DefinisiRuas(nama: 'sub_jenis', label: 'Jenis Permohonan', tipe: TipeRuas.pilihan,
                pilihan: ['Cetak Baru', 'Penggantian', 'Aktivasi IKD']),
            DefinisiRuas(nama: 'alasan', label: 'Alasan', tipe: TipeRuas.areaTeks, panjangMaks: 250),
          ],
          berkas: [
            DefinisiBerkas(nama: 'foto_kk', label: 'Foto Kartu Keluarga'),
            DefinisiBerkas(nama: 'foto_diri', label: 'Foto Diri (selfie)'),
          ],
          langkahPanduan: [
            'Siapkan foto KK yang masih berlaku.',
            'Ambil foto diri (selfie) dengan pencahayaan yang baik.',
            'Pilih jenis permohonan dan isi alasan singkat.',
            'Kirim formulir, status akan muncul di menu Riwayat.',
          ],
        );
      case JenisLayanan.kartuKeluarga:
        return const DefinisiFormulir(
          ruas: [
            DefinisiRuas(nama: 'sub_jenis', label: 'Jenis Permohonan', tipe: TipeRuas.pilihan,
                pilihan: ['KK Baru', 'Perubahan Data', 'Pecah KK']),
            DefinisiRuas(nama: 'no_kk_lama', label: 'Nomor KK Lama', tipe: TipeRuas.noKk, wajib: false),
            DefinisiRuas(nama: 'keterangan', label: 'Keterangan', tipe: TipeRuas.areaTeks, panjangMaks: 250),
          ],
          berkas: [
            DefinisiBerkas(nama: 'foto_kk_lama', label: 'Foto KK Lama', wajib: false),
            DefinisiBerkas(nama: 'foto_ktp_kepala', label: 'KTP Kepala Keluarga'),
            DefinisiBerkas(nama: 'foto_pendukung', label: 'Dokumen Pendukung'),
          ],
          langkahPanduan: [
            'Tentukan jenis permohonan KK.',
            'Isi nomor KK lama bila ada.',
            'Unggah foto KK lama, KTP kepala keluarga, dan dokumen pendukung.',
            'Kirim permohonan.',
          ],
        );
      case JenisLayanan.kia:
        return const DefinisiFormulir(
          ruas: [
            DefinisiRuas(nama: 'nik_anak', label: 'NIK Anak', tipe: TipeRuas.nik),
            DefinisiRuas(nama: 'nama_anak', label: 'Nama Anak', tipe: TipeRuas.teks),
            DefinisiRuas(nama: 'tgl_lahir', label: 'Tanggal Lahir', tipe: TipeRuas.tanggal),
          ],
          berkas: [
            DefinisiBerkas(nama: 'akta_lahir', label: 'Akta Kelahiran'),
            DefinisiBerkas(nama: 'foto_anak', label: 'Foto Anak', wajib: false),
          ],
          langkahPanduan: [
            'Pastikan anak sudah memiliki NIK.',
            'Unggah akta kelahiran.',
            'Foto anak opsional untuk kelengkapan.',
            'Kirim formulir.',
          ],
        );
      case JenisLayanan.aktaKelahiran:
        return const DefinisiFormulir(
          ruas: [
            DefinisiRuas(nama: 'nama_anak', label: 'Nama Anak', tipe: TipeRuas.teks),
            DefinisiRuas(nama: 'tempat_lahir', label: 'Tempat Lahir', tipe: TipeRuas.teks),
            DefinisiRuas(nama: 'tgl_lahir', label: 'Tanggal Lahir', tipe: TipeRuas.tanggal),
            DefinisiRuas(nama: 'nik_ayah', label: 'NIK Ayah', tipe: TipeRuas.nik),
            DefinisiRuas(nama: 'nik_ibu', label: 'NIK Ibu', tipe: TipeRuas.nik),
          ],
          berkas: [
            DefinisiBerkas(nama: 'surat_lahir', label: 'Surat Keterangan Lahir'),
            DefinisiBerkas(nama: 'foto_kk', label: 'Foto Kartu Keluarga'),
            DefinisiBerkas(nama: 'foto_buku_nikah', label: 'Buku Nikah Orang Tua'),
          ],
          langkahPanduan: [
            'Siapkan surat keterangan lahir dari faskes.',
            'Pastikan NIK ayah dan ibu sudah terdaftar.',
            'Unggah dokumen pendukung.',
            'Kirim permohonan.',
          ],
        );
      case JenisLayanan.aktaKematian:
        return const DefinisiFormulir(
          ruas: [
            DefinisiRuas(nama: 'nik_almarhum', label: 'NIK Almarhum', tipe: TipeRuas.nik),
            DefinisiRuas(nama: 'tgl_meninggal', label: 'Tanggal Meninggal', tipe: TipeRuas.tanggal),
            DefinisiRuas(nama: 'tempat_meninggal', label: 'Tempat Meninggal', tipe: TipeRuas.teks),
            DefinisiRuas(nama: 'penyebab', label: 'Penyebab', tipe: TipeRuas.teks),
          ],
          berkas: [
            DefinisiBerkas(nama: 'surat_kematian', label: 'Surat Keterangan Kematian'),
            DefinisiBerkas(nama: 'foto_kk', label: 'Foto Kartu Keluarga'),
          ],
          langkahPanduan: [
            'Dapatkan surat keterangan kematian.',
            'Siapkan KK terbaru.',
            'Isi data almarhum dengan teliti.',
            'Kirim permohonan.',
          ],
        );
      case JenisLayanan.perkawinanPerceraian:
        return const DefinisiFormulir(
          ruas: [
            DefinisiRuas(nama: 'sub_jenis', label: 'Jenis Pencatatan', tipe: TipeRuas.pilihan,
                pilihan: ['Perkawinan', 'Perceraian']),
            DefinisiRuas(nama: 'nik_pihak_1', label: 'NIK Pihak Pertama', tipe: TipeRuas.nik),
            DefinisiRuas(nama: 'nik_pihak_2', label: 'NIK Pihak Kedua', tipe: TipeRuas.nik),
            DefinisiRuas(nama: 'tanggal_peristiwa', label: 'Tanggal Peristiwa', tipe: TipeRuas.tanggal),
          ],
          berkas: [
            DefinisiBerkas(nama: 'akta_gereja', label: 'Akta Perkawinan/Perceraian Gereja'),
            DefinisiBerkas(nama: 'foto_pasangan', label: 'Foto Pasangan'),
          ],
          langkahPanduan: [
            'Layanan ini untuk pencatatan non-muslim.',
            'Lengkapi dokumen akta dari lembaga keagamaan.',
            'Isi data kedua pihak dengan benar.',
            'Kirim permohonan.',
          ],
        );
      case JenisLayanan.pindahDatang:
        return const DefinisiFormulir(
          ruas: [
            DefinisiRuas(nama: 'tujuan', label: 'Alamat Tujuan', tipe: TipeRuas.areaTeks),
            DefinisiRuas(nama: 'alasan', label: 'Alasan Pindah', tipe: TipeRuas.teks),
            DefinisiRuas(nama: 'jumlah_anggota', label: 'Jumlah Anggota Pindah', tipe: TipeRuas.angka),
          ],
          berkas: [
            DefinisiBerkas(nama: 'foto_kk', label: 'Foto Kartu Keluarga'),
            DefinisiBerkas(nama: 'foto_ktp', label: 'Foto KTP-el'),
          ],
          langkahPanduan: [
            'Pastikan alamat tujuan lengkap dengan RT/RW.',
            'Sertakan KK dan KTP pemohon.',
            'Cantumkan jumlah anggota keluarga yang ikut pindah.',
            'Kirim permohonan SKPWNI.',
          ],
        );
      case JenisLayanan.konsolidasiData:
        return const DefinisiFormulir(
          ruas: [
            DefinisiRuas(nama: 'jenis_perubahan', label: 'Jenis Perubahan', tipe: TipeRuas.pilihan,
                pilihan: ['Alamat', 'Status Perkawinan', 'Pendidikan', 'Pekerjaan']),
            DefinisiRuas(nama: 'detail', label: 'Detail Perubahan', tipe: TipeRuas.areaTeks),
          ],
          berkas: [
            DefinisiBerkas(nama: 'foto_pendukung', label: 'Dokumen Pendukung'),
          ],
          langkahPanduan: [
            'Pilih jenis data yang ingin diperbarui.',
            'Jelaskan secara singkat perubahan yang diinginkan.',
            'Unggah dokumen pendukung perubahan.',
            'Kirim permohonan.',
          ],
        );
      case JenisLayanan.legalisir:
        return const DefinisiFormulir(
          ruas: [
            DefinisiRuas(nama: 'jenis_dokumen', label: 'Jenis Dokumen', tipe: TipeRuas.pilihan,
                pilihan: ['Akta Kelahiran', 'Akta Kematian', 'Akta Perkawinan', 'Akta Perceraian']),
            DefinisiRuas(nama: 'jumlah_salinan', label: 'Jumlah Salinan', tipe: TipeRuas.angka),
          ],
          berkas: [
            DefinisiBerkas(nama: 'foto_dokumen', label: 'Salinan Dokumen'),
          ],
          langkahPanduan: [
            'Pilih jenis akta yang akan dilegalisir.',
            'Tentukan jumlah salinan.',
            'Unggah foto salinan dokumen yang jelas.',
            'Kirim permohonan.',
          ],
        );
      case JenisLayanan.pengaduan:
        return const DefinisiFormulir(
          ruas: [
            DefinisiRuas(nama: 'judul', label: 'Judul Pengaduan', tipe: TipeRuas.teks),
            DefinisiRuas(nama: 'kategori', label: 'Kategori', tipe: TipeRuas.pilihan,
                pilihan: ['Layanan Petugas', 'Sistem/Aplikasi', 'Lainnya']),
            DefinisiRuas(nama: 'isi', label: 'Uraian Pengaduan', tipe: TipeRuas.areaTeks, panjangMaks: 500),
          ],
          berkas: [
            DefinisiBerkas(nama: 'lampiran', label: 'Lampiran (opsional)', wajib: false),
          ],
          langkahPanduan: [
            'Tuliskan judul pengaduan yang singkat dan jelas.',
            'Pilih kategori yang sesuai.',
            'Uraikan kronologi dengan rinci.',
            'Lampirkan bukti bila ada, lalu kirim.',
          ],
        );
    }
  }
}
