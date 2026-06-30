class StatusMaintenance {
  const StatusMaintenance({
    required this.aktif,
    this.judul,
    this.pesan,
    this.estimasiSelesai,
    this.kontakDukungan,
    this.fiturDiizinkan = const [],
    this.diperiksaPada,
  });

  final bool aktif;
  final String? judul;
  final String? pesan;
  final DateTime? estimasiSelesai;
  final String? kontakDukungan;
  final List<String> fiturDiizinkan;
  final DateTime? diperiksaPada;

  bool fiturDiblokir(String kunciFitur) {
    if (!aktif) return false;
    if (fiturDiizinkan.isEmpty) return true;
    return !fiturDiizinkan.contains(kunciFitur);
  }

  static const tidakAktif = StatusMaintenance(aktif: false);

  factory StatusMaintenance.dariJson(Map<String, dynamic> json) {
    DateTime? parseTanggal(dynamic v) {
      if (v is String && v.isNotEmpty) {
        return DateTime.tryParse(v);
      }
      return null;
    }

    List<String> parseFitur(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return const [];
    }

    String? teks(List<String> kunci) {
      for (final k in kunci) {
        final v = json[k];
        if (v is String && v.isNotEmpty) return v;
      }
      return null;
    }

    return StatusMaintenance(
      aktif: json['maintenance'] == true ||
          json['sedang_maintenance'] == true ||
          json['is_maintenance'] == true,
      judul: teks(['title', 'judul']),
      pesan: teks(['message', 'pesan']),
      estimasiSelesai: parseTanggal(
        json['estimated_until'] ?? json['perkiraan_selesai'],
      ),
      kontakDukungan: teks(['support_contact', 'kontak_dukungan', 'kontak']),
      fiturDiizinkan: parseFitur(
        json['allowed_features'] ?? json['fitur_diizinkan'],
      ),
      diperiksaPada: DateTime.now(),
    );
  }
}

class AmbangMaintenance {
  const AmbangMaintenance._();
  static const Duration cacheValid = Duration(seconds: 60);
  static const Duration batasPermintaan = Duration(seconds: 6);
}
