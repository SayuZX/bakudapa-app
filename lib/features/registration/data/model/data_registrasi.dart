import 'package:bakudapa_mobile/core/enums/jenis_kelamin.dart';

import '../../../../core/liveness/model_tantangan_liveness.dart';

export 'package:bakudapa_mobile/core/enums/jenis_kelamin.dart';

class IdentitasRegistrasi {
  const IdentitasRegistrasi({
    this.nomorIdentitas = '',
    this.namaLengkap = '',
    this.tanggalLahir,
    this.tempatLahir = '',
    this.jenisKelamin,
    this.noHp = '',
    this.surel = '',
    this.kabupatenKode = '',
    this.kabupatenNama = '',
    this.kecamatanKode = '',
    this.kecamatanNama = '',
    this.desaKode = '',
    this.desaNama = '',
  });

  final String nomorIdentitas;
  final String namaLengkap;
  final DateTime? tanggalLahir;
  final String tempatLahir;
  final JenisKelamin? jenisKelamin;
  final String noHp;
  final String surel;
  final String kabupatenKode;
  final String kabupatenNama;
  final String kecamatanKode;
  final String kecamatanNama;
  final String desaKode;
  final String desaNama;

  IdentitasRegistrasi salin({
    String? nomorIdentitas,
    String? namaLengkap,
    DateTime? tanggalLahir,
    String? tempatLahir,
    JenisKelamin? jenisKelamin,
    String? noHp,
    String? surel,
    String? kabupatenKode,
    String? kabupatenNama,
    String? kecamatanKode,
    String? kecamatanNama,
    String? desaKode,
    String? desaNama,
  }) {
    return IdentitasRegistrasi(
      nomorIdentitas: nomorIdentitas ?? this.nomorIdentitas,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      tempatLahir: tempatLahir ?? this.tempatLahir,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      noHp: noHp ?? this.noHp,
      surel: surel ?? this.surel,
      kabupatenKode: kabupatenKode ?? this.kabupatenKode,
      kabupatenNama: kabupatenNama ?? this.kabupatenNama,
      kecamatanKode: kecamatanKode ?? this.kecamatanKode,
      kecamatanNama: kecamatanNama ?? this.kecamatanNama,
      desaKode: desaKode ?? this.desaKode,
      desaNama: desaNama ?? this.desaNama,
    );
  }

  Map<String, Object?> toJson() => {
        'nik': nomorIdentitas,
        'nama_lengkap': namaLengkap,
        'tanggal_lahir':
            tanggalLahir == null ? null : _tanggal(tanggalLahir!),
        'tempat_lahir': tempatLahir,
        'jenis_kelamin': jenisKelamin?.value,
        'no_hp': noHp,
        'email': surel,
        'kabupaten_kode': kabupatenKode,
        'kecamatan_kode': kecamatanKode,
        'desa_kode': desaKode,
      };

  static String _tanggal(DateTime t) {
    final bln = t.month.toString().padLeft(2, '0');
    final hari = t.day.toString().padLeft(2, '0');
    return '${t.year}-$bln-$hari';
  }
}

class PersetujuanKebijakan {
  const PersetujuanKebijakan({
    this.privasi = false,
    this.layanan = false,
    this.penafian = false,
    this.biometrik = false,
    this.kebenaranData = false,
    this.versi = const {},
  });

  final bool privasi;
  final bool layanan;
  final bool penafian;
  final bool biometrik;
  final bool kebenaranData;
  final Map<String, String> versi;

  bool get semua => privasi && layanan && penafian && biometrik && kebenaranData;

  PersetujuanKebijakan salin({
    bool? privasi,
    bool? layanan,
    bool? penafian,
    bool? biometrik,
    bool? kebenaranData,
    Map<String, String>? versi,
  }) {
    return PersetujuanKebijakan(
      privasi: privasi ?? this.privasi,
      layanan: layanan ?? this.layanan,
      penafian: penafian ?? this.penafian,
      biometrik: biometrik ?? this.biometrik,
      kebenaranData: kebenaranData ?? this.kebenaranData,
      versi: versi ?? this.versi,
    );
  }

  Map<String, bool> toJson() => {
        'privasi': privasi,
        'layanan': layanan,
        'penafian': penafian,
        'biometrik': biometrik,
        'kebenaran_data': kebenaranData,
      };
}

class TangkapTantangan {
  const TangkapTantangan({
    required this.kodeTantangan,
    required this.jalurFoto,
    required this.dimulaiMs,
    required this.selesaiMs,
    required this.namaFilter,
  });

  final String kodeTantangan;
  final String jalurFoto;
  final int dimulaiMs;
  final int selesaiMs;
  final String namaFilter;

  Map<String, Object?> toJson() => {
        'kode_tantangan': kodeTantangan,
        'mulai_ms': dimulaiMs,
        'selesai_ms': selesaiMs,
        'filter': namaFilter,
      };
}

class SesiRegistrasi {
  const SesiRegistrasi({
    this.token,
    this.identitas = const IdentitasRegistrasi(),
    this.jalurFotoDokumen,
    this.jalurFotoWajah,
    this.jalurVideoLiveness,
    this.tantanganLiveness = const [],
    this.tangkapanTantangan = const [],
    this.kodeTantanganLivenessServer,
    this.persetujuan = const PersetujuanKebijakan(),
    this.mulaiPada,
  });

  final String? token;
  final IdentitasRegistrasi identitas;
  final String? jalurFotoDokumen;
  final String? jalurFotoWajah;
  final String? jalurVideoLiveness;
  final List<TantanganLiveness> tantanganLiveness;
  final List<TangkapTantangan> tangkapanTantangan;
  final String? kodeTantanganLivenessServer;
  final PersetujuanKebijakan persetujuan;
  final DateTime? mulaiPada;

  bool get punyaIdentitas =>
      identitas.nomorIdentitas.isNotEmpty &&
      identitas.namaLengkap.isNotEmpty;

  SesiRegistrasi salin({
    String? token,
    IdentitasRegistrasi? identitas,
    String? jalurFotoDokumen,
    String? jalurFotoWajah,
    String? jalurVideoLiveness,
    List<TantanganLiveness>? tantanganLiveness,
    List<TangkapTantangan>? tangkapanTantangan,
    String? kodeTantanganLivenessServer,
    PersetujuanKebijakan? persetujuan,
    DateTime? mulaiPada,
  }) {
    return SesiRegistrasi(
      token: token ?? this.token,
      identitas: identitas ?? this.identitas,
      jalurFotoDokumen: jalurFotoDokumen ?? this.jalurFotoDokumen,
      jalurFotoWajah: jalurFotoWajah ?? this.jalurFotoWajah,
      jalurVideoLiveness: jalurVideoLiveness ?? this.jalurVideoLiveness,
      tantanganLiveness: tantanganLiveness ?? this.tantanganLiveness,
      tangkapanTantangan: tangkapanTantangan ?? this.tangkapanTantangan,
      kodeTantanganLivenessServer:
          kodeTantanganLivenessServer ?? this.kodeTantanganLivenessServer,
      persetujuan: persetujuan ?? this.persetujuan,
      mulaiPada: mulaiPada ?? this.mulaiPada,
    );
  }
}
