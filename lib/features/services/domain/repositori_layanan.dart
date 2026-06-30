import '../../../shared/models/jenis_layanan.dart';
import 'detail_layanan.dart';

abstract class RepositoriLayanan {
  Future<List<RingkasanLayanan>> mintaDaftar({String? cari, String? kategori});

  Future<DetailLayanan> mintaDetail(String kodeLayanan);
}
