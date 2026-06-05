import 'model_tantangan_liveness.dart';

class PermintaanAnalisisLiveness {
  const PermintaanAnalisisLiveness({
    required this.jalurVideo,
    required this.tantangan,
    required this.diambilPada,
  });

  final String jalurVideo;
  final List<TantanganLiveness> tantangan;
  final DateTime diambilPada;

  Map<String, dynamic> keMap() => {
        'video_path': jalurVideo,
        'taken_at': diambilPada.toIso8601String(),
        'challenges': tantangan
            .map((t) => {
                  'code': t.kode,
                  'instruction': t.instruksi,
                })
            .toList(),
      };
}

class HasilAnalisisLiveness {
  const HasilAnalisisLiveness({
    required this.lulus,
    required this.skor,
    this.detail,
    this.pesan,
  });

  final bool lulus;
  final double skor;
  final Map<String, dynamic>? detail;
  final String? pesan;
}

abstract class BridgeAnalisisLiveness {
  Future<HasilAnalisisLiveness> analisis(PermintaanAnalisisLiveness req);
}

class BridgeAnalisisLokal implements BridgeAnalisisLiveness {
  const BridgeAnalisisLokal();

  @override
  Future<HasilAnalisisLiveness> analisis(
    PermintaanAnalisisLiveness req,
  ) async {
    return const HasilAnalisisLiveness(
      lulus: true,
      skor: 1.0,
      pesan: 'Validasi tantangan dilakukan on-device.',
    );
  }
}

class BridgeAnalisisBackend implements BridgeAnalisisLiveness {
  const BridgeAnalisisBackend({required this.endpoint});

  final String endpoint;

  @override
  Future<HasilAnalisisLiveness> analisis(
    PermintaanAnalisisLiveness req,
  ) async {
    throw UnimplementedError(
      'BridgeAnalisisBackend belum diaktifkan. Wire ke endpoint $endpoint pada server Python.',
    );
  }
}
