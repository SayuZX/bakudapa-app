import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../dialogs/dialog_aplikasi.dart';
import '../localization/teks.dart';
import '../../shared/providers/penyedia_bahasa.dart';
import 'layanan_status_sistem.dart';
import 'model_status_maintenance.dart';

class PenjagaMaintenance {
  PenjagaMaintenance._();

  static bool _dialogTerbuka = false;

  static Future<bool> cekUntukAksi({
    required BuildContext context,
    required WidgetRef ref,
    String? kunciFitur,
    bool tampilkanDialog = true,
  }) async {
    final layanan = LayananStatusSistem.instance;
    final status = await layanan.cek();
    if (!context.mounted) return false;

    final diblokir = kunciFitur == null
        ? status.aktif
        : status.fiturDiblokir(kunciFitur);
    if (!diblokir) return true;

    if (tampilkanDialog) {
      await _tampilkanDialog(context: context, ref: ref, status: status);
    }
    return false;
  }

  static Future<void> _tampilkanDialog({
    required BuildContext context,
    required WidgetRef ref,
    required StatusMaintenance status,
  }) async {
    if (_dialogTerbuka) return;
    _dialogTerbuka = true;
    try {
      final t = ref.read(teksProvider);
      final bahasa = ref.read(penyediaBahasa);
      final pesan = _gabungkanPesan(status, t, bahasa);
      await DialogAplikasi.tampilkanAlert<void>(
        context: context,
        judul: status.judul?.isNotEmpty == true
            ? status.judul!
            : t.maintenanceJudul,
        pesan: pesan,
        nada: NadaDialog.info,
        dapatDitutup: false,
        aksi: [
          AksiDialog(
            label: t.tutup,
            onTekan: () =>
                Navigator.of(context, rootNavigator: true).pop(),
          ),
          AksiDialog(
            label: t.cobaLagi,
            utama: true,
            onTekan: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await LayananStatusSistem.instance.cek(paksaUlang: true);
            },
          ),
        ],
      );
    } finally {
      _dialogTerbuka = false;
    }
  }

  static String _gabungkanPesan(
    StatusMaintenance status,
    Teks t,
    KodeBahasa bahasa,
  ) {
    final buf = StringBuffer();
    final inti = status.pesan?.isNotEmpty == true
        ? status.pesan!
        : t.maintenancePesanSingkat;
    buf.write(inti);
    final estimasi = status.estimasiSelesai;
    if (estimasi != null) {
      buf.write('\n\n');
      buf.write(t.estimasiSelesai(_formatTanggal(estimasi, bahasa)));
    }
    final kontak = status.kontakDukungan;
    if (kontak != null && kontak.isNotEmpty) {
      buf.write('\n');
      buf.write(t.kontakLayanan(kontak));
    }
    return buf.toString();
  }

  static String _formatTanggal(DateTime tanggal, KodeBahasa bahasa) {
    final lokal = bahasa == KodeBahasa.en ? 'en_US' : 'id_ID';
    return DateFormat('d MMMM yyyy, HH:mm', lokal).format(tanggal.toLocal());
  }
}
