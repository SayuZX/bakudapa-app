import '../enums/peristiwa_audit.dart';
import '../services/layanan_sidik_perangkat.dart';
import 'detektor_vpn.dart';
import 'layanan_audit_keamanan.dart';
import 'layanan_integritas_perangkat.dart';

enum AlasanBlokir { tidakAda, perangkatTidakAman, gagalCek }

class LaporanKeamanan {
  const LaporanKeamanan({
    required this.alasan,
    this.vpnAktif = false,
    this.namaAntarmukaVpn,
    this.detailIntegritas,
  });

  final AlasanBlokir alasan;
  final bool vpnAktif;
  final String? namaAntarmukaVpn;
  final HasilIntegritas? detailIntegritas;

  bool get aman => alasan == AlasanBlokir.tidakAda;
  bool get terblokir => !aman;
}

class PenjagaKeamanan {
  PenjagaKeamanan._();
  static final PenjagaKeamanan instance = PenjagaKeamanan._();

  Future<LaporanKeamanan> periksa() async {
    try {
      final hasilFutures = await Future.wait([
        DetektorVpn.instance.periksa(),
        LayananIntegritasPerangkat.instance.periksa(),
      ]);
      final vpn = hasilFutures[0] as HasilDetektorVpn;
      final integritas = hasilFutures[1] as HasilIntegritas;

      await _catatTemuan(integritas: integritas, vpn: vpn);

      if (!integritas.aman) {
        return LaporanKeamanan(
          alasan: integritas.galat != null
              ? AlasanBlokir.gagalCek
              : AlasanBlokir.perangkatTidakAman,
          vpnAktif: vpn.aktif,
          namaAntarmukaVpn: vpn.antarmuka,
          detailIntegritas: integritas,
        );
      }

      return LaporanKeamanan(
        alasan: AlasanBlokir.tidakAda,
        vpnAktif: vpn.aktif,
        namaAntarmukaVpn: vpn.antarmuka,
        detailIntegritas: integritas,
      );
    } catch (_) {
      return const LaporanKeamanan(alasan: AlasanBlokir.gagalCek);
    }
  }

  Future<void> _catatTemuan({
    required HasilIntegritas integritas,
    required HasilDetektorVpn vpn,
  }) async {
    final peristiwa = <(PeristiwaAudit, TingkatAudit)>[];
    if (integritas.terootJailbreak) {
      peristiwa.add((PeristiwaAudit.rootTerdeteksi, TingkatAudit.kritis));
    }
    if (integritas.frida) {
      peristiwa.add((PeristiwaAudit.fridaTerdeteksi, TingkatAudit.kritis));
    }
    if (integritas.debugger) {
      peristiwa.add((PeristiwaAudit.debuggerTerdeteksi, TingkatAudit.kritis));
    }
    if (integritas.tandaTanganTidakValid) {
      peristiwa.add((PeristiwaAudit.tandaTanganTidakValid, TingkatAudit.kritis));
    }
    if (integritas.emulator) {
      peristiwa.add((PeristiwaAudit.emulatorTerdeteksi, TingkatAudit.peringatan));
    }
    if (integritas.galat != null) {
      peristiwa.add((PeristiwaAudit.integritasGagalCek, TingkatAudit.peringatan));
    }
    if (vpn.aktif) {
      peristiwa.add((PeristiwaAudit.vpnTerdeteksi, TingkatAudit.info));
    }
    if (peristiwa.isEmpty) return;

    final metadata = await _metadata(integritas);
    await Future.wait([
      for (final (p, t) in peristiwa)
        LayananAuditKeamanan.instance.catat(
          peristiwa: p,
          tingkat: t,
          metadata: metadata,
        ),
    ]);
  }

  Future<Map<String, dynamic>> _metadata(HasilIntegritas integritas) async {
    try {
      final identitas = await LayananSidikPerangkat.instance.identitas();
      return {
        if (identitas.os.isNotEmpty) 'os': identitas.os,
        if (identitas.model.isNotEmpty) 'model': identitas.model,
        if (identitas.versiAplikasi.isNotEmpty)
          'app_version': identitas.versiAplikasi,
        if (integritas.ringkasan.isNotEmpty) 'tanda': integritas.ringkasan,
      };
    } catch (_) {
      return {
        if (integritas.ringkasan.isNotEmpty) 'tanda': integritas.ringkasan,
      };
    }
  }
}
