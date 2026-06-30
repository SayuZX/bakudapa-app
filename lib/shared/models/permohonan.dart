import 'jenis_layanan.dart';
import 'status_permohonan.dart';

class Permohonan {
  const Permohonan({
    required this.id,
    required this.nomorPermohonan,
    required this.slugLayanan,
    required this.status,
    required this.diajukanPada,
    this.namaPemohon,
    this.nikPemohon,
    this.diperbaruiPada,
    this.diselesaikanPada,
    this.catatan,
    this.alasanPenolakan,
    this.detail = const <String, dynamic>{},
  });

  final String id;
  final String nomorPermohonan;
  final String slugLayanan;
  final StatusPermohonan status;
  final DateTime diajukanPada;
  final String? namaPemohon;
  final String? nikPemohon;
  final DateTime? diperbaruiPada;
  final DateTime? diselesaikanPada;
  final String? catatan;
  final String? alasanPenolakan;
  final Map<String, dynamic> detail;

  JenisLayanan? get jenis => JenisLayanan.dariSlug(slugLayanan);

  String get namaLayanan {
    final nama = detail['nama_layanan']?.toString() ??
        detail['service_type_label']?.toString();
    if (nama != null && nama.isNotEmpty) return nama;
    return JenisLayanan.labelSlug(slugLayanan);
  }

  factory Permohonan.dariJson(
    Map<String, dynamic> json, {
    String? slugLayanan,
  }) {
    final slug = slugLayanan ??
        json['jenis_layanan']?.toString() ??
        json['service_type_slug']?.toString() ??
        json['service_type']?.toString() ??
        '';
    return Permohonan(
      id: json['id']?.toString() ?? '',
      nomorPermohonan: json['kode_referensi']?.toString() ??
          json['application_number']?.toString() ??
          '',
      slugLayanan: slug,
      status: StatusPermohonan.dariKode(
        json['status']?.toString() ?? json['progress_status']?.toString(),
      ),
      diajukanPada: DateTime.tryParse(
                json['diajukan_pada']?.toString() ??
                    json['created_at']?.toString() ??
                    '',
              )?.toLocal() ??
              DateTime.now(),
      namaPemohon: json['applicant_name']?.toString(),
      nikPemohon: json['applicant_nik']?.toString(),
      diperbaruiPada: DateTime.tryParse(
        json['diperbarui_pada']?.toString() ??
            json['updated_at']?.toString() ??
            '',
      )?.toLocal(),
      diselesaikanPada:
          DateTime.tryParse(json['diselesaikan_pada']?.toString() ?? '')
              ?.toLocal(),
      catatan: json['catatan']?.toString() ?? json['notes']?.toString(),
      alasanPenolakan: json['alasan_penolakan']?.toString() ??
          json['rejection_reason']?.toString(),
      detail: json,
    );
  }
}
