import 'package:dio/dio.dart';

import '../../../core/config/endpoints.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/network/klien_jaringan.dart';
import '../../../shared/models/halaman_data.dart';
import '../../../shared/models/pemberitahuan.dart';

abstract class RepositoriPemberitahuan {
  Future<HalamanData<Pemberitahuan>> daftar({
    int halaman = 1,
    int ukuran = 20,
    bool? dibaca,
    String? kategori,
  });

  Future<int> jumlahBelumDibaca();

  Future<void> tandaiDibaca(String id);

  Future<void> tandaiSemuaDibaca();
}

class RepositoriPemberitahuanApi implements RepositoriPemberitahuan {
  RepositoriPemberitahuanApi({Dio? dio})
    : _dio = dio ?? KlienJaringan.instance.dio;
  final Dio _dio;

  @override
  Future<HalamanData<Pemberitahuan>> daftar({
    int halaman = 1,
    int ukuran = 20,
    bool? dibaca,
    String? kategori,
  }) async {
    try {
      final res = await _dio.get(
        Endpoints.pemberitahuan,
        queryParameters: {
          'halaman': halaman,
          'per_halaman': ukuran,
          'dibaca': ?dibaca,
          'kategori': ?kategori,
        },
      );
      final daftar = _daftarMap(res.data).map(Pemberitahuan.dariJson).toList();
      final meta = _bacaMeta(res);
      return HalamanData(
        daftar: daftar,
        halaman: _angka(meta['halaman'] ?? meta['current_page']) ?? halaman,
        totalHalaman: _angka(meta['total_halaman'] ?? meta['total_pages']) ?? 1,
        totalItem:
            _angka(meta['total'] ?? meta['total_count']) ?? daftar.length,
      );
    } on DioException catch (e) {
      throw e.error is Kesalahan
          ? e.error! as Kesalahan
          : const KesalahanTakDikenal();
    }
  }

  @override
  Future<int> jumlahBelumDibaca() async {
    try {
      final res = await _dio.get(Endpoints.pemberitahuanJumlahBelumDibaca);
      final data = res.data;
      if (data is Map) {
        return _angka(
              data['jumlah'] ?? data['count'] ?? data['unread_count'],
            ) ??
            0;
      }
      return 0;
    } on DioException catch (e) {
      throw e.error is Kesalahan
          ? e.error! as Kesalahan
          : const KesalahanTakDikenal();
    }
  }

  @override
  Future<void> tandaiDibaca(String id) async {
    try {
      await _dio.post(Endpoints.pemberitahuanTandaiDibaca(id));
    } on DioException catch (e) {
      throw e.error is Kesalahan
          ? e.error! as Kesalahan
          : const KesalahanTakDikenal();
    }
  }

  @override
  Future<void> tandaiSemuaDibaca() async {
    try {
      await _dio.post(Endpoints.pemberitahuanTandaiSemua);
    } on DioException catch (e) {
      throw e.error is Kesalahan
          ? e.error! as Kesalahan
          : const KesalahanTakDikenal();
    }
  }
}

int? _angka(dynamic nilai) {
  if (nilai is int) return nilai;
  if (nilai is num) return nilai.toInt();
  return int.tryParse('$nilai');
}

List<Map<String, dynamic>> _daftarMap(dynamic body) {
  dynamic isi = body;
  if (isi is Map) {
    isi =
        isi['pemberitahuan'] ??
        isi['data'] ??
        isi['items'] ??
        isi['list'] ??
        isi.values.firstWhere((v) => v is List, orElse: () => null);
  }
  if (isi is List) {
    return isi
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  return const [];
}

Map<String, dynamic> _bacaMeta(Response res) {
  final ekstra = res.extra['meta'];
  if (ekstra is Map) return Map<String, dynamic>.from(ekstra);
  return const {};
}
