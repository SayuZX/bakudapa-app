import 'package:dio/dio.dart';

import '../network/klien_jaringan.dart';
import 'model_status_maintenance.dart';

abstract class RepositoriStatusSistem {
  Future<StatusMaintenance> ambilStatus();
}

class RepositoriStatusSistemApi implements RepositoriStatusSistem {
  const RepositoriStatusSistemApi();

  static const String _endpoint = '/system/maintenance';

  @override
  Future<StatusMaintenance> ambilStatus() async {
    try {
      final r = await KlienJaringan.instance.dio.get(
        _endpoint,
        options: Options(
          sendTimeout: AmbangMaintenance.batasPermintaan,
          receiveTimeout: AmbangMaintenance.batasPermintaan,
          validateStatus: (s) => s != null && s < 500,
        ),
      );
      final data = r.data;
      if (data is Map && data['data'] is Map) {
        final isi = (data['data'] as Map).cast<String, dynamic>();
        return StatusMaintenance.dariJson(isi);
      }
      return StatusMaintenance.tidakAktif;
    } on DioException {
      return StatusMaintenance.tidakAktif;
    } catch (_) {
      return StatusMaintenance.tidakAktif;
    }
  }
}

class RepositoriStatusSistemDummy implements RepositoriStatusSistem {
  const RepositoriStatusSistemDummy();

  @override
  Future<StatusMaintenance> ambilStatus() async {
    return StatusMaintenance.tidakAktif;
  }
}
