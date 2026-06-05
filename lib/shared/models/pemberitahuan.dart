class Pemberitahuan {
  const Pemberitahuan({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.diterimaPada,
    this.dibaca = false,
    this.idPermohonan,
    this.kategori,
  });

  final String id;
  final String judul;
  final String pesan;
  final DateTime diterimaPada;
  final bool dibaca;
  final String? idPermohonan;
  final String? kategori;

  factory Pemberitahuan.dariJson(Map<String, dynamic> json) {
    return Pemberitahuan(
      id: json['id']?.toString() ?? '',
      judul: json['judul']?.toString() ?? '',
      pesan: json['pesan']?.toString() ?? '',
      diterimaPada: DateTime.tryParse(json['diterima_pada']?.toString() ?? '') ?? DateTime.now(),
      dibaca: json['dibaca'] == true,
      idPermohonan: json['id_permohonan']?.toString(),
      kategori: json['kategori']?.toString(),
    );
  }

  Pemberitahuan tandaiDibaca() => Pemberitahuan(
        id: id,
        judul: judul,
        pesan: pesan,
        diterimaPada: diterimaPada,
        dibaca: true,
        idPermohonan: idPermohonan,
        kategori: kategori,
      );
}
