import '../../../shared/models/jenis_layanan.dart';
import 'definisi_formulir.dart';

class Persyaratan {
  const Persyaratan({required this.teks, this.wajib = true});

  final String teks;
  final bool wajib;
}

class GrupFormulir {
  const GrupFormulir({required this.judul, required this.ruas});

  final String judul;
  final List<DefinisiRuas> ruas;
}

class DetailLayanan {
  const DetailLayanan({
    required this.kode,
    required this.nama,
    required this.formulir,
    required this.persyaratan,
    this.dokumen = const <DefinisiDokumen>[],
    this.deskripsi,
    this.kategori,
    this.kebijakan,
    this.formulirPdf = const <FormulirPdf>[],
    this.urlFormulirPdf,
    this.langkahPanduan = const <String>[],
    this.estimasiMenit = 10,
    this.dariServer = false,
  });

  final String kode;
  final String nama;
  final String? deskripsi;
  final String? kategori;
  final List<GrupFormulir> formulir;
  final List<Persyaratan> persyaratan;
  final List<DefinisiDokumen> dokumen;
  final Map<String, String>? kebijakan;
  final List<FormulirPdf> formulirPdf;
  final String? urlFormulirPdf;
  final List<String> langkahPanduan;
  final int estimasiMenit;
  final bool dariServer;

  JenisLayanan? get jenis => JenisLayanan.dariSlug(kode);

  List<String> get persyaratanTeks =>
      persyaratan.map((e) => e.teks).toList(growable: false);

  List<DefinisiDokumen> get slotDokumen {
    if (dokumen.isNotEmpty) return dokumen;
    return [
      for (final (i, syarat) in persyaratan.indexed)
        DefinisiDokumen(
          kunci: 'dokumen_${i + 1}',
          label: syarat.teks,
          wajib: syarat.wajib,
        ),
    ];
  }

  factory DetailLayanan.dariJson(
    Map<String, dynamic> json, {
    required String kode,
  }) {
    final kodeFinal = _teks(json, const ['kode', 'slug', 'id']).isNotEmpty
        ? _teks(json, const ['kode', 'slug', 'id'])
        : kode;

    final nama = _teks(json, const ['nama', 'nama_layanan', 'title', 'name']);
    final kategori =
        _teks(json, const ['kategori', 'category', 'kelompok']);
    final deskripsi =
        _teks(json, const ['deskripsi', 'description', 'keterangan']);

    final grup = _parseFormulir(_ambilFields(json));
    final persyaratan = _parsePersyaratan(json);

    final dokumenMentah = _ambilDaftar(
      json,
      const ['dokumen_definisi', 'dokumen', 'documents', 'lampiran', 'attachments'],
    );
    final dokumen = _parseDokumen(dokumenMentah);

    final kebijakan = _parseKebijakan(json);
    final pdf = _parsePdf(json);
    final urlPdf = _teks(
      json,
      const ['url_formulir_pdf', 'formulir_pdf_url', 'pdf_url', 'url_pdf'],
    );
    final panduan = _parsePanduan(json);
    final estimasi = _angka(json, const ['estimasi_menit', 'estimasi', 'eta']);

    return DetailLayanan(
      kode: kodeFinal,
      nama: nama.isNotEmpty ? nama : JenisLayanan.labelSlug(kodeFinal),
      deskripsi: deskripsi.isEmpty ? null : deskripsi,
      kategori: kategori.isEmpty ? null : kategori,
      formulir: grup,
      persyaratan: persyaratan,
      dokumen: dokumen,
      kebijakan: kebijakan,
      formulirPdf: pdf,
      urlFormulirPdf: urlPdf.isEmpty ? null : urlPdf,
      langkahPanduan: panduan,
      estimasiMenit: estimasi ?? 10,
      dariServer: grup.isNotEmpty || persyaratan.isNotEmpty || dokumen.isNotEmpty,
    );
  }

