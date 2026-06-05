class HasilOcrKtp {
  const HasilOcrKtp({
    required this.adalahKtp,
    this.nik,
    this.nama,
    this.tanggalLahir,
    this.tempatLahir,
    this.jenisKelamin,
    this.alamat,
    this.agama,
    this.statusPerkawinan,
    this.pekerjaan,
    this.kewarganegaraan,
    required this.terbacaJelas,
    required this.wajahTerlihat,
    required this.adaTandaTampering,
    this.catatan,
  });

  final bool adalahKtp;
  final String? nik;
  final String? nama;
  final String? tanggalLahir;
  final String? tempatLahir;
  final String? jenisKelamin;
  final String? alamat;
  final String? agama;
  final String? statusPerkawinan;
  final String? pekerjaan;
  final String? kewarganegaraan;
  final bool terbacaJelas;
  final bool wajahTerlihat;
  final bool adaTandaTampering;
  final String? catatan;

  factory HasilOcrKtp.dariJson(dynamic json) {
    if (json is! Map) {
      return const HasilOcrKtp(
        adalahKtp: false,
        terbacaJelas: false,
        wajahTerlihat: false,
        adaTandaTampering: false,
      );
    }
    final kualitas = json['kualitas'];
    return HasilOcrKtp(
      adalahKtp: json['adalah_ktp'] == true,
      nik: json['nik'] as String?,
      nama: json['nama'] as String?,
      tanggalLahir: json['tanggal_lahir'] as String?,
      tempatLahir: json['tempat_lahir'] as String?,
      jenisKelamin: json['jenis_kelamin'] as String?,
      alamat: json['alamat'] as String?,
      agama: json['agama'] as String?,
      statusPerkawinan: json['status_perkawinan'] as String?,
      pekerjaan: json['pekerjaan'] as String?,
      kewarganegaraan: json['kewarganegaraan'] as String?,
      terbacaJelas:
          kualitas is Map ? kualitas['terbaca_jelas'] == true : false,
      wajahTerlihat:
          kualitas is Map ? kualitas['wajah_terlihat'] == true : false,
      adaTandaTampering:
          kualitas is Map ? kualitas['ada_tanda_tampering'] == true : false,
      catatan: kualitas is Map ? kualitas['catatan'] as String? : null,
    );
  }
}

class HasilCocokWajah {
  const HasilCocokWajah({
    required this.jarak,
    required this.ambang,
    required this.wajahRujukanTerdeteksi,
    required this.wajahKandidatTerdeteksi,
    required this.durasiMs,
  });

  final double jarak;
  final double ambang;
  final bool wajahRujukanTerdeteksi;
  final bool wajahKandidatTerdeteksi;
  final int durasiMs;

  double get skor => (1 - jarak).clamp(0.0, 1.0);

  factory HasilCocokWajah.dariJson(dynamic json) {
    if (json is! Map) {
      return const HasilCocokWajah(
        jarak: 1.0,
        ambang: 0.6,
        wajahRujukanTerdeteksi: false,
        wajahKandidatTerdeteksi: false,
        durasiMs: 0,
      );
    }
    return HasilCocokWajah(
      jarak: (json['distance'] as num?)?.toDouble() ?? 1.0,
      ambang: (json['threshold'] as num?)?.toDouble() ?? 0.6,
      wajahRujukanTerdeteksi: json['reference_face_detected'] == true,
      wajahKandidatTerdeteksi: json['candidate_face_detected'] == true,
      durasiMs: (json['duration_ms'] as num?)?.toInt() ?? 0,
    );
  }
}

class HasilHeuristikWajah {
  const HasilHeuristikWajah({
    this.kemungkinanSama,
    this.skorKemiripan,
    this.alasan = '',
    this.ciriDipakai = const [],
    this.catatanKualitas = '',
  });

  final bool? kemungkinanSama;
  final double? skorKemiripan;
  final String alasan;
  final List<String> ciriDipakai;
  final String catatanKualitas;

  factory HasilHeuristikWajah.dariJson(dynamic json) {
    if (json is! Map) return const HasilHeuristikWajah();
    final ciri = json['ciri_dipakai'];
    return HasilHeuristikWajah(
      kemungkinanSama: json['kemungkinan_sama'] as bool?,
      skorKemiripan: (json['skor_kemiripan'] as num?)?.toDouble(),
      alasan: json['alasan'] as String? ?? '',
      ciriDipakai: ciri is List ? List<String>.from(ciri) : const [],
      catatanKualitas: json['catatan_kualitas'] as String? ?? '',
    );
  }
}

enum KeputusanVerifikasiWajah {
  terverifikasi,
  ditolak,
  perluReviewManusia,
  tidakDikenal;

  static KeputusanVerifikasiWajah dariString(String? nilai) {
    switch (nilai) {
      case 'terverifikasi':
        return KeputusanVerifikasiWajah.terverifikasi;
      case 'ditolak':
        return KeputusanVerifikasiWajah.ditolak;
      case 'perlu_review_manusia':
        return KeputusanVerifikasiWajah.perluReviewManusia;
      default:
        return KeputusanVerifikasiWajah.tidakDikenal;
    }
  }
}

class HasilVerifikasiWajahAi {
  const HasilVerifikasiWajahAi({
    required this.id,
    required this.keputusan,
    required this.skorConfidence,
    required this.alasan,
    required this.catatan,
    required this.statusReview,
    required this.ocr,
    required this.cocokWajah,
    required this.heuristik,
    required this.latensiMs,
    required this.dibuatPada,
  });

  final String id;
  final KeputusanVerifikasiWajah keputusan;
  final double skorConfidence;
  final String alasan;
  final String catatan;
  final String statusReview;
  final HasilOcrKtp ocr;
  final HasilCocokWajah cocokWajah;
  final HasilHeuristikWajah heuristik;
  final int latensiMs;
  final DateTime? dibuatPada;

  factory HasilVerifikasiWajahAi.dariJson(Map<String, dynamic> json) {
    final output = json['output'];
    Map<String, dynamic> ambil(String kunci) {
      if (output is Map && output[kunci] is Map) {
        return Map<String, dynamic>.from(output[kunci] as Map);
      }
      return const {};
    }

    return HasilVerifikasiWajahAi(
      id: json['id'] as String? ?? '',
      keputusan: KeputusanVerifikasiWajah.dariString(
        json['keputusan'] as String?,
      ),
      skorConfidence: (json['skor_confidence'] as num?)?.toDouble() ?? 0,
      alasan: json['alasan'] as String? ?? '',
      catatan: json['catatan'] as String? ?? '',
      statusReview:
          json['status_review'] as String? ?? 'tidak_butuh_review',
      ocr: HasilOcrKtp.dariJson(ambil('ocr')),
      cocokWajah: HasilCocokWajah.dariJson(ambil('face_match')),
      heuristik: HasilHeuristikWajah.dariJson(ambil('heuristik')),
      latensiMs: (json['latensi_ms'] as num?)?.toInt() ?? 0,
      dibuatPada: json['dibuat_pada'] is String
          ? DateTime.tryParse(json['dibuat_pada'] as String)
          : null,
    );
  }
}
