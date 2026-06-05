import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../config/endpoints.dart';
import 'klien_jaringan.dart';
import 'model_kualitas_jaringan.dart';

class LayananKualitasJaringan {
  LayananKualitasJaringan._();
  static final LayananKualitasJaringan instance = LayananKualitasJaringan._();

  final Connectivity _konektivitas = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _langganKonektivitas;
  final StreamController<HasilKualitasJaringan> _pengontrol =
      StreamController<HasilKualitasJaringan>.broadcast();

  HasilKualitasJaringan _terakhir = HasilKualitasJaringan.awal;
  Future<HasilKualitasJaringan>? _pemeriksaanAktif;
  int _hitunganGagalBerturut = 0;
  DateTime? _terakhirSukses;

  Stream<HasilKualitasJaringan> get aliran => _pengontrol.stream;
  HasilKualitasJaringan get terakhir => _terakhir;

  void mulai() {
    if (_langganKonektivitas != null) return;
    _langganKonektivitas =
        _konektivitas.onConnectivityChanged.listen((hasil) {
      final adaInternet = hasil.any(
        (r) =>
            r == ConnectivityResult.wifi ||
            r == ConnectivityResult.mobile ||
            r == ConnectivityResult.ethernet ||
            r == ConnectivityResult.vpn,
      );
      if (!adaInternet) {
        _publis(_terakhir.salin(
          status: StatusKualitasJaringan.offline,
          diperiksaPada: DateTime.now(),
        ));
      } else if (_terakhir.aktifOffline) {
        unawaited(cek(paksaUlang: true));
      }
    });
  }

  Future<void> hentikan() async {
    await _langganKonektivitas?.cancel();
    _langganKonektivitas = null;
  }

  Future<HasilKualitasJaringan> cek({bool paksaUlang = false}) async {
    if (!paksaUlang) {
      final aktif = _pemeriksaanAktif;
      if (aktif != null) return aktif;
      final sukses = _terakhirSukses;
      if (sukses != null &&
          _terakhir.aktifBaik &&
          DateTime.now().difference(sukses) <
              AmbangJaringan.intervalCekUlang) {
        return _terakhir;
      }
    }
    _publis(_terakhir.salin(status: StatusKualitasJaringan.memeriksa));
    final tugas = _jalankanCek();
    _pemeriksaanAktif = tugas;
    try {
      final hasil = await tugas;
      return hasil;
    } finally {
      _pemeriksaanAktif = null;
    }
  }

  Future<HasilKualitasJaringan> _jalankanCek() async {
    final konektivitas = await _konektivitas.checkConnectivity();
    final adaInternet = konektivitas.any(
      (r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn,
    );
    if (!adaInternet) {
      _hitunganGagalBerturut++;
      final hasil = HasilKualitasJaringan(
        status: StatusKualitasJaringan.offline,
        diperiksaPada: DateTime.now(),
      );
      _publis(hasil);
      return hasil;
    }

    final mulai = DateTime.now();
    try {
      await KlienJaringan.instance.dio.get(
        Endpoints.sistemPing,
        options: Options(
          sendTimeout: AmbangJaringan.batasPing,
          receiveTimeout: AmbangJaringan.batasPing,
          validateStatus: (s) => s != null,
          extra: const {'anonim': true},
        ),
      );
      final latensi = DateTime.now().difference(mulai).inMilliseconds;
      final status = _statusDariLatensi(latensi);
      final hasil = HasilKualitasJaringan(
        status: status,
        latensiMili: latensi,
        diperiksaPada: DateTime.now(),
      );
      _hitunganGagalBerturut = 0;
      _terakhirSukses = DateTime.now();
      _publis(hasil);
      return hasil;
    } on DioException catch (e) {
      final responseStatus = e.response?.statusCode;
      if (responseStatus != null) {
        final latensi = DateTime.now().difference(mulai).inMilliseconds;
        final status = _statusDariLatensi(latensi);
        final hasil = HasilKualitasJaringan(
          status: status,
          latensiMili: latensi,
          diperiksaPada: DateTime.now(),
        );
        _hitunganGagalBerturut = 0;
        _terakhirSukses = DateTime.now();
        _publis(hasil);
        return hasil;
      }
      _hitunganGagalBerturut++;
      final status = _statusDariGalat(e);
      final hasil = HasilKualitasJaringan(
        status: status,
        diperiksaPada: DateTime.now(),
        pesanGalat: e.message,
      );
      _publis(hasil);
      return hasil;
    } catch (e) {
      _hitunganGagalBerturut++;
      final hasil = HasilKualitasJaringan(
        status: StatusKualitasJaringan.sedang,
        diperiksaPada: DateTime.now(),
        pesanGalat: e.toString(),
      );
      _publis(hasil);
      return hasil;
    }
  }

  StatusKualitasJaringan _statusDariLatensi(int latensiMili) {
    if (latensiMili <= AmbangJaringan.latensiStabilMaks) {
      return StatusKualitasJaringan.stabil;
    }
    if (latensiMili <= AmbangJaringan.latensiSedangMaks) {
      return StatusKualitasJaringan.sedang;
    }
    return StatusKualitasJaringan.tidakStabil;
  }

  StatusKualitasJaringan _statusDariGalat(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return StatusKualitasJaringan.batasWaktu;
      case DioExceptionType.connectionError:
        return StatusKualitasJaringan.serverTakTerjangkau;
      default:
        if (_hitunganGagalBerturut >=
            AmbangJaringan.maksGagalSebelumTakTerjangkau) {
          return StatusKualitasJaringan.serverTakTerjangkau;
        }
        return StatusKualitasJaringan.tidakStabil;
    }
  }

  void _publis(HasilKualitasJaringan nilai) {
    _terakhir = nilai;
    if (!_pengontrol.isClosed) _pengontrol.add(nilai);
  }

  Future<void> buang() async {
    await hentikan();
    await _pengontrol.close();
  }
}