  static List<GrupFormulir> _parseFormulir(List<Map<String, dynamic>> mentah) {
    if (mentah.isEmpty) return const [];
    final adaGrup = mentah.any(
      (e) =>
          e.containsKey('ruas') ||
          e.containsKey('fields') ||
          e.containsKey('field') ||
          e.containsKey('items'),
    );
    if (adaGrup) {
      final hasil = <GrupFormulir>[];
      for (final grupJson in mentah) {
        final judul = _teks(grupJson, const ['judul', 'title', 'grup', 'group', 'nama']);
        final ruasMentah = _ambilDaftar(
          grupJson,
          const ['ruas', 'fields', 'field', 'items'],
        );
        final ruas = ruasMentah
            .map(_parseRuas)
            .whereType<DefinisiRuas>()
            .toList();
        if (ruas.isNotEmpty) {
          hasil.add(GrupFormulir(judul: judul.isEmpty ? 'Data' : judul, ruas: ruas));
        }
      }
      return hasil;
    }
    final ruas = mentah.map(_parseRuas).whereType<DefinisiRuas>().toList();
    if (ruas.isEmpty) return const [];
    return [GrupFormulir(judul: 'Data Permohonan', ruas: ruas)];
  }

  static DefinisiRuas? _parseRuas(Map<String, dynamic> json) {
    final kunci = _teks(json, const ['kunci', 'key', 'name', 'kode']);
    if (kunci.isEmpty) return null;
    final label = _teks(json, const ['label', 'judul', 'title', 'nama']);
    final tipe = _parseTipe(_teks(json, const ['tipe', 'type', 'jenis']));
    final wajib = _bool(json, const ['wajib', 'required', 'mandatory']);
    final placeholder = _teks(json, const ['placeholder', 'petunjuk', 'hint']);
    final panjangMaks = _angka(json, const ['panjang_maks', 'panjang_maksimal', 'max_length', 'maxlength']);
    final panjangMin = _angka(json, const ['panjang_min', 'panjang_minimal', 'min_length', 'minlength']);
    final min = _desimal(json, const ['min', 'minimum', 'nilai_min']);
    final maks = _desimal(json, const ['maks', 'maksimum', 'max', 'nilai_maks']);
    final desimal = _bool(json, const ['desimal', 'decimal']);
    final hanyaAngka = _bool(json, const ['hanya_angka', 'numeric', 'angka']);
    final pilihan = _parsePilihan(json);
    final kondisi = _parseKondisi(json);

    return DefinisiRuas(
      kunci: kunci,
      label: label.isEmpty ? kunci : label,
      tipe: tipe,
      wajib: wajib,
      panjangMin: panjangMin,
      panjangMaks: panjangMaks,
      placeholder: placeholder.isEmpty ? null : placeholder,
      min: min,
      maks: maks,
      desimal: desimal,
      hanyaAngka: hanyaAngka,
      pilihan: pilihan,
      kondisi: kondisi,
    );
  }

