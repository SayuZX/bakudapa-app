import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/ai/model_ai_chat.dart';
import '../../../core/config/endpoints.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/network/klien_jaringan.dart';
import '../domain/repositori_ai_chat.dart';

class RepositoriAiChatApi implements RepositoriAiChat {
  RepositoriAiChatApi({Dio? dio}) : _dio = dio ?? KlienJaringan.instance.dio;

  final Dio _dio;

  static const Duration _batasTerima = Duration(seconds: 100);
  static const Duration _deadlinePolling = Duration(seconds: 90);
  static const Duration _selangPolling = Duration(milliseconds: 1200);

  @override
  Future<HasilBalasanAi> tanya({
    required String pesan,
    String? sesiId,
    Map<String, dynamic>? konteks,
    bool lanjutkan = false,
    CancelToken? batal,
  }) async {
    try {
      final res = await _dio.post(
        Endpoints.aiTanya,
        data: {
          'pesan': pesan,
          if (sesiId != null && sesiId.isNotEmpty) 'sesi_id': sesiId,
        },
        options: Options(receiveTimeout: _batasTerima),
        cancelToken: batal,
      );
      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const KesalahanAi('Respons AI tidak valid.');
      }

      final kirim = HasilKirimAi.dariJson(data);

      if (kirim.adaBalasanLangsung) {
        return HasilBalasanAi.dariJson(data);
      }

      final pesanId = kirim.pesanId;
      if (pesanId == null || pesanId.isEmpty) {
        throw const KesalahanAi('Respons AI tidak valid.');
      }

      final teks = kirim.stream
          ? await _viaStream(pesanId, batal)
          : await _viaPolling(pesanId, batal);

      return HasilBalasanAi(
        sesiId: kirim.sesiId.isNotEmpty ? kirim.sesiId : (sesiId ?? ''),
        balasan: teks,
        selesai: true,
      );
    } on Kesalahan {
      rethrow;
    } on DioException catch (e) {
      if (e.error is Kesalahan) throw e.error! as Kesalahan;
      throw const KesalahanAi();
    } catch (_) {
      throw const KesalahanAi();
    }
  }

  Future<String> _viaPolling(String pesanId, CancelToken? batal) async {
    final deadline = DateTime.now().add(_deadlinePolling);
    while (DateTime.now().isBefore(deadline)) {
      if (batal?.isCancelled ?? false) return '';
      final res = await _dio.get(
        Endpoints.aiPesan(pesanId),
        options: Options(receiveTimeout: const Duration(seconds: 30)),
        cancelToken: batal,
      );
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final hasil = HasilPesanAi.dariJson(data);
        if (hasil.gagal) {
          throw KesalahanAi(hasil.errorPesan ?? 'Asisten AI gagal merespons.');
        }
        if (hasil.selesai || (!hasil.mengetik && hasil.balasan.isNotEmpty)) {
          return hasil.balasan;
        }
      }
      await Future<void>.delayed(_selangPolling);
    }
    throw const KesalahanBatasWaktu();
  }

  Future<String> _viaStream(String pesanId, CancelToken? batal) async {
    final res = await _dio.get<ResponseBody>(
      Endpoints.aiPesanStream(pesanId),
      options: Options(
        responseType: ResponseType.stream,
        receiveTimeout: _batasTerima,
        headers: {'Accept': 'text/event-stream'},
      ),
      cancelToken: batal,
    );

    final aliran = res.data;
    if (aliran == null) throw const KesalahanAi();

    final akumulasi = StringBuffer();
    var teksSelesai = '';
    var sisaBaris = '';
    var peristiwa = '';
    var selesai = false;

    await for (final potongan in aliran.stream) {
      if (batal?.isCancelled ?? false) break;
      sisaBaris += utf8.decode(potongan, allowMalformed: true);
      final baris = sisaBaris.split('\n');
      sisaBaris = baris.removeLast();

      for (final mentah in baris) {
        final garis = mentah.trimRight();
        if (garis.isEmpty) {
          peristiwa = '';
          continue;
        }
        if (garis.startsWith('event:')) {
          peristiwa = garis.substring(6).trim();
          continue;
        }
        if (garis.startsWith('data:')) {
          final muatan = garis.substring(5).trim();
          if (muatan.isEmpty) continue;
          final obj = _uraikan(muatan);
          if (obj == null) continue;
          switch (peristiwa) {
            case 'token':
              final delta = obj['delta'];
              if (delta is String) akumulasi.write(delta);
            case 'done':
              final isi = obj['isi'];
              if (isi is String) teksSelesai = isi;
              selesai = true;
            case 'error':
              throw KesalahanAi(
                obj['message']?.toString() ?? 'Asisten AI gagal merespons.',
              );
          }
        }
      }
      if (selesai) break;
    }

    final hasil = teksSelesai.isNotEmpty ? teksSelesai : akumulasi.toString();
    if (hasil.trim().isEmpty) throw const KesalahanAi();
    return hasil;
  }

  Map<String, dynamic>? _uraikan(String muatan) {
    try {
      final hasil = jsonDecode(muatan);
      return hasil is Map<String, dynamic> ? hasil : null;
    } catch (_) {
      return null;
    }
  }
}
