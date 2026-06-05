import 'package:flutter/material.dart';

enum KeputusanAi {
  terverifikasi('terverifikasi'),
  ditolak('ditolak'),
  perluRevisi('perlu_revisi'),
  perluReviewManusia('perlu_review_manusia'),
  diluarCakupan('diluar_cakupan');

  const KeputusanAi(this.value);
  final String value;

  static KeputusanAi fromString(String? raw) =>
      values.firstWhere((e) => e.value == raw, orElse: () => perluReviewManusia);

  String get labelId => switch (this) {
        terverifikasi => 'Terverifikasi',
        ditolak => 'Ditolak',
        perluRevisi => 'Perlu Revisi',
        perluReviewManusia => 'Sedang Ditinjau Operator',
        diluarCakupan => 'Di Luar Cakupan',
      };

  Color get warna => switch (this) {
        terverifikasi => Colors.green,
        ditolak => Colors.red,
        perluRevisi => Colors.orange,
        perluReviewManusia => Colors.amber,
        diluarCakupan => Colors.grey,
      };

  IconData get ikon => switch (this) {
        terverifikasi => Icons.verified,
        ditolak => Icons.cancel,
        perluRevisi => Icons.edit,
        perluReviewManusia => Icons.hourglass_top,
        diluarCakupan => Icons.info_outline,
      };
}
