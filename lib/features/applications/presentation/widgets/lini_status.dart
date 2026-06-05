import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../../core/utils/format.dart';
import '../../../../shared/models/permohonan.dart';
import '../../../../shared/models/status_permohonan.dart';

class LiniStatus extends StatelessWidget {
  const LiniStatus({super.key, required this.permohonan});
  final Permohonan permohonan;

  @override
  Widget build(BuildContext context) {
    final daftar = permohonan.timeline.isNotEmpty
        ? permohonan.timeline
        : _bangunDariStatus(permohonan);

    return Column(
      children: [
        for (var i = 0; i < daftar.length; i++)
          _Baris(
            riwayat: daftar[i],
            pertama: i == 0,
            terakhir: i == daftar.length - 1,
          ),
      ],
    );
  }

  List<RiwayatStatus> _bangunDariStatus(Permohonan p) {
    final dasar = [
      RiwayatStatus(status: StatusPermohonan.menunggu, waktu: p.diajukanPada,
          deskripsi: 'Permohonan diterima sistem.'),
    ];
    if (p.status.langkahLini >= 1) {
      dasar.add(RiwayatStatus(
          status: StatusPermohonan.diverifikasi,
          waktu: p.diperbaruiPada ?? p.diajukanPada));
    }
    if (p.status.langkahLini >= 2) {
      dasar.add(RiwayatStatus(
          status: StatusPermohonan.diproses,
          waktu: p.diperbaruiPada ?? p.diajukanPada));
    }
    if (p.status == StatusPermohonan.selesai) {
      dasar.add(RiwayatStatus(
          status: StatusPermohonan.selesai,
          waktu: p.diperbaruiPada ?? p.diajukanPada));
    }
    if (p.status == StatusPermohonan.ditolak) {
      dasar.add(RiwayatStatus(
          status: StatusPermohonan.ditolak,
          waktu: p.diperbaruiPada ?? p.diajukanPada,
          deskripsi: p.catatan));
    }
    if (p.status == StatusPermohonan.tertunda) {
      dasar.add(RiwayatStatus(
          status: StatusPermohonan.tertunda,
          waktu: p.diperbaruiPada ?? p.diajukanPada,
          deskripsi: p.catatan));
    }
    return dasar;
  }
}

class _Baris extends StatelessWidget {
  const _Baris({required this.riwayat, required this.pertama, required this.terakhir});
  final RiwayatStatus riwayat;
  final bool pertama;
  final bool terakhir;

  Color _warnaStatus(StatusPermohonan s) {
    switch (s) {
      case StatusPermohonan.selesai:
        return Warna.sukses;
      case StatusPermohonan.ditolak:
        return Warna.bahaya;
      case StatusPermohonan.tertunda:
        return Warna.peringatan;
      case StatusPermohonan.diverifikasi:
      case StatusPermohonan.diproses:
        return Warna.info;
      case StatusPermohonan.menunggu:
        return Warna.tunda;
    }
  }

  Color _latarStatus(StatusPermohonan s) {
    switch (s) {
      case StatusPermohonan.selesai:
        return Warna.suksesLembut;
      case StatusPermohonan.ditolak:
        return Warna.bahayaLembut;
      case StatusPermohonan.tertunda:
        return Warna.peringatanLembut;
      case StatusPermohonan.diverifikasi:
      case StatusPermohonan.diproses:
        return Warna.infoLembut;
      case StatusPermohonan.menunggu:
        return Warna.tundaLembut;
    }
  }

  IconData _ikon(StatusPermohonan s) {
    switch (s) {
      case StatusPermohonan.selesai:
        return HugeIcons.strokeRoundedCheckmarkCircle02;
      case StatusPermohonan.ditolak:
        return HugeIcons.strokeRoundedCancelCircle;
      case StatusPermohonan.tertunda:
        return HugeIcons.strokeRoundedAlert02;
      case StatusPermohonan.diverifikasi:
      case StatusPermohonan.diproses:
        return HugeIcons.strokeRoundedReload;
      case StatusPermohonan.menunggu:
        return HugeIcons.strokeRoundedClock01;
    }
  }

  @override
  Widget build(BuildContext context) {
    final warna = _warnaStatus(riwayat.status);
    final latar = _latarStatus(riwayat.status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: latar,
                  shape: BoxShape.circle,
                  border: Border.all(color: warna, width: 1.5),
                ),
                child: Icon(_ikon(riwayat.status), color: warna, size: 16),
              ),
              if (!terakhir)
                Expanded(
                  child: Container(width: 2, color: Warna.garis, margin: const EdgeInsets.symmetric(vertical: 4)),
                ),
            ],
          ),
          const SizedBox(width: Jarak.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: terakhir ? 0 : Jarak.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    riwayat.status.label,
                    style: context.teks.titleSmall?.copyWith(color: warna),
                  ),
                  Text(
                    Format.tanggalJam(riwayat.waktu),
                    style: context.teks.bodySmall?.copyWith(color: Warna.teksKedua),
                  ),
                  if (riwayat.deskripsi != null && riwayat.deskripsi!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(riwayat.deskripsi!, style: context.teks.bodyMedium),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
