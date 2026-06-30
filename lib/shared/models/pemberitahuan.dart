enum KategoriPemberitahuan { status, tindakan, info, sistem, takDikenal }

KategoriPemberitahuan _kategoriDari(String? nilai) {
  switch (nilai?.toLowerCase()) {
    case 'status':
      return KategoriPemberitahuan.status;
    case 'tindakan':
      return KategoriPemberitahuan.tindakan;
    case 'info':
      return KategoriPemberitahuan.info;
    case 'sistem':
      return KategoriPemberitahuan.sistem;
    default:
      return KategoriPemberitahuan.takDikenal;
  }
}

class MetadataPemberitahuan {
  const MetadataPemberitahuan({
    this.kodeReferensi,
    this.status,
    this.jenisLayanan,
    this.event,
  });

  final String? kodeReferensi;
  final String? status;
  final String? jenisLayanan;
  final String? event;

  factory MetadataPemberitahuan.dariJson(Map<String, dynamic> json) {
    return MetadataPemberitahuan(
      kodeReferensi: json['kode_referensi']?.toString(),
      status: json['status']?.toString(),
      jenisLayanan: json['jenis_layanan']?.toString(),
      event: json['event']?.toString(),
    );
  }
}

class Pemberitahuan {
  const Pemberitahuan({
    required this.id,
    required this.kategori,
    required this.judul,
    required this.pesan,
    required this.dikirimPada,
    this.permohonanId,
    this.metadata,
    this.dibaca = false,
    this.dibacaPada,
  });

  final String id;
  final KategoriPemberitahuan kategori;
  final String judul;
  final String pesan;
  final DateTime dikirimPada;
  final String? permohonanId;
  final MetadataPemberitahuan? metadata;
  final bool dibaca;
  final DateTime? dibacaPada;

  factory Pemberitahuan.dariJson(Map<String, dynamic> json) {
    final metaRaw = json['metadata'];
    final dibacaRaw = json['dibaca'];
    final bool dibaca;
    if (dibacaRaw is bool) {
      dibaca = dibacaRaw;
    } else {
      final status = json['status']?.toString().toLowerCase();
      dibaca = status != null && status != 'unread';
    }
    final permohonan =
        json['permohonan_id']?.toString() ?? json['id_referensi']?.toString();
    return Pemberitahuan(
      id: json['id']?.toString() ?? '',
      kategori: _kategoriDari(json['kategori']?.toString()),
      judul: json['judul']?.toString() ?? json['title']?.toString() ?? '',
      pesan: json['pesan']?.toString() ?? json['message']?.toString() ?? '',
      dikirimPada:
          DateTime.tryParse(
            json['dikirim_pada']?.toString() ??
                json['dibuat_pada']?.toString() ??
                json['created_at']?.toString() ??
                '',
          )?.toLocal() ??
          DateTime.now(),
      permohonanId: permohonan != null && permohonan.isNotEmpty
          ? permohonan
          : null,
      metadata: metaRaw is Map
          ? MetadataPemberitahuan.dariJson(Map<String, dynamic>.from(metaRaw))
          : null,
      dibaca: dibaca,
      dibacaPada: DateTime.tryParse(
        json['dibaca_pada']?.toString() ?? '',
      )?.toLocal(),
    );
  }

  Pemberitahuan tandaiDibaca() => Pemberitahuan(
    id: id,
    kategori: kategori,
    judul: judul,
    pesan: pesan,
    dikirimPada: dikirimPada,
    permohonanId: permohonanId,
    metadata: metadata,
    dibaca: true,
    dibacaPada: dibacaPada ?? DateTime.now(),
  );
}
