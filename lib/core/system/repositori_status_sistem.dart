import 'package:dio/dio.dart';

import '../config/endpoints.dart';
import '../errors/kesalahan.dart';
import '../network/klien_jaringan.dart';
import 'model_status_maintenance.dart';

abstract class RepositoriStatusSistem {
  Future<StatusMaintenance> ambilStatus();
}

class RepositoriStatusSistemApi implements RepositoriStatusSistem {
  const RepositoriStatusSistemApi();

  static const String _endpoint = Endpoints.sistemMaintenance;

  @override
  Future<StatusMaintenance> ambilStatus() async {
    try {
      final r = await KlienJaringan.instance.dio.get(
        _endpoint,
        options: Options(
          sendTimeout: AmbangMaintenance.batasPermintaan,
          receiveTimeout: AmbangMaintenance.batasPermintaan,
          validateStatus: (s) => s != null && s < 600,
        ),
      );
      if (r.statusCode == 503) {
        return _aktif(r.data);
      }
      final data = r.data;
      if (data is Map) {
        return StatusMaintenance.dariJson(Map<String, dynamic>.from(data));
      }
      return _tidakAktif();
    } on DioException catch (e) {
      if (e.response?.statusCode == 503 || e.error is KesalahanMaintenance) {
        return _aktif(e.response?.data);
      }
      return _tidakAktif();
    } catch (_) {
      return _tidakAktif();
    }
  }

  StatusMaintenance _tidakAktif() =>
      StatusMaintenance(aktif: false, diperiksaPada: DateTime.now());

  StatusMaintenance _aktif(dynamic data) {
    if (data is Map) {
      final mentah = Map<String, dynamic>.from(data);
      final error = mentah['error'];
      final isi = error is Map
          ? Map<String, dynamic>.from(error)
          : mentah;
      final detail = isi['details'];
      String? teks(String kunci) {
        final v = isi[kunci] ?? mentah[kunci];
        return v is String && v.isNotEmpty ? v : null;
      }

      DateTime? estimasi;
      final kandidat = [
        if (detail is Map) detail['estimated_until'],
        if (detail is Map) detail['perkiraan_selesai'],
        mentah['estimated_until'],
        mentah['perkiraan_selesai'],
      ];
      for (final v in kandidat) {
        if (v is String && v.isNotEmpty) {
          final t = DateTime.tryParse(v);
          if (t != null) {
            estimasi = t;
            break;
          }
        }
      }

      return StatusMaintenance(
        aktif: true,
        judul: teks('title') ?? teks('judul'),
        pesan: teks('message') ?? teks('pesan'),
        estimasiSelesai: estimasi,
        kontakDukungan:
            (detail is Map ? detail['support_contact'] : null) as String? ??
            teks('support_contact'),
        diperiksaPada: DateTime.now(),
      );
    }
    return StatusMaintenance(aktif: true, diperiksaPada: DateTime.now());
  }
}
