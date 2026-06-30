class Wilayah {
  const Wilayah({required this.kode, required this.nama});

  final String kode;
  final String nama;

  factory Wilayah.dariJson(Map<String, dynamic> json) {
    return Wilayah(
      kode:
          json['kode']?.toString() ??
          json['code']?.toString() ??
          json['id']?.toString() ??
          '',
      nama:
          json['nama']?.toString() ??
          json['name']?.toString() ??
          json['label']?.toString() ??
          '',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Wilayah && other.kode == kode && other.nama == nama;

  @override
  int get hashCode => Object.hash(kode, nama);
}
