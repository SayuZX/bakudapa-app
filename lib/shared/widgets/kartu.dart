import 'package:flutter/material.dart';

import '../../core/theme/bayangan.dart';
import '../../core/theme/dimensi.dart';
import '../../core/theme/warna.dart';

class Kartu extends StatelessWidget {
  const Kartu({
    super.key,
    required this.anak,
    this.pengisi = const EdgeInsets.all(Jarak.lg),
    this.saatKetuk,
    this.warna,
    this.bergaris = true,
    this.bayangan = false,
  });

  final Widget anak;
  final EdgeInsets pengisi;
  final VoidCallback? saatKetuk;
  final Color? warna;
  final bool bergaris;
  final bool bayangan;

  @override
  Widget build(BuildContext context) {
    final bentuk = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Sudut.lg),
      side: bergaris ? const BorderSide(color: Warna.garis) : BorderSide.none,
    );

    final kartu = Material(
      color: warna ?? Warna.permukaan,
      shape: bentuk,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: saatKetuk,
        splashColor: Warna.merahLembut,
        highlightColor: Warna.merahLembut,
        child: Padding(padding: pengisi, child: anak),
      ),
    );

    if (!bayangan) return kartu;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sudut.lg),
        boxShadow: Bayangan.kartu,
      ),
      child: kartu,
    );
  }
}
