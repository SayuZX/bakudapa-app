import 'package:dio/dio.dart';

import '../network/klien_jaringan.dart';

enum PeristiwaAudit {
  vpnTerdeteksi('vpn_terdeteksi'),
  rootTerdeteksi('root_terdeteksi'),
  emulatorTerdeteksi('emulator_terdeteksi'),
  fingerprintGagal('fingerprint_gagal'),
  loginGagal('login_gagal'),
  loginSukses('login_sukses');

  const PeristiwaAudit(this.kode);
  final String kode;
}

enum TingkatAudit {
  info('info'),
  peringatan('peringatan'),
  kritis('kritis');

  const TingkatAudit(this.kode);
  final String kode;
}

class LayananAuditKeamanan {
  LayananAuditKeamanan._();
  static final LayananAuditKeamanan instance = LayananAuditKeamanan._();

  Future<void> catat({
    required PeristiwaAudit peristiwa,
    TingkatAudit tingkat = TingkatAudit.info,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await KlienJaringan.instance.dio.post(
        '/biometrik/audit',
        data: {
          'peristiwa': peristiwa.kode,
          'tingkat': tingkat.kode,
          if (metadata != null && metadata.isNotEmpty) 'metadata': metadata,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          extra: const {'anonim': true},
        ),
      );
    } catch (_) {}
  }
}
