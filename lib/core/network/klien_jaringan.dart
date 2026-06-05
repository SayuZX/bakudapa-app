import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/api_config.dart';
import '../config/storage_keys.dart';
import '../errors/kesalahan.dart';
import '../services/penyimpanan_aman.dart';
import 'pencegat_amplop.dart';
import 'pencegat_maintenance.dart';
import 'pencegat_otentikasi.dart';

typedef SaatTidakBerwenang = Future<void> Function();

class KlienJaringan {
  KlienJaringan._();
  static final KlienJaringan instance = KlienJaringan._();

  late final Dio _dio = _bangun();
  late final Dio _dioPenyegar = _bangunPenyegar();
  SaatTidakBerwenang? _penanganTidakBerwenang;

  Dio get dio => _dio;

  void daftarPenanganTidakBerwenang(SaatTidakBerwenang penangan) {
    _penanganTidakBerwenang = penangan;
  }

  void aturBahasa(String kode) {
    _dio.options.headers['Accept-Language'] = kode;
    _dioPenyegar.options.headers['Accept-Language'] = kode;
  }

  Dio _bangun() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.uploadTimeout,
        responseType: ResponseType.json,
        headers: {
          'Accept': 'application/json',
          'Accept-Version': ApiConfig.apiVersion,
          'Accept-Language': 'id',
          'X-Client': 'bakudapa-mobile',
        },
        validateStatus: (s) => s != null && s < 500,
      ),
    );

    dio.interceptors.addAll([
      PencegatMaintenance(),
      PencegatOtentikasi(
        penyimpanan: PenyimpananAman.instance,
        dioPenyegar: _dioPenyegar,
        saatTidakBerwenang: () async {
          await _penanganTidakBerwenang?.call();
        },
      ),
      PencegatAmplop(),
      _NormalisasiKesalahan(),
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: false,
          requestBody: false,
          responseBody: false,
          responseHeader: false,
          compact: true,
          maxWidth: 80,
        ),
    ]);

    return dio;
  }

  Dio _bangunPenyegar() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.connectTimeout,
        responseType: ResponseType.json,
        headers: {
          'Accept': 'application/json',
          'Accept-Version': ApiConfig.apiVersion,
          'Accept-Language': 'id',
          'X-Client': 'bakudapa-mobile',
        },
        validateStatus: (s) => s != null && s < 500,
      ),
    );
  }

  Future<void> bersihkanOtentikasi() async {
    await PenyimpananAman.instance.hapus(StorageKeys.accessToken);
    await PenyimpananAman.instance.hapus(StorageKeys.refreshToken);
    await PenyimpananAman.instance.hapus(StorageKeys.kedaluwarsa);
  }
}

