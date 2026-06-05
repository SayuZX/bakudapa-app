import 'detektor_vpn.dart';
import 'layanan_integritas_perangkat.dart';

enum AlasanBlokir { tidakAda, vpn, perangkatTidakAman, gagalCek }

class LaporanKeamanan {
  const LaporanKeamanan({
    required this.alasan,
    this.namaAntarmukaVpn,
    this.detailIntegritas,
  });

  final AlasanBlokir alasan;
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

      if (!integritas.aman) {
        return LaporanKeamanan(
          alasan: AlasanBlokir.perangkatTidakAman,
          detailIntegritas: integritas,
        );
      }
      if (vpn.aktif) {
        return LaporanKeamanan(
          alasan: AlasanBlokir.vpn,
          namaAntarmukaVpn: vpn.antarmuka,
        );
      }
      return const LaporanKeamanan(alasan: AlasanBlokir.tidakAda);
    } catch (_) {
      return const LaporanKeamanan(alasan: AlasanBlokir.gagalCek);
    }
  }
}
