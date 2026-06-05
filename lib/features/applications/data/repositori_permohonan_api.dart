import 'dart:io';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/kesalahan.dart';
import '../../../core/network/klien_jaringan.dart';
import '../../../shared/models/halaman_data.dart';
import '../../../shared/models/jenis_layanan.dart';
import '../../../shared/models/permohonan.dart';
import '../domain/repositori_permohonan.dart';

class RepositoriPermohonanApi implements RepositoriPermohonan {
  RepositoriPermohonanApi({Dio? dio}) : _dio = dio ?? KlienJaringan.instance.dio;
  final Dio _dio;

  @override
  Future<HalamanData<Permohonan>> mintaRiwayat({
    int halaman = 1,
    int ukuran = 15,
    String? kueriPencarian,
  }) async {
    try {
      final res = await _dio.get(
        '/permohonan',
        queryParameters: {
          'halaman': halaman,
          'ukuran': ukuran,
          if (kueriPencarian != null && kueriPencarian.isNotEmpty) 'kueri': kueriPencarian,
        },
      );
      final body = res.data as Map<String, dynamic>;
      final daftar = (body['data'] as List<dynamic>? ?? const [])
          .map((e) => Permohonan.dariJson(e as Map<String, dynamic>))
          .toList();
      final meta = body['meta'] as Map<String, dynamic>? ?? const {};
      return HalamanData(
        daftar: daftar,
        halaman: meta['halaman'] as int? ?? halaman,
        totalHalaman: meta['total_halaman'] as int? ?? 1,
        totalItem: meta['total_item'] as int? ?? daftar.length,
      );
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    } catch (_) {
      throw const KesalahanTakDikenal();
    }
  }

  @override
  Future<Permohonan> mintaDetail(String id) async {
    try {
      final res = await _dio.get('/permohonan/$id');
      final body = res.data as Map<String, dynamic>;
      return Permohonan.dariJson(body['data'] as Map<String, dynamic>? ?? body);
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    } catch (_) {
      throw const KesalahanTakDikenal();
    }
  }

  @override
  Future<RingkasanStatus> mintaRingkasan() async {
    try {
      final res = await _dio.get('/permohonan/ringkasan');
      final data = _bacaData(res.data) ?? const {};
      return RingkasanStatus(
        menunggu: data['menunggu'] as int? ?? 0,
        berjalan: data['berjalan'] as int? ?? 0,
        selesai: data['selesai'] as int? ?? 0,
      );
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    } catch (_) {
      throw const KesalahanTakDikenal();
    }
  }

  @override
  Future<Permohonan> ajukan({
    required JenisLayanan jenis,
    required Map<String, dynamic> data,
    required List<File> lampiran,
  }) async {
    try {
      final form = FormData();
      form.fields.add(MapEntry('jenis', jenis.kode));
      data.forEach((k, v) => form.fields.add(MapEntry(k, v?.toString() ?? '')));
      for (var i = 0; i < lampiran.length; i++) {
        final berkas = lampiran[i];
        form.files.add(
          MapEntry(
            'lampiran[]',
            await MultipartFile.fromFile(berkas.path, filename: berkas.uri.pathSegments.last),
          ),
        );
      }
      final res = await _dio.post(
        '/permohonan',
        data: form,
        options: Options(headers: {'X-Idempotency-Key': const Uuid().v4()}),
      );
      return Permohonan.dariJson(_bacaData(res.data) ?? const {});
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    } catch (_) {
      throw const KesalahanTakDikenal();
    }
  }

  @override
  Future<String> unduhDokumenHasil(String idPermohonan) async {
    try {
      final res = await _dio.get('/permohonan/$idPermohonan/dokumen');
      final data = _bacaData(res.data) ?? const {};
      return data['url']?.toString() ?? '';
    } on DioException catch (e) {
      throw e.error is Kesalahan ? e.error! as Kesalahan : const KesalahanTakDikenal();
    } catch (_) {
      throw const KesalahanTakDikenal();
    }
  }

  Map<String, dynamic>? _bacaData(dynamic body) {
    if (body is! Map) return null;
    final map = Map<String, dynamic>.from(body);
    final inner = map['data'];
    if (inner is Map) return Map<String, dynamic>.from(inner);
    return map;
  }
}
