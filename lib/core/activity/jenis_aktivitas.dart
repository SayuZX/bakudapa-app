enum JenisAktivitas {
  bukaLayar('buka_layar'),
  mulaiPermohonan('mulai_permohonan'),
  kirimPermohonan('kirim_permohonan'),
  unggahDokumen('unggah_dokumen'),
  unduhDokumen('unduh_dokumen'),
  lihatStatusPermohonan('lihat_status_permohonan'),
  lihatPemberitahuan('lihat_pemberitahuan'),
  bukaAiChat('buka_ai_chat'),
  kirimPesanAi('kirim_pesan_ai'),
  masuk('masuk'),
  keluar('keluar'),
  ubahBahasa('ubah_bahasa');

  const JenisAktivitas(this.kode);
  final String kode;
}
