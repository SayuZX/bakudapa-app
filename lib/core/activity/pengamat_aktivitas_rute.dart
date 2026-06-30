import 'dart:async';

import 'package:flutter/widgets.dart';

import 'jenis_aktivitas.dart';
import 'layanan_pencatat_aktivitas.dart';

class PengamatAktivitasRute extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _catat(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _catat(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  void _catat(Route<dynamic>? route) {
    final nama = route?.settings.name;
    if (nama == null || nama.isEmpty) return;

    unawaited(
      LayananPencatatAktivitas.instance.catat(
        JenisAktivitas.bukaLayar,
        layar: nama,
      ),
    );
  }
}
