enum StatusKualitasJaringan {
  belumDicek,
  memeriksa,
  stabil,
  sedang,
  tidakStabil,
  offline,
  batasWaktu,
  serverTakTerjangkau,
}

class HasilKualitasJaringan {
  const HasilKualitasJaringan({
    required this.status,
    this.latensiMili,
    this.diperiksaPada,
    this.pesanGalat,
  });

  final StatusKualitasJaringan status;
  final int? latensiMili;
  final DateTime? diperiksaPada;
  final String? pesanGalat;

  bool get aktifBaik =>
      status == StatusKualitasJaringan.stabil ||
      status == StatusKualitasJaringan.sedang;

  bool get aktifBuruk =>
      status == StatusKualitasJaringan.tidakStabil ||
      status == StatusKualitasJaringan.batasWaktu ||
      status == StatusKualitasJaringan.serverTakTerjangkau;

  bool get aktifOffline => status == StatusKualitasJaringan.offline;

  bool get bolehUploadBesar => status == StatusKualitasJaringan.stabil;

  static const awal = HasilKualitasJaringan(
    status: StatusKualitasJaringan.belumDicek,
  );

  HasilKualitasJaringan salin({
    StatusKualitasJaringan? status,
    int? latensiMili,
    DateTime? diperiksaPada,
    String? pesanGalat,
  }) {
    return HasilKualitasJaringan(
      status: status ?? this.status,
      latensiMili: latensiMili ?? this.latensiMili,
      diperiksaPada: diperiksaPada ?? this.diperiksaPada,
      pesanGalat: pesanGalat ?? this.pesanGalat,
    );
  }
}

class AmbangJaringan {
  const AmbangJaringan._();
  static const int latensiStabilMaks = 800;
  static const int latensiSedangMaks = 1500;
  static const Duration batasPing = Duration(seconds: 4);
  static const Duration intervalCekUlang = Duration(seconds: 30);
  static const int maksGagalSebelumTakTerjangkau = 2;
}
