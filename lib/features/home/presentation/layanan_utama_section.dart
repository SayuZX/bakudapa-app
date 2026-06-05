import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/nama_rute.dart';
import '../../../shared/models/jenis_layanan.dart';

class LayananUtamaSection extends StatelessWidget {
  const LayananUtamaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<JenisLayanan> daftar = JenisLayanan.daring.take(4).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Layanan Utama',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF14171F),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push(NamaRute.layanan),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFC8102E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              for (int i = 0; i < daftar.length; i++) ...<Widget>[
                Expanded(child: _MenuItem(jenis: daftar[i])),
                if (i != daftar.length - 1) const SizedBox(width: 12),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.jenis});

  final JenisLayanan jenis;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('${NamaRute.detailLayanan}/${jenis.kode}'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE3E6EB)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(jenis.ikon, size: 24, color: const Color(0xFF14171F)),
          ),
          const SizedBox(height: 7),
          Text(
            jenis.nama,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5A6171),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
