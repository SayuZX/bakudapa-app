import 'package:bakudapa_mobile/core/enums/jenis_kelamin.dart';

import '../../../../core/biometric/model_hasil_biometrik.dart';
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
  });

  final String nomorIdentitas;
  final String namaLengkap;
  final DateTime? tanggalLahir;
  final String tempatLahir;
  final JenisKelamin? jenisKelamin;
  final String noHp;
  final String surel;

  IdentitasRegistrasi salin({
    String? nomorIdentitas,
    String? namaLengkap,
    DateTime? tanggalLahir,
    String? tempatLahir,
    JenisKelamin? jenisKelamin,
    String? noHp,
    String? surel,
  }) {
    return IdentitasRegistrasi(
      nomorIdentitas: nomorIdentitas ?? this.nomorIdentitas,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      tempatLahir: tempatLahir ?? this.tempatLahir,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      noHp: noHp ?? this.noHp,
      surel: surel ?? this.surel,
    );
  }

  Map<String, Object?> toJson() => {
        'user_type': 'WNI',
        'identity_number': nomorIdentitas,
        'full_name': namaLengkap,
        'birth_date': tanggalLahir?.toIso8601String(),
        'birth_place': tempatLahir,
        'gender': jenisKelamin?.value,
        'phone_number': noHp,
        'email': surel,
      };
}

class PersetujuanKebijakan {
  const PersetujuanKebijakan({
    this.privasi = false,
    this.layanan = false,
    this.penafian = false,
    this.biometrik = false,
    this.kebenaranData = false,
  });

  final bool privasi;
  final bool layanan;
  final bool penafian;
  final bool biometrik;
  final bool kebenaranData;

  bool get semua => privasi && layanan && penafian && biometrik && kebenaranData;

  PersetujuanKebijakan salin({
    bool? privasi,
    bool? layanan,
    bool? penafian,
    bool? biometrik,
    bool? kebenaranData,
  }) {
    return PersetujuanKebijakan(
      privasi: privasi ?? this.privasi,
      layanan: layanan ?? this.layanan,
      penafian: penafian ?? this.penafian,
      biometrik: biometrik ?? this.biometrik,
      kebenaranData: kebenaranData ?? this.kebenaranData,
    );
  }

  Map<String, bool> toJson() => {
        'privacy': privasi,
        'service': layanan,
        'disclaimer': penafian,
        'biometric': biometrik,
        'data_truth': kebenaranData,
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
    this.kalimatSuara,
    this.kodeSuara,
    this.jalurAudioSuara,
    this.hasilSidikJari,
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
  final String? kalimatSuara;
  final String? kodeSuara;
  final String? jalurAudioSuara;
  final HasilBiometrikSidikJari? hasilSidikJari;
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
    String? kalimatSuara,
    String? kodeSuara,
    String? jalurAudioSuara,
    HasilBiometrikSidikJari? hasilSidikJari,
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
      kalimatSuara: kalimatSuara ?? this.kalimatSuara,
      kodeSuara: kodeSuara ?? this.kodeSuara,
      jalurAudioSuara: jalurAudioSuara ?? this.jalurAudioSuara,
      hasilSidikJari: hasilSidikJari ?? this.hasilSidikJari,
      persetujuan: persetujuan ?? this.persetujuan,
      mulaiPada: mulaiPada ?? this.mulaiPada,
    );
  }
}