  static List<PilihanRuas> _parsePilihan(Map<String, dynamic> json) {
    final mentah = _ambilDaftarDinamis(
      json,
      const ['pilihan', 'options', 'opsi', 'choices'],
    );
    final hasil = <PilihanRuas>[];
    for (final item in mentah) {
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final nilai = _teks(map, const ['nilai', 'value', 'kode', 'id']);
        final label = _teks(map, const ['label', 'teks', 'text', 'nama']);
        if (nilai.isNotEmpty) {
          hasil.add(PilihanRuas(nilai, label.isEmpty ? nilai : label));
        }
      } else if (item != null) {
        final nilai = item.toString();
        if (nilai.isNotEmpty) hasil.add(PilihanRuas(nilai, nilai));
      }
    }
    return hasil;
  }

  static KondisiTampil? _parseKondisi(Map<String, dynamic> json) {
    final kondisi = json['kondisi'] ?? json['condition'] ?? json['tampil_jika'];
    if (kondisi is! Map) return null;
    final map = Map<String, dynamic>.from(kondisi);
    final kunciRuas = _teks(map, const ['kunci_ruas', 'kunci', 'key', 'field']);
    if (kunciRuas.isEmpty) return null;
    final nilai = map['salah_satu_dari'] ??
        map['nilai'] ??
        map['value'] ??
        map['values'] ??
        map['in'];
    final daftar = <String>[];
    if (nilai is List) {
      daftar.addAll(nilai.map((e) => e.toString()));
    } else if (nilai != null) {
      daftar.add(nilai.toString());
    }
    if (daftar.isEmpty) return null;
    return KondisiTampil(kunciRuas: kunciRuas, salahSatuDari: daftar);
  }

  static List<Persyaratan> _parsePersyaratan(Map<String, dynamic> json) {
    final mentah = _ambilDaftarDinamis(
      json,
      const ['berkas_disiapkan', 'persyaratan', 'syarat', 'requirements', 'dokumen_persyaratan'],
    );
    final hasil = <Persyaratan>[];
    for (final item in mentah) {
      if (item is String) {
        final teks = item.trim();
        if (teks.isNotEmpty) hasil.add(Persyaratan(teks: teks));
      } else if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final teks = _teks(map, const ['teks', 'label', 'nama', 'title', 'keterangan', 'deskripsi']);
        if (teks.isEmpty) continue;
        hasil.add(Persyaratan(
          teks: teks,
          wajib: _bool(map, const ['wajib', 'required', 'mandatory'], bawaan: true),
        ));
      }
    }
    return hasil;
  }

  static List<DefinisiDokumen> _parseDokumen(List<Map<String, dynamic>> mentah) {
    final hasil = <DefinisiDokumen>[];
    for (final (i, item) in mentah.indexed) {
      final label = _teks(
        item,
        const ['label', 'nama', 'judul', 'title', 'keterangan'],
      );
      if (label.isEmpty) continue;
      final kunci = _teks(item, const ['kunci', 'key', 'jenis', 'type', 'kode']);
      final wajib = _bool(item, const ['wajib', 'required', 'mandatory']);
      hasil.add(
        DefinisiDokumen(
          kunci: kunci.isEmpty ? 'dokumen_${i + 1}' : kunci,
          label: label,
          wajib: wajib,
          kondisi: _parseKondisi(item),
          mimeTypes: _parseMimeTypes(item),
          maksByte: _angka(item, const ['max_size_byte', 'maks_byte', 'ukuran_maks', 'max_size']),
        ),
      );
    }
    return hasil;
  }

  static List<String> _parsePanduan(Map<String, dynamic> json) {
    final mentah = _ambilDaftarDinamis(
      json,
      const ['langkah_panduan', 'panduan', 'langkah', 'steps', 'guide'],
    );
    final hasil = <String>[];
    for (final item in mentah) {
      if (item is String) {
        final teks = item.trim();
        if (teks.isNotEmpty) hasil.add(teks);
      } else if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final teks = _teks(
          map,
          const ['teks', 'label', 'judul', 'title', 'deskripsi', 'keterangan', 'langkah'],
        );
        if (teks.isNotEmpty) hasil.add(teks);
      }
    }
    return hasil;
  }

  static Map<String, String>? _parseKebijakan(Map<String, dynamic> json) {
    final kebijakan = json['kebijakan'] ?? json['policy'] ?? json['kebijakan_layanan'];
    if (kebijakan is! Map) return null;
    final hasil = <String, String>{};
    kebijakan.forEach((k, v) {
      if (v != null && v.toString().trim().isNotEmpty) {
        hasil[k.toString()] = v.toString();
      }
    });
    return hasil.isEmpty ? null : hasil;
  }

  static List<FormulirPdf> _parsePdf(Map<String, dynamic> json) {
    final mentah = _ambilDaftar(
      json,
      const ['formulir_pdf', 'pdf', 'lampiran_pdf', 'forms'],
    );
    final hasil = <FormulirPdf>[];
    for (final item in mentah) {
      final nama = _teks(item, const ['nama', 'judul', 'title', 'label']);
      final berkas = _teks(item, const ['nama_berkas', 'file_name', 'berkas', 'file']);
      if (nama.isEmpty && berkas.isEmpty) continue;
      hasil.add(
        FormulirPdf(
          nama: nama.isEmpty ? berkas : nama,
          namaBerkas: berkas.isEmpty ? nama : berkas,
        ),
      );
    }
    return hasil;
  }

  static TipeRuas _parseTipe(String mentah) {
    switch (mentah.toLowerCase().trim()) {
      case 'angka':
      case 'number':
      case 'numeric':
      case 'integer':
        return TipeRuas.angka;
      case 'tanggal':
      case 'date':
        return TipeRuas.tanggal;
      case 'jam':
      case 'time':
      case 'waktu':
        return TipeRuas.jam;
      case 'pilihan':
      case 'select':
      case 'dropdown':
      case 'enum':
        return TipeRuas.pilihan;
      case 'multiselect':
      case 'multi_pilihan':
      case 'multi-select':
      case 'pilihan_ganda':
        return TipeRuas.multiPilihan;
      case 'nik_list':
      case 'daftar_nik':
      case 'nik-list':
        return TipeRuas.daftarNik;
      case 'biodata_changes':
      case 'perubahan_biodata':
      case 'biodata-changes':
        return TipeRuas.perubahanBiodata;
      case 'area_teks':
      case 'textarea':
      case 'teks_panjang':
        return TipeRuas.areaTeks;
      case 'email':
      case 'surel':
        return TipeRuas.email;
      default:
        return TipeRuas.teks;
    }
  }

  static List<String> _parseMimeTypes(Map<String, dynamic> json) {
    final mentah = _ambilDaftarDinamis(
      json,
      const ['mime_types', 'mime', 'tipe_mime', 'tipe_konten'],
    );
    return mentah
        .map((e) => e.toString().trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  static String _teks(Map<String, dynamic> json, List<String> kunci) {
    for (final k in kunci) {
      final nilai = json[k];
      if (nilai != null && nilai.toString().trim().isNotEmpty) {
        return nilai.toString().trim();
      }
    }
    return '';
  }

  static bool _bool(
    Map<String, dynamic> json,
    List<String> kunci, {
    bool bawaan = false,
  }) {
    for (final k in kunci) {
      final nilai = json[k];
      if (nilai is bool) return nilai;
      if (nilai is num) return nilai != 0;
      if (nilai is String) {
        final bersih = nilai.toLowerCase().trim();
        if (bersih == 'true' || bersih == '1' || bersih == 'ya') return true;
        if (bersih == 'false' || bersih == '0' || bersih == 'tidak') {
          return false;
        }
      }
    }
    return bawaan;
  }

  static int? _angka(Map<String, dynamic> json, List<String> kunci) {
    for (final k in kunci) {
      final nilai = json[k];
      if (nilai is int) return nilai;
      if (nilai is num) return nilai.toInt();
      if (nilai is String) {
        final parsed = int.tryParse(nilai.trim());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static double? _desimal(Map<String, dynamic> json, List<String> kunci) {
    for (final k in kunci) {
      final nilai = json[k];
      if (nilai is num) return nilai.toDouble();
      if (nilai is String) {
        final parsed = double.tryParse(nilai.trim());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static List<Map<String, dynamic>> _ambilFields(Map<String, dynamic> json) {
    final def = json['formulir_definisi'] ?? json['formulir'] ?? json['form'];
    if (def is Map) {
      final fields = def['fields'] ?? def['ruas'] ?? def['items'];
      if (fields is List) {
        return fields.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return const [];
    }
    if (def is List) {
      return def.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return _ambilDaftar(json, const ['skema_formulir', 'schema', 'fields', 'ruas']);
  }

  static List<Map<String, dynamic>> _ambilDaftar(
    Map<String, dynamic> json,
    List<String> kunci,
  ) {
    return _ambilDaftarDinamis(json, kunci)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static List<dynamic> _ambilDaftarDinamis(
    Map<String, dynamic> json,
    List<String> kunci,
  ) {
    for (final k in kunci) {
      final nilai = json[k];
      if (nilai is List) return nilai;
    }
    return const [];
  }
}
