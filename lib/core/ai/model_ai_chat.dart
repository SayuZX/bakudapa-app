enum TipeAksiAi {
  bukaLayanan,
  lihatStatus,
  lihatPermohonan,
  mulaiPengaduan,
  bukaFaq,
  hubungiOperator,
  takDikenal,
}

class AksiAi {
  const AksiAi({required this.tipe, required this.label, this.target});

  final TipeAksiAi tipe;
  final String label;
  final String? target;

  factory AksiAi.dariJson(Map<String, dynamic> json) {
    return AksiAi(
      tipe: _tipeDari(
          json['tipe']?.toString() ?? json['type']?.toString() ?? ''),
      label: json['label']?.toString() ?? '',
      target: json['target']?.toString(),
    );
  }

  static TipeAksiAi _tipeDari(String s) {
    switch (s) {
      case 'buka_layanan':
      case 'open_service':
        return TipeAksiAi.bukaLayanan;
      case 'lihat_status':
      case 'view_status':
        return TipeAksiAi.lihatStatus;
      case 'lihat_permohonan':
      case 'view_requests':
        return TipeAksiAi.lihatPermohonan;
      case 'mulai_pengaduan':
      case 'start_complaint':
        return TipeAksiAi.mulaiPengaduan;
      case 'buka_faq':
      case 'open_faq':
        return TipeAksiAi.bukaFaq;
      case 'hubungi_operator':
      case 'contact_operator':
        return TipeAksiAi.hubungiOperator;
      default:
        return TipeAksiAi.takDikenal;
    }
  }

  Map<String, dynamic> toJson() => {
        'tipe': tipe.name,
        'label': label,
        if (target != null) 'target': target,
      };
}

class HasilBalasanAi {
  const HasilBalasanAi({
    required this.sesiId,
    required this.balasan,
    required this.selesai,
    this.alasanSelesai,
    this.tokenOutput,
    this.latensiMs,
    this.aksi = const [],
    this.saran = const [],
    this.butuhOperator = false,
  });

  final String sesiId;
  final String balasan;
  final bool selesai;
  final String? alasanSelesai;
  final int? tokenOutput;
  final int? latensiMs;
  final List<AksiAi> aksi;
  final List<String> saran;
  final bool butuhOperator;

  factory HasilBalasanAi.dariJson(Map<String, dynamic> json) {
    final aksiRaw = json['aksi'] ?? json['actions'];
    final saranRaw = json['saran'] ?? json['suggestions'];
    return HasilBalasanAi(
      sesiId: json['sesi_id'] as String? ?? '',
      balasan: json['balasan'] as String? ?? '',
      selesai: json['selesai'] != false,
      alasanSelesai: json['done_reason'] as String?,
      tokenOutput: (json['token_output'] as num?)?.toInt(),
      latensiMs: (json['latensi_ms'] as num?)?.toInt(),
      aksi: aksiRaw is List
          ? aksiRaw
              .whereType<Map>()
              .map((e) => AksiAi.dariJson(Map<String, dynamic>.from(e)))
              .where((a) => a.label.isNotEmpty)
              .toList()
          : const [],
      saran: saranRaw is List
          ? saranRaw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList()
          : const [],
      butuhOperator: json['butuh_operator'] == true ||
          json['needs_human'] == true ||
          json['escalate'] == true,
    );
  }
}

enum PeranPesanAi { pengguna, asisten, sistem }

class PesanAi {
  PesanAi({
    required this.peran,
    required this.isi,
    required this.dibuatPada,
    this.selesai = true,
    this.terjadiGalat = false,
    this.pesanGalat,
    this.aksi = const [],
    this.butuhOperator = false,
  });

  final PeranPesanAi peran;
  final String isi;
  final DateTime dibuatPada;
  final bool selesai;
  final bool terjadiGalat;
  final String? pesanGalat;
  final List<AksiAi> aksi;
  final bool butuhOperator;

  Map<String, dynamic> toJson() => {
        'peran': peran.name,
        'isi': isi,
        'dibuat_pada': dibuatPada.toIso8601String(),
        'selesai': selesai,
        if (aksi.isNotEmpty) 'aksi': aksi.map((a) => a.toJson()).toList(),
        if (butuhOperator) 'butuh_operator': true,
      };

  factory PesanAi.dariJson(Map<String, dynamic> json) {
    final aksiRaw = json['aksi'];
    return PesanAi(
      peran: PeranPesanAi.values.firstWhere(
        (p) => p.name == json['peran'],
        orElse: () => PeranPesanAi.asisten,
      ),
      isi: json['isi']?.toString() ?? '',
      dibuatPada:
          DateTime.tryParse(json['dibuat_pada']?.toString() ?? '') ??
              DateTime.now(),
      selesai: json['selesai'] != false,
      aksi: aksiRaw is List
          ? aksiRaw
              .whereType<Map>()
              .map((e) => AksiAi.dariJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      butuhOperator: json['butuh_operator'] == true,
    );
  }
}
