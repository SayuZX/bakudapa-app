class Pengguna {
  const Pengguna({
    required this.id,
    required this.nik,
    required this.namaLengkap,
    this.surel,
    this.noHp,
    this.alamat,
    this.kabupatenKota,
    this.kecamatan,
    this.urlFoto,
    this.terverifikasi = false,
  });

  final String id;
  final String nik;
  final String namaLengkap;
  final String? surel;
  final String? noHp;
  final String? alamat;
  final String? kabupatenKota;
  final String? kecamatan;
  final String? urlFoto;
  final bool terverifikasi;

  factory Pengguna.dariJson(Map<String, dynamic> json) {
    return Pengguna(
      id: json['id']?.toString() ?? '',
      nik: json['nik']?.toString() ?? '',
      namaLengkap: json['nama_lengkap']?.toString() ?? json['name']?.toString() ?? '',
      surel: json['email']?.toString(),
      noHp: json['no_hp']?.toString() ?? json['phone']?.toString(),
      alamat: json['alamat']?.toString(),
      kabupatenKota: json['kab_kota']?.toString(),
      kecamatan: json['kecamatan']?.toString(),
      urlFoto: json['url_foto']?.toString() ?? json['avatar']?.toString(),
      terverifikasi: json['terverifikasi'] == true || json['verified'] == true,
    );
  }

  Map<String, dynamic> keJson() => {
        'id': id,
        'nik': nik,
        'nama_lengkap': namaLengkap,
        'email': surel,
        'no_hp': noHp,
        'alamat': alamat,
        'kab_kota': kabupatenKota,
        'kecamatan': kecamatan,
        'url_foto': urlFoto,
        'terverifikasi': terverifikasi,
      };

  Pengguna salin({
    String? namaLengkap,
    String? surel,
    String? noHp,
    String? alamat,
    String? kabupatenKota,
    String? kecamatan,
    String? urlFoto,
    bool? terverifikasi,
  }) {
    return Pengguna(
      id: id,
      nik: nik,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      surel: surel ?? this.surel,
      noHp: noHp ?? this.noHp,
      alamat: alamat ?? this.alamat,
      kabupatenKota: kabupatenKota ?? this.kabupatenKota,
      kecamatan: kecamatan ?? this.kecamatan,
      urlFoto: urlFoto ?? this.urlFoto,
      terverifikasi: terverifikasi ?? this.terverifikasi,
    );
  }
}
