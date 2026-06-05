enum StatusBiometrik {
  belumDiperiksa,
  tidakDidukung,
  belumTerdaftar,
  ditolakPengguna,
  diverifikasi,
  gagal,
  dilewati,
}

extension StatusBiometrikLabel on StatusBiometrik {
  String get labelOperator {
    switch (this) {
      case StatusBiometrik.belumDiperiksa:
        return 'Belum diverifikasi';
      case StatusBiometrik.tidakDidukung:
        return 'Tidak didukung perangkat';
      case StatusBiometrik.belumTerdaftar:
        return 'Belum ada sidik jari terdaftar';
      case StatusBiometrik.ditolakPengguna:
        return 'Verifikasi dibatalkan pengguna';
      case StatusBiometrik.diverifikasi:
        return 'Berhasil diverifikasi';
      case StatusBiometrik.gagal:
        return 'Gagal diverifikasi';
      case StatusBiometrik.dilewati:
        return 'Dilewati pengguna';
    }
  }

  bool get sukses => this == StatusBiometrik.diverifikasi;
}

enum SumberBiometrik { perangkat, scannerEksternal }

class HasilBiometrikSidikJari {
  const HasilBiometrikSidikJari({
    required this.status,
    this.sumber = SumberBiometrik.perangkat,
    this.diverifikasiPada,
    this.tipeBiometrik,
    this.skorKualitas,
    this.posisiJari,
    this.alasan,
  });

  final StatusBiometrik status;
  final SumberBiometrik sumber;
  final DateTime? diverifikasiPada;
  final String? tipeBiometrik;
  final int? skorKualitas;
  final String? posisiJari;
  final String? alasan;

  HasilBiometrikSidikJari salin({
    StatusBiometrik? status,
    SumberBiometrik? sumber,
    DateTime? diverifikasiPada,
    String? tipeBiometrik,
    int? skorKualitas,
    String? posisiJari,
    String? alasan,
  }) {
    return HasilBiometrikSidikJari(
      status: status ?? this.status,
      sumber: sumber ?? this.sumber,
      diverifikasiPada: diverifikasiPada ?? this.diverifikasiPada,
      tipeBiometrik: tipeBiometrik ?? this.tipeBiometrik,
      skorKualitas: skorKualitas ?? this.skorKualitas,
      posisiJari: posisiJari ?? this.posisiJari,
      alasan: alasan ?? this.alasan,
    );
  }

  Map<String, Object?> toJsonPerangkat({
    required String idSesi,
    required Map<String, Object?> metadataPerangkat,
  }) {
    return {
      'registration_session_id': idSesi,
      'biometric_type': tipeBiometrik ?? 'fingerprint',
      'biometric_available': status != StatusBiometrik.tidakDidukung,
      'biometric_verified': status == StatusBiometrik.diverifikasi,
      'verified_at': diverifikasiPada?.toUtc().toIso8601String(),
      'source': 'device',
      'device_metadata': metadataPerangkat,
    };
  }

  Map<String, Object?> toJsonScannerEksternal({
    required String idSesi,
    required Map<String, Object?> metadataPerangkat,
    required String templateTerenkripsi,
  }) {
    return {
      'registration_session_id': idSesi,
      'scanner_type': 'external_fingerprint_scanner',
      'fingerprint_quality_score': skorKualitas,
      'finger_position': posisiJari ?? 'right_thumb',
      'encrypted_template': templateTerenkripsi,
      'captured_at': diverifikasiPada?.toUtc().toIso8601String(),
      'device_metadata': metadataPerangkat,
    };
  }
}
