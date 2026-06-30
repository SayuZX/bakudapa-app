import 'dart:async';

import 'model_status_maintenance.dart';
import 'repositori_status_sistem.dart';

class LayananStatusSistem {
  LayananStatusSistem._();
  static final LayananStatusSistem instance = LayananStatusSistem._();

  RepositoriStatusSistem _repo = const RepositoriStatusSistemApi();
  StatusMaintenance _terakhir = StatusMaintenance.tidakAktif;
  Future<StatusMaintenance>? _permintaanAktif;
  final StreamController<StatusMaintenance> _pengontrol =
      StreamController<StatusMaintenance>.broadcast();

  Stream<StatusMaintenance> get aliran => _pengontrol.stream;
  StatusMaintenance get terakhir => _terakhir;

  void pasangRepo(RepositoriStatusSistem repo) {
    _repo = repo;
  }

  Future<StatusMaintenance> cek({bool paksaUlang = false}) async {
    if (!paksaUlang) {
      final aktif = _permintaanAktif;
      if (aktif != null) return aktif;
      final diperiksa = _terakhir.diperiksaPada;
      if (diperiksa != null &&
          DateTime.now().difference(diperiksa) <
              AmbangMaintenance.cacheValid) {
        return _terakhir;
      }
    }
    final tugas = _ambilDariRepo();
    _permintaanAktif = tugas;
    try {
      return await tugas;
    } finally {
      _permintaanAktif = null;
    }
  }

  Future<StatusMaintenance> _ambilDariRepo() async {
    final hasil = await _repo.ambilStatus();
    _publis(hasil);
    return hasil;
  }

  void tandaiAktifDariResponseGalat({
    String? judul,
    String? pesan,
    DateTime? estimasiSelesai,
  }) {
    final hasil = StatusMaintenance(
      aktif: true,
      judul: judul,
      pesan: pesan,
      estimasiSelesai: estimasiSelesai ?? _terakhir.estimasiSelesai,
      diperiksaPada: DateTime.now(),
    );
    _publis(hasil);
  }

  void _publis(StatusMaintenance nilai) {
    _terakhir = nilai;
    if (!_pengontrol.isClosed) _pengontrol.add(nilai);
  }

  Future<void> buang() async {
    await _pengontrol.close();
  }
}
