import 'package:dio/dio.dart';

import '../../../core/errors/kesalahan.dart';
import '../../../core/network/klien_jaringan.dart';
import '../../../shared/models/pemberitahuan.dart';

class StatistikPemberitahuan {
  const StatistikPemberitahuan({
    required this.total,
    required this.belumDibaca,
    required this.perKategori,
  });

  final int total;
  final int belumDibaca;
  final Map<String, int> perKategori;

  factory StatistikPemberitahuan.kosong() =>
      const StatistikPemberitahuan(total: 0, belumDibaca: 0, perKategori: {});

  factory StatistikPemberitahuan.dariJson(Map<String, dynamic> json) {
    final perK = <String, int>{};
    final raw = json['per_kategori'] ?? json['per_category'];
    if (raw is Map) {
      raw.forEach((k, v) {
        if (v is int) perK[k.toString()] = v;
      });
    }
    return StatistikPemberitahuan(
      total: (json['total'] as int?) ?? 0,
      belumDibaca:
          (json['belum_dibaca'] as int?) ?? (json['unread'] as int?) ?? 0,
      perKategori: perK,
    );
  }
}

abstract class RepositoriPemberitahuan {
  Future<List<Pemberitahuan>> daftar({int halaman = 1, int ukuran = 20, String? kategori});
  Future<int> jumlahBelumDibaca();
  Future<StatistikPemberitahuan> statistik();
  Future<Pemberitahuan?> detail(String id);
  Future<void> tandaiDibaca(String id);
  Future<void> tandaiSemuaDibaca();
}

class RepositoriPemberitahuanApi implements RepositoriPemberitahuan {
  RepositoriPemberitahuanApi({Dio? dio}) : _dio = dio ?? KlienJaringan.instance.dio;
  final Dio _dio;

  @override
  Future<List<Pemberitahuan>> daftar({int halaman = 1, int ukuran = 20, String? kategori}) async {
    try {
      final params = <String, dynamic>{
        'page': halaman,
        'page_size': ukuran,
        if (kategori != null && kategori.isNotEmpty) 'category': kategori,
      };
      final res = await _dio.get('/notifications', queryParameters: params);
      final body = res.data as Map<String, dynamic>;
      return (body['data'] as List<dynamic>? ?? const [])
          .map((e) => Pemberitahuan.dariJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    } catch (_) {
      throw const KesalahanTakDikenal();
    }
  }

  @override
  Future<int> jumlahBelumDibaca() async {
    try {
      final res = await _dio.get('/notifications/unread-count');
      final data = _bacaData(res.data) ?? const {};
      return (data['unread_count'] as int?) ??
          (data['jumlah'] as int?) ??
          0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<StatistikPemberitahuan> statistik() async {
    try {
      final res = await _dio.get('/notifications/stats');
      final data = _bacaData(res.data) ?? const {};
      return StatistikPemberitahuan.dariJson(data);
    } catch (_) {
      return StatistikPemberitahuan.kosong();
    }
  }

  @override
  Future<Pemberitahuan?> detail(String id) async {
    try {
      final res = await _dio.get('/notifications/$id');
      final data = _bacaData(res.data);
      if (data == null) return null;
      return Pemberitahuan.dariJson(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> tandaiDibaca(String id) async {
    try {
      await _dio.put('/notifications/$id/mark-as-read');
    } catch (_) {}
  }

  @override
  Future<void> tandaiSemuaDibaca() async {
    try {
      await _dio.put('/notifications/mark-all-as-read');
    } catch (_) {}
  }

  Map<String, dynamic>? _bacaData(dynamic body) {
    if (body is! Map) return null;
    final map = Map<String, dynamic>.from(body);
    final inner = map['data'];
    if (inner is Map) return Map<String, dynamic>.from(inner);
    return map;
  }
}