class _NormalisasiKesalahan extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is KesalahanMaintenance) {
      handler.next(err);
      return;
    }
    final dipetakan = _petakan(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: dipetakan,
        type: err.type,
        response: err.response,
      ),
    );
  }

  Kesalahan _petakan(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const KesalahanBatasWaktu();
      case DioExceptionType.connectionError:
        return const KesalahanJaringan();
      case DioExceptionType.cancel:
        return const KesalahanTakDikenal('Permintaan dibatalkan.');
      case DioExceptionType.badCertificate:
        return const KesalahanJaringan('Sertifikat tidak valid.');
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        final status = err.response?.statusCode;
        final data = err.response?.data;
        final amplop = _uraikanAmplop(data);
        return _dariKode(status, amplop);
    }
  }

  Kesalahan _dariKode(int? status, _AmplopGalat amplop) {
    final pesan = amplop.pesan;
    final details = amplop.details;
    switch (amplop.kode) {
      case KodeKesalahanBackend.invalidCredentials:
        return KesalahanKredensialSalah(pesan ?? 'Identitas atau kata sandi salah.');
      case KodeKesalahanBackend.accountBlocked:
        DateTime? terblokirSampai;
        final raw = details?['terblokir_sampai'];
        if (raw is String) {
          terblokirSampai = DateTime.tryParse(raw);
        }
        return KesalahanAkunDiblokir(
          pesan: pesan ?? 'Akun terkunci sementara.',
          terblokirSampai: terblokirSampai,
        );
      case KodeKesalahanBackend.conflict:
        return KesalahanKonflik(pesan ?? 'Data sudah terdaftar.');
      case KodeKesalahanBackend.rateLimited:
        final detik = details?['retry_after_seconds'];
        return KesalahanBatasFrekuensiDenganRetry(
          pesan: pesan ?? 'Terlalu banyak percobaan. Coba lagi nanti.',
          detikUlang: detik is int ? detik : null,
        );
      case KodeKesalahanBackend.aiUnavailable:
        return KesalahanAiTidakTersedia(pesan ?? 'Asisten AI sedang tidak tersedia.');
      case KodeKesalahanBackend.aiError:
        return KesalahanAi(pesan ?? 'Layanan AI sedang terganggu.');
      case KodeKesalahanBackend.visionError:
        return KesalahanVisi(pesan ?? 'Analisis gambar gagal.');
      case KodeKesalahanBackend.faceServiceError:
        return KesalahanLayananWajah(pesan ?? 'Layanan verifikasi wajah sedang bermasalah.');
      case KodeKesalahanBackend.facePhotoBlocked:
        return KesalahanFotoWajahDiblokir(
          pesan ?? 'Percobaan foto wajah habis.',
        );
      case KodeKesalahanBackend.resourceEmpty:
        return KesalahanSumberKosong(pesan ?? 'Sumber data belum tersedia.');
      case KodeKesalahanBackend.validationError:
        return KesalahanValidasi(
          pesan ?? 'Data tidak valid.',
          kesalahanRuas: _uraikanRuas(details),
        );
      case KodeKesalahanBackend.unauthorized:
        return KesalahanTidakBerwenang(pesan ?? 'Sesi Anda telah berakhir.');
      case KodeKesalahanBackend.notFound:
        return KesalahanTidakDitemukan(pesan ?? 'Data tidak ditemukan.');
      case KodeKesalahanBackend.maintenanceMode:
        return KesalahanMaintenance(
          pesan: pesan ?? 'Layanan sedang dalam pemeliharaan.',
          judul: amplop.judul,
        );
    }
    switch (status) {
      case 400:
        return KesalahanValidasi(
          pesan ?? 'Permintaan tidak valid.',
          kesalahanRuas: _uraikanRuas(details),
        );
      case 401:
        return KesalahanTidakBerwenang(pesan ?? 'Sesi Anda telah berakhir.');
      case 403:
        return KesalahanDilarang(pesan ?? 'Akses ditolak.');
      case 404:
        return KesalahanTidakDitemukan(pesan ?? 'Data tidak ditemukan.');
      case 409:
        return KesalahanKonflik(pesan ?? 'Data sudah terdaftar.');
      case 422:
        return KesalahanValidasi(
          pesan ?? 'Data tidak lolos validasi.',
          kesalahanRuas: _uraikanRuas(details),
        );
      case 429:
        return const KesalahanBatasFrekuensi();
      default:
        return KesalahanServer(pesan ?? 'Layanan sedang bermasalah.');
    }
  }

  _AmplopGalat _uraikanAmplop(dynamic data) {
    if (data is! Map) return const _AmplopGalat();
    final isi = data['error'];
    if (isi is Map) {
      final detailsMap = isi['details'];
      return _AmplopGalat(
        kode: isi['code'] is String ? isi['code'] as String : null,
        judul: isi['title'] is String ? isi['title'] as String : null,
        pesan: isi['message'] is String ? isi['message'] as String : null,
        details: detailsMap is Map
            ? Map<String, dynamic>.from(detailsMap)
            : null,
      );
    }
    return _AmplopGalat(
      pesan: data['message'] is String ? data['message'] as String : null,
    );
  }

  Map<String, String>? _uraikanRuas(dynamic data) {
    if (data is! Map) return null;
    final ruas = data['errors'] ?? data['fields'] ?? data;
    if (ruas is! Map) return null;
    final keluar = <String, String>{};
    ruas.forEach((k, v) {
      if (v is List && v.isNotEmpty) {
        keluar[k.toString()] = v.first.toString();
      } else if (v is String) {
        keluar[k.toString()] = v;
      }
    });
    return keluar.isEmpty ? null : keluar;
  }
}

class _AmplopGalat {
  const _AmplopGalat({
    this.kode,
    this.judul,
    this.pesan,
    this.details,
  });

  final String? kode;
  final String? judul;
  final String? pesan;
  final Map<String, dynamic>? details;
}
