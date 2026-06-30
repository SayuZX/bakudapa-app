enum TipeRuas {
  teks,
  angka,
  tanggal,
  jam,
  pilihan,
  multiPilihan,
  daftarNik,
  perubahanBiodata,
  areaTeks,
  email,
}

class PilihanRuas {
  const PilihanRuas(this.nilai, this.label);
  final String nilai;
  final String label;
}

class KondisiTampil {
  const KondisiTampil({required this.kunciRuas, required this.salahSatuDari});
  final String kunciRuas;
  final List<String> salahSatuDari;

  bool terpenuhi(Map<String, String> nilai) {
    final v = nilai[kunciRuas] ?? '';
    if (salahSatuDari.contains(v)) return true;
    return v
        .split(';')
        .where((e) => e.isNotEmpty)
        .any(salahSatuDari.contains);
  }
}

class DefinisiRuas {
  const DefinisiRuas({
    required this.kunci,
    required this.label,
    required this.tipe,
    this.wajib = false,
    this.panjangMin,
    this.panjangMaks,
    this.placeholder,
    this.min,
    this.maks,
    this.desimal = false,
    this.hanyaAngka = false,
    this.pilihan = const <PilihanRuas>[],
    this.kondisi,
  });

  final String kunci;
  final String label;
  final TipeRuas tipe;
  final bool wajib;
  final int? panjangMin;
  final int? panjangMaks;
  final String? placeholder;
  final double? min;
  final double? maks;
  final bool desimal;
  final bool hanyaAngka;
  final List<PilihanRuas> pilihan;
  final KondisiTampil? kondisi;

  String get _kunciKecil => kunci.toLowerCase();

  bool get adalahNik => _kunciKecil.contains('nik');

  bool get adalahNoKk =>
      _kunciKecil.contains('kk') || _kunciKecil.contains('kartu_keluarga');

  bool get nomorIdentitas16 =>
      panjangMaks == 16 && (panjangMin == 16 || adalahNik || adalahNoKk);
}

class DefinisiDokumen {
  const DefinisiDokumen({
    required this.kunci,
    required this.label,
    this.wajib = false,
    this.kondisi,
    this.mimeTypes = const <String>[],
    this.maksByte,
  });

  final String kunci;
  final String label;
  final bool wajib;
  final KondisiTampil? kondisi;
  final List<String> mimeTypes;
  final int? maksByte;
}

class FormulirPdf {
  const FormulirPdf({required this.nama, required this.namaBerkas});
  final String nama;
  final String namaBerkas;
}
