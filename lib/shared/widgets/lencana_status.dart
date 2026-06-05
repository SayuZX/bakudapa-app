import 'package:flutter/material.dart';

import '../../core/theme/dimensi.dart';
import '../../core/theme/warna.dart';
import '../models/status_permohonan.dart';

class LencanaStatus extends StatelessWidget {
  const LencanaStatus({
    super.key,
    required this.status,
    this.kompak = false,
  });

  final StatusPermohonan status;
  final bool kompak;

  @override
  Widget build(BuildContext context) {
    final nada = _nada(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: kompak ? 8 : 10,
        vertical: kompak ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: nada.latar,
        borderRadius: BorderRadius.circular(Sudut.pil),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: nada.depan, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: nada.depan,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      ),
    );
  }

  _Nada _nada(StatusPermohonan s) {
    switch (s) {
      case StatusPermohonan.menunggu:
        return const _Nada(Warna.tundaLembut, Warna.tunda);
      case StatusPermohonan.diverifikasi:
      case StatusPermohonan.diproses:
        return const _Nada(Warna.infoLembut, Warna.info);
      case StatusPermohonan.tertunda:
        return const _Nada(Warna.peringatanLembut, Warna.peringatan);
      case StatusPermohonan.ditolak:
        return const _Nada(Warna.bahayaLembut, Warna.bahaya);
      case StatusPermohonan.selesai:
        return const _Nada(Warna.suksesLembut, Warna.sukses);
    }
  }
}

class _Nada {
  const _Nada(this.latar, this.depan);
  final Color latar;
  final Color depan;
}
