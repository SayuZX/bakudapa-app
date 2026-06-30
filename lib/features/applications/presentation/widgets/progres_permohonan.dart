import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../../shared/models/permohonan.dart';
import '../../../../shared/models/status_permohonan.dart';

class ProgresPermohonan extends StatelessWidget {
  const ProgresPermohonan({super.key, required this.permohonan});

  final Permohonan permohonan;

  static const List<StatusPermohonan> _tahap = [
    StatusPermohonan.menunggu,
    StatusPermohonan.diverifikasi,
    StatusPermohonan.diproses,
    StatusPermohonan.selesai,
  ];

  static const List<IconData> _ikon = [
    HugeIcons.strokeRoundedFile02,
    HugeIcons.strokeRoundedSearch01,
    HugeIcons.strokeRoundedReload,
    HugeIcons.strokeRoundedCheckmarkCircle02,
  ];

  @override
  Widget build(BuildContext context) {
    final status = permohonan.status;

    if (status == StatusPermohonan.ditolak) {
      return _Khusus(
        warna: Warna.bahaya,
        latar: Warna.bahayaLembut,
        ikon: HugeIcons.strokeRoundedCancelCircle,
        judul: status.label,
        catatan: permohonan.alasanPenolakan ?? permohonan.catatan,
      );
    }
    if (status == StatusPermohonan.tertunda ||
        status == StatusPermohonan.perluPerbaikan) {
      return _Khusus(
        warna: Warna.peringatan,
        latar: Warna.peringatanLembut,
        ikon: HugeIcons.strokeRoundedAlert02,
        judul: status.label,
        catatan: permohonan.catatan,
      );
    }
    if (status == StatusPermohonan.dibatalkan) {
      return _Khusus(
        warna: Warna.netral500,
        latar: Warna.netral100,
        ikon: HugeIcons.strokeRoundedCancelCircle,
        judul: status.label,
        catatan: permohonan.catatan,
      );
    }

    final aktif = status.langkahLini;
    return Row(
      children: [
        for (var i = 0; i < _tahap.length; i++)
          Expanded(
            child: _Node(
              ikon: _ikon[i],
              label: _tahap[i].label,
              tercapai: i <= aktif,
              selesai: i < aktif,
              garisKiriAktif: i <= aktif,
              garisKananAktif: i + 1 <= aktif,
              tampilkanKiri: i > 0,
              tampilkanKanan: i < _tahap.length - 1,
            ),
          ),
      ],
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({
    required this.ikon,
    required this.label,
    required this.tercapai,
    required this.selesai,
    required this.garisKiriAktif,
    required this.garisKananAktif,
    required this.tampilkanKiri,
    required this.tampilkanKanan,
  });

  final IconData ikon;
  final String label;
  final bool tercapai;
  final bool selesai;
  final bool garisKiriAktif;
  final bool garisKananAktif;
  final bool tampilkanKiri;
  final bool tampilkanKanan;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: tampilkanKiri
                  ? Container(
                      height: 3,
                      color: garisKiriAktif ? Warna.primer : Warna.garis,
                    )
                  : const SizedBox(),
            ),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: tercapai ? Warna.primer : Warna.permukaan,
                shape: BoxShape.circle,
                border: Border.all(
                  color: tercapai ? Warna.primer : Warna.garisTegas,
                  width: 1.5,
                ),
              ),
              child: Icon(
                selesai ? Icons.check_rounded : ikon,
                color: tercapai ? Colors.white : Warna.netral400,
                size: 17,
              ),
            ),
            Expanded(
              child: tampilkanKanan
                  ? Container(
                      height: 3,
                      color: garisKananAktif ? Warna.primer : Warna.garis,
                    )
                  : const SizedBox(),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.teks.labelSmall?.copyWith(
            color: tercapai ? Warna.teksUtama : Warna.teksKetiga,
            fontWeight: tercapai ? FontWeight.w700 : FontWeight.w600,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}

class _Khusus extends StatelessWidget {
  const _Khusus({
    required this.warna,
    required this.latar,
    required this.ikon,
    required this.judul,
    this.catatan,
  });

  final Color warna;
  final Color latar;
  final IconData ikon;
  final String judul;
  final String? catatan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Jarak.md),
      decoration: BoxDecoration(
        color: latar,
        borderRadius: BorderRadius.circular(Sudut.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
            child: Icon(ikon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: Jarak.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: context.teks.titleSmall
                      ?.copyWith(color: warna, fontWeight: FontWeight.w800),
                ),
                if (catatan != null && catatan!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    catatan!,
                    style: context.teks.bodySmall
                        ?.copyWith(color: Warna.teksKedua, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
