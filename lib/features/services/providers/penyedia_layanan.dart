import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/jenis_layanan.dart';
import '../data/repositori_layanan_api.dart';
import '../domain/detail_layanan.dart';
import '../domain/repositori_layanan.dart';

final penyediaRepositoriLayanan =
    Provider<RepositoriLayanan>((ref) => RepositoriLayananApi());

class FilterDaftarLayanan {
  const FilterDaftarLayanan({this.cari, this.kategori});

  final String? cari;
  final String? kategori;

  @override
  bool operator ==(Object other) =>
      other is FilterDaftarLayanan &&
      other.cari == cari &&
      other.kategori == kategori;

  @override
  int get hashCode => Object.hash(cari, kategori);
}

final penyediaDaftarLayanan = FutureProvider.autoDispose
    .family<List<RingkasanLayanan>, FilterDaftarLayanan>((ref, filter) async {
  return ref.watch(penyediaRepositoriLayanan).mintaDaftar(
        cari: filter.cari,
        kategori: filter.kategori,
      );
});

final penyediaDetailLayanan = FutureProvider.autoDispose
    .family<DetailLayanan, String>((ref, kode) async {
  return ref.watch(penyediaRepositoriLayanan).mintaDetail(kode);
});
