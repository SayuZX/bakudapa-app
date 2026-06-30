enum StatusPerangkat {
  aktif,
  dicabut,
  kedaluwarsa,
  takDikenal;

  static StatusPerangkat dari(String? nilai) {
    switch (nilai?.toLowerCase()) {
      case 'aktif':
      case 'active':
        return StatusPerangkat.aktif;
      case 'dicabut':
      case 'revoked':
        return StatusPerangkat.dicabut;
      case 'kedaluwarsa':
      case 'expired':
        return StatusPerangkat.kedaluwarsa;
      default:
        return StatusPerangkat.takDikenal;
    }
  }
}

class PerangkatAktif {
  const PerangkatAktif({
    required this.sesiId,
    required this.perangkat,
    required this.os,
    this.label = '',
    this.appVersion,
    this.masukPada,
    this.terakhirAktif,
    this.status = StatusPerangkat.aktif,
    this.iniPerangkatSaatIni = false,
  });

  final String sesiId;
  final String perangkat;
  final String os;
  final String label;
  final String? appVersion;
  final DateTime? masukPada;
  final DateTime? terakhirAktif;
  final StatusPerangkat status;
  final bool iniPerangkatSaatIni;

  String get namaTampil {
    if (label.isNotEmpty) return label;
    if (perangkat.isNotEmpty) {
      return os.isNotEmpty ? '$perangkat · $os' : perangkat;
    }
    return os.isNotEmpty ? os : '';
  }

  factory PerangkatAktif.dariJson(Map<String, dynamic> json) {
    DateTime? tanggal(List<String> kunci) {
      for (final k in kunci) {
        final v = json[k]?.toString();
        if (v != null && v.isNotEmpty) {
          final t = DateTime.tryParse(v);
          if (t != null) return t;
        }
      }
      return null;
    }

    return PerangkatAktif(
      sesiId:
          json['id_sesi']?.toString() ??
          json['sesi_id']?.toString() ??
          json['session_id']?.toString() ??
          json['id']?.toString() ??
          '',
      perangkat:
          json['model']?.toString() ??
          json['perangkat']?.toString() ??
          json['device']?.toString() ??
          json['device_model']?.toString() ??
          '',
      os:
          json['os']?.toString() ??
          json['device_os']?.toString() ??
          json['sistem_operasi']?.toString() ??
          '',
      label: json['label']?.toString() ?? '',
      appVersion:
          json['app_version']?.toString() ?? json['versi_aplikasi']?.toString(),
      masukPada: tanggal(['masuk_pada', 'login_at', 'masuk']),
      terakhirAktif: tanggal([
        'terakhir_aktif',
        'terakhir_aktif_pada',
        'last_active_at',
      ]),
      status: StatusPerangkat.dari(json['status']?.toString()),
      iniPerangkatSaatIni:
          json['ini_perangkat_ini'] == true ||
          json['perangkat_saat_ini'] == true ||
          json['current_device'] == true ||
          json['is_current'] == true,
    );
  }
}

class KelolaPerangkat {
  const KelolaPerangkat({
    required this.diperlukan,
    required this.perangkatAktif,
    this.batas,
  });

  final bool diperlukan;
  final List<PerangkatAktif> perangkatAktif;
  final int? batas;

  factory KelolaPerangkat.dariJson(Map<String, dynamic> json) {
    final daftar = json['perangkat_aktif'] ?? json['active_devices'];
    final batas = json['batas'] ?? json['limit'];
    return KelolaPerangkat(
      diperlukan: json['diperlukan'] == true || json['required'] == true,
      batas: batas is int ? batas : int.tryParse(batas?.toString() ?? ''),
      perangkatAktif: daftar is List
          ? daftar
                .whereType<Map>()
                .map((e) => PerangkatAktif.dariJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
    );
  }
}
