import '../../../shared/models/perangkat_aktif.dart';

abstract class RepositoriPerangkat {
  Future<List<PerangkatAktif>> mintaDaftar();

  Future<List<PerangkatAktif>> mintaRiwayat();

  Future<void> cabut(String sesiId);
}
