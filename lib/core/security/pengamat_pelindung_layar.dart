import 'package:flutter/widgets.dart';

import '../router/nama_rute.dart';
import 'layanan_pelindung_layar.dart';

class PengamatPelindungLayar extends NavigatorObserver {
  static const Set<String> _ruteSensitif = {
    NamaRute.masuk,
    NamaRute.otp,
    NamaRute.lupaKataSandi,
    NamaRute.resetKataSandiBaru,
    NamaRute.buatKredensial,
    NamaRute.gantiKataSandi,
    NamaRute.daftar,
    NamaRute.daftarFotoDokumen,
    NamaRute.daftarFotoWajah,
    NamaRute.daftarKameraFotoWajah,
    NamaRute.daftarLiveness,
    NamaRute.daftarKameraLiveness,
    NamaRute.kelolaPerangkat,
    NamaRute.pengaturanPerangkatAktif,
  };

  int _jumlahSensitif = 0;

  bool _sensitif(Route<dynamic>? route) {
    final nama = route?.settings.name;
    return nama != null && _ruteSensitif.contains(nama);
  }

  void _segarkan() {
    if (_jumlahSensitif > 0) {
      LayananPelindungLayar.instance.aktifkan();
    } else {
      LayananPelindungLayar.instance.nonaktifkan();
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_sensitif(route)) {
      _jumlahSensitif++;
      _segarkan();
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_sensitif(route)) {
      _jumlahSensitif = (_jumlahSensitif - 1).clamp(0, 1 << 30);
      _segarkan();
    }
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_sensitif(route)) {
      _jumlahSensitif = (_jumlahSensitif - 1).clamp(0, 1 << 30);
      _segarkan();
    }
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (_sensitif(oldRoute)) {
      _jumlahSensitif = (_jumlahSensitif - 1).clamp(0, 1 << 30);
    }
    if (_sensitif(newRoute)) {
      _jumlahSensitif++;
    }
    _segarkan();
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
