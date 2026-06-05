import 'jenis_layanan.dart';
import 'status_permohonan.dart';

class Permohonan {
  const Permohonan({
    required this.id,
    required this.kodeReferensi,
    required this.jenis,
    required this.status,
    required this.diajukanPada,
    this.diperbaruiPada,
    this.catatan,
    this.urlDokumenHasil,
    this.timeline = const <RiwayatStatus>[],
  });

  final String id;
  final String kodeReferensi;
  final JenisLayanan jenis;
  final StatusPermohonan status;
  final DateTime diajukanPada;
  final DateTime? diperbaruiPada;
  final String? catatan;
  final String? urlDokumenHasil;
  final List<RiwayatStatus> timeline;

  factory Permohonan.dariJson(Map<String, dynamic> json) {
    final timeline = (json['timeline'] as List<dynamic>?)
            ?.map((e) => RiwayatStatus.dariJson(e as Map<String, dynamic>))
            .toList() ??
        const <RiwayatStatus>[];
    return Permohonan(
      id: json['id']?.toString() ?? '',
      kodeReferensi: json['kode_referensi']?.toString() ?? json['reference']?.toString() ?? '',
      jenis: JenisLayanan.dariKode(json['jenis']?.toString() ?? ''),
      status: StatusPermohonan.dariKode(json['status']?.toString()),
      diajukanPada: DateTime.tryParse(json['diajukan_pada']?.toString() ?? '') ?? DateTime.now(),
      diperbaruiPada: DateTime.tryParse(json['diperbarui_pada']?.toString() ?? ''),
      catatan: json['catatan']?.toString(),
      urlDokumenHasil: json['url_dokumen_hasil']?.toString(),
      timeline: timeline,
    );
  }
}

class RiwayatStatus {
  const RiwayatStatus({
    required this.status,
    required this.waktu,
    this.deskripsi,
    this.olehPetugas,
  });

  final StatusPermohonan status;
  final DateTime waktu;
  final String? deskripsi;
  final String? olehPetugas;

  factory RiwayatStatus.dariJson(Map<String, dynamic> json) {
    return RiwayatStatus(
      status: StatusPermohonan.dariKode(json['status']?.toString()),
      waktu: DateTime.tryParse(json['waktu']?.toString() ?? '') ?? DateTime.now(),
      deskripsi: json['deskripsi']?.toString(),
      olehPetugas: json['petugas']?.toString(),
    );
  }
}
