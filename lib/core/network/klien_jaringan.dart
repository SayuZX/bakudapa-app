import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../shared/models/perangkat_aktif.dart';
import '../config/api_config.dart';
import '../config/storage_keys.dart';
import '../enums/peristiwa_audit.dart';
import '../errors/kesalahan.dart';
import '../security/layanan_audit_keamanan.dart';
import '../services/penyimpanan_aman.dart';
import 'pencegat_amplop.dart';
import 'pencegat_maintenance.dart';
import 'pencegat_otentikasi.dart';
import 'pin_ssl.dart';

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
        validateStatus: (s) => s != null && s >= 200 && s < 300,
      ),
    );

    dio.interceptors.addAll([
      PencegatMaintenance(),
      PencegatOtentikasi(
        penyimpanan: PenyimpananAman.instance,
        dioPenyegar: _dioPenyegar,
        saatTidakBerwenang: () async {
          await bersihkanOtentikasi();
          await _penanganTidakBerwenang?.call();
        },
      ),
      PencegatAmplop(),
      _NormalisasiKesalahan(),
    ]);

    PinSsl.pasang(dio);
    return dio;
  }

  Dio _bangunPenyegar() {
    final dioPenyegar = Dio(
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
        validateStatus: (s) => s != null && s >= 200 && s < 300,
      ),
    );
    PinSsl.pasang(dioPenyegar);
    return dioPenyegar;
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
    if (_pinningGagal(err)) {
      _catatPinningGagal(err);
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const KesalahanJaringan(
            'Koneksi tidak aman terdeteksi. Permintaan dihentikan.',
          ),
          type: err.type,
          response: err.response,
        ),
      );
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

  bool _pinningGagal(DioException err) {
    if (err.type == DioExceptionType.badCertificate) return true;
    final galat = err.error;
    if (galat is HandshakeException) return true;
    if (galat is TlsException) return true;
    return false;
  }

  void _catatPinningGagal(DioException err) {
    if (err.requestOptions.extra['anonim'] == true) return;
    unawaited(
      LayananAuditKeamanan.instance.catat(
        peristiwa: PeristiwaAudit.fingerprintGagal,
        tingkat: TingkatAudit.kritis,
        metadata: {'host': err.requestOptions.uri.host},
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
      case KodeKesalahanBackend.duplicateRecord:
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
      case KodeKesalahanBackend.batasPerangkatTercapai:
        final daftar = details?['perangkat_aktif'] ?? details?['active_devices'];
        final batas = details?['batas'] ?? details?['limit'];
        return KesalahanBatasPerangkat(
          pesan: pesan ?? 'Akun sudah digunakan pada 2 perangkat aktif.',
          batas: batas is int
              ? batas
              : int.tryParse(batas?.toString() ?? ''),
          perangkatAktif: daftar is List
              ? daftar
                    .whereType<Map>()
                    .map(
                      (e) =>
                          PerangkatAktif.dariJson(Map<String, dynamic>.from(e)),
                    )
                    .toList()
              : const [],
        );
      case KodeKesalahanBackend.sessionRevoked:
      case KodeKesalahanBackend.invalidRefreshToken:
        return KesalahanTidakBerwenang(pesan ?? 'Sesi Anda telah berakhir.');
      case KodeKesalahanBackend.sesiTidakValid:
        return KesalahanSesiTidakValid(pesan ?? 'Perangkat yang dipilih tidak valid.');
      case KodeKesalahanBackend.sesiSudahTidakAktif:
        return KesalahanSesiSudahTidakAktif(pesan ?? 'Perangkat sudah tidak aktif.');
      case KodeKesalahanBackend.storageNotConfigured:
        return KesalahanUnggah(
          pesan ?? 'Layanan penyimpanan belum siap. Coba lagi nanti.',
        );
      case KodeKesalahanBackend.storageError:
        return KesalahanUnggah(pesan ?? 'Gagal mengunggah berkas. Coba lagi.');
      case KodeKesalahanBackend.validationError:
      case KodeKesalahanBackend.validationFailed:
      case KodeKesalahanBackend.badRequest:
        return KesalahanValidasi(
          pesan ?? 'Data tidak valid.',
          kesalahanRuas: amplop.kesalahanRuas,
        );
      case KodeKesalahanBackend.payloadTooLarge:
        return KesalahanValidasi(
          pesan ?? 'Ukuran berkas terlalu besar. Maksimal 5 MB per berkas.',
        );
      case KodeKesalahanBackend.unauthorized:
        return KesalahanTidakBerwenang(pesan ?? 'Sesi Anda telah berakhir.');
      case KodeKesalahanBackend.forbidden:
        return KesalahanDilarang(pesan ?? 'Akses ditolak.');
      case KodeKesalahanBackend.notFound:
        return KesalahanTidakDitemukan(pesan ?? 'Data tidak ditemukan.');
      case KodeKesalahanBackend.internalServerError:
      case KodeKesalahanBackend.serviceUnavailable:
        return KesalahanServer(pesan ?? 'Layanan sedang bermasalah.');
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
          kesalahanRuas: amplop.kesalahanRuas,
        );
      case 401:
        return KesalahanTidakBerwenang(pesan ?? 'Sesi Anda telah berakhir.');
      case 403:
        return KesalahanDilarang(pesan ?? 'Akses ditolak.');
      case 404:
        return KesalahanTidakDitemukan(pesan ?? 'Data tidak ditemukan.');
      case 409:
        return KesalahanKonflik(pesan ?? 'Data sudah terdaftar.');
      case 413:
        return KesalahanValidasi(
          pesan ?? 'Ukuran berkas terlalu besar. Maksimal 5 MB per berkas.',
        );
      case 422:
        return KesalahanValidasi(
          pesan ?? 'Data tidak lolos validasi.',
          kesalahanRuas: amplop.kesalahanRuas,
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
        kesalahanRuas: detailsMap is Map
            ? _uraikanRuas(detailsMap['errors'] ?? detailsMap['fields'] ?? detailsMap)
            : null,
      );
    }
    if (data['error_code'] is String || data['errors'] != null) {
      return _AmplopGalat(
        kode: data['error_code'] is String ? data['error_code'] as String : null,
        pesan: _pesanDari(data),
        kesalahanRuas: _uraikanRuas(data['errors']),
      );
    }
    return _AmplopGalat(
      pesan: data['message'] is String ? data['message'] as String : null,
    );
  }

  String? _pesanDari(Map<dynamic, dynamic> data) {
    final pesan = data['message'];
    if (pesan is String && pesan.isNotEmpty) return pesan;
    final errors = data['errors'];
    if (errors is List && errors.isNotEmpty) return errors.first.toString();
    if (errors is Map && errors.isNotEmpty) {
      final pertama = errors.values.first;
      if (pertama is List && pertama.isNotEmpty) return pertama.first.toString();
      if (pertama is String) return pertama;
    }
    return null;
  }

  Map<String, String>? _uraikanRuas(dynamic ruas) {
    if (ruas is List) {
      if (ruas.isEmpty) return null;
      final perRuas = <String, String>{};
      for (final item in ruas) {
        if (item is Map) {
          final field = (item['field'] ?? item['key'] ?? item['kunci'])?.toString();
          final pesan =
              (item['message'] ?? item['pesan'] ?? item['error'])?.toString();
          if (field != null && field.isNotEmpty && pesan != null && pesan.isNotEmpty) {
            perRuas[field] = pesan;
          }
        }
      }
      return perRuas.isNotEmpty ? perRuas : {'form': ruas.first.toString()};
    }
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
    this.kesalahanRuas,
  });

  final String? kode;
  final String? judul;
  final String? pesan;
  final Map<String, dynamic>? details;
  final Map<String, String>? kesalahanRuas;
}
