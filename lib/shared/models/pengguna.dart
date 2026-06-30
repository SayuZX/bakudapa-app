class Pengguna {
  const Pengguna({
    required this.id,
    required this.nik,
    required this.namaLengkap,
    this.namaPengguna,
    this.username,
    this.surel,
    this.noHp,
    this.alamat,
    this.tempatLahir,
    this.tanggalLahir,
    this.jenisKelamin,
    this.bahasaPilihan,
    this.statusVerifikasi,
    this.nomorRegistrasi,
    this.terakhirLoginPada,
    this.kabupatenKota,
    this.kecamatan,
    this.desaKelurahan,
    this.kabupatenKode,
    this.kecamatanKode,
    this.desaKode,
    this.urlFoto,
    this.tipePengguna,
    this.terverifikasi = false,
    this.setujuKetentuan = false,
    this.wajibGantiKataSandi = false,
  });

  final String id;
  final String nik;
  final String namaLengkap;
  final String? namaPengguna;
  final String? username;
  final String? surel;
  final String? noHp;
  final String? alamat;
  final String? tempatLahir;
  final String? tanggalLahir;
  final String? jenisKelamin;
  final String? bahasaPilihan;
  final String? statusVerifikasi;
  final String? nomorRegistrasi;
  final String? terakhirLoginPada;
  final String? kabupatenKota;
  final String? kecamatan;
  final String? desaKelurahan;
  final String? kabupatenKode;
  final String? kecamatanKode;
  final String? desaKode;
  final String? urlFoto;
  final String? tipePengguna;
  final bool terverifikasi;
  final bool setujuKetentuan;
  final bool wajibGantiKataSandi;

  factory Pengguna.dariJson(Map<String, dynamic> json) {
    final status = json['status_verifikasi']?.toString();
    final wilayah = json['wilayah'] is Map
        ? Map<String, dynamic>.from(json['wilayah'] as Map)
        : const <String, dynamic>{};
    String? bagian(String prefiks, String sufiks) {
      final nested = wilayah[prefiks];
      if (nested is Map) {
        final v = nested[sufiks] ?? nested[sufiks == 'nama' ? 'name' : 'code'];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
      final flat = wilayah['${prefiks}_$sufiks'];
      if (flat != null && flat.toString().isNotEmpty) return flat.toString();
      return null;
    }

    return Pengguna(
      id: json['id']?.toString() ?? '',
      nik: json['nik_samar']?.toString() ??
          json['nik']?.toString() ??
          json['user_nik']?.toString() ??
          '',
      namaLengkap: json['nama_lengkap']?.toString() ??
          json['user_fullname']?.toString() ??
          json['full_name']?.toString() ??
          json['name']?.toString() ??
          '',
      namaPengguna: json['user_name']?.toString(),
      username: json['username']?.toString(),
      surel: json['email_samar']?.toString() ??
          json['email']?.toString() ??
          json['user_email']?.toString(),
      noHp: json['no_hp_samar']?.toString() ??
          json['no_hp']?.toString() ??
          json['phone']?.toString(),
      alamat: json['alamat']?.toString() ?? json['address']?.toString(),
      tempatLahir:
          json['tempat_lahir']?.toString() ?? json['birth_place']?.toString(),
      tanggalLahir:
          json['tanggal_lahir']?.toString() ?? json['birth_date']?.toString(),
      jenisKelamin: json['jenis_kelamin']?.toString(),
      bahasaPilihan: json['bahasa_pilihan']?.toString(),
      statusVerifikasi: status,
      nomorRegistrasi: json['nomor_registrasi']?.toString(),
      terakhirLoginPada: json['terakhir_login_pada']?.toString(),
      kabupatenKota: bagian('kabupaten', 'nama') ??
          json['district_name']?.toString() ??
          json['kab_kota']?.toString(),
      kecamatan: bagian('kecamatan', 'nama') ??
          json['sub_district_name']?.toString() ??
          json['kecamatan']?.toString(),
      desaKelurahan: bagian('desa', 'nama'),
      kabupatenKode: bagian('kabupaten', 'kode'),
      kecamatanKode: bagian('kecamatan', 'kode'),
      desaKode: bagian('desa', 'kode'),
      urlFoto: json['avatar']?.toString() ?? json['url_foto']?.toString(),
      tipePengguna: json['user_type']?.toString(),
      terverifikasi: json['terverifikasi'] == true ||
          status == 'terverifikasi' ||
          json['verified'] == true,
      setujuKetentuan: json['terms_accepted'] == true,
      wajibGantiKataSandi: json['wajib_ganti_kata_sandi'] == true,
    );
  }

  Map<String, dynamic> keJson() => {
        'id': id,
        'nik': nik,
        'nama_lengkap': namaLengkap,
        'user_name': namaPengguna,
        'username': username,
        'email_samar': surel,
        'no_hp_samar': noHp,
        'alamat': alamat,
        'tempat_lahir': tempatLahir,
        'tanggal_lahir': tanggalLahir,
        'jenis_kelamin': jenisKelamin,
        'bahasa_pilihan': bahasaPilihan,
        'status_verifikasi': statusVerifikasi,
        'nomor_registrasi': nomorRegistrasi,
        'terakhir_login_pada': terakhirLoginPada,
        'avatar': urlFoto,
        'user_type': tipePengguna,
        'terverifikasi': terverifikasi,
        'terms_accepted': setujuKetentuan,
      };

  String? get domisili {
    final bagian = [
      desaKelurahan,
      kecamatan,
      kabupatenKota,
    ].where((e) => e != null && e.isNotEmpty).toList();
    return bagian.isEmpty ? null : bagian.join(' · ');
  }

  String get inisial {
    final bagian = namaLengkap.trim().split(RegExp(r'\s+'));
    if (bagian.isEmpty || bagian.first.isEmpty) return '?';
    if (bagian.length == 1) {
      return bagian.first.substring(0, 1).toUpperCase();
    }
    return (bagian.first.substring(0, 1) + bagian.last.substring(0, 1))
        .toUpperCase();
  }

  Pengguna salin({
    String? namaLengkap,
    String? username,
    String? surel,
    String? noHp,
    String? alamat,
    String? tempatLahir,
    String? tanggalLahir,
    String? jenisKelamin,
    String? bahasaPilihan,
    String? statusVerifikasi,
    String? kabupatenKota,
    String? kecamatan,
    String? desaKelurahan,
    String? urlFoto,
    bool? terverifikasi,
  }) {
    return Pengguna(
      id: id,
      nik: nik,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      namaPengguna: namaPengguna,
      username: username ?? this.username,
      surel: surel ?? this.surel,
      noHp: noHp ?? this.noHp,
      alamat: alamat ?? this.alamat,
      tempatLahir: tempatLahir ?? this.tempatLahir,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      bahasaPilihan: bahasaPilihan ?? this.bahasaPilihan,
      statusVerifikasi: statusVerifikasi ?? this.statusVerifikasi,
      nomorRegistrasi: nomorRegistrasi,
      terakhirLoginPada: terakhirLoginPada,
      kabupatenKota: kabupatenKota ?? this.kabupatenKota,
      kecamatan: kecamatan ?? this.kecamatan,
      desaKelurahan: desaKelurahan ?? this.desaKelurahan,
      kabupatenKode: kabupatenKode,
      kecamatanKode: kecamatanKode,
      desaKode: desaKode,
      urlFoto: urlFoto ?? this.urlFoto,
      tipePengguna: tipePengguna,
      terverifikasi: terverifikasi ?? this.terverifikasi,
      setujuKetentuan: setujuKetentuan,
      wajibGantiKataSandi: wajibGantiKataSandi,
    );
  }
}
