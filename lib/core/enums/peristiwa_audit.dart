enum PeristiwaAudit {
  vpnTerdeteksi('vpn_terdeteksi'),
  rootTerdeteksi('root_terdeteksi'),
  emulatorTerdeteksi('emulator_terdeteksi'),
  fridaTerdeteksi('frida_terdeteksi'),
  debuggerTerdeteksi('debugger_terdeteksi'),
  tandaTanganTidakValid('tanda_tangan_tidak_valid'),
  integritasGagalCek('integritas_gagal_cek'),
  fingerprintGagal('fingerprint_gagal'),
  livenessGagal('liveness_gagal'),
  fotoWajahDitolak('foto_wajah_ditolak'),
  pelanggaranPersetujuan('pelanggaran_persetujuan');

  const PeristiwaAudit(this.value);
  final String value;
}

enum TingkatAudit {
  info('info'),
  peringatan('peringatan'),
  kritis('kritis');

  const TingkatAudit(this.value);
  final String value;
}
