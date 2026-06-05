import 'dart:io';

import '../../../shared/models/halaman_data.dart';
import '../../../shared/models/jenis_layanan.dart';
import '../../../shared/models/permohonan.dart';

class RingkasanStatus {
  const RingkasanStatus({
    required this.menunggu,
    required this.berjalan,
    required this.selesai,
  });
  final int menunggu;
  final int berjalan;
  final int selesai;
}

abstract class RepositoriPermohonan {
  Future<HalamanData<Permohonan>> mintaRiwayat({
    int halaman = 1,
    int ukuran = 15,
    String? kueriPencarian,
  });

  Future<Permohonan> mintaDetail(String id);

  Future<RingkasanStatus> mintaRingkasan();

  Future<Permohonan> ajukan({
    required JenisLayanan jenis,
    required Map<String, dynamic> data,
    required List<File> lampiran,
  });

  Future<String> unduhDokumenHasil(String idPermohonan);
}
