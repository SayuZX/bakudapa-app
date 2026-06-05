import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dialogs/dialog_aplikasi.dart';
import '../localization/teks.dart';
import 'layanan_kualitas_jaringan.dart';
import 'model_kualitas_jaringan.dart';

enum TingkatKekakuanJaringan { ringan, sedang, ketat }

class PenjagaJaringan {
  PenjagaJaringan._();

  static bool _dialogTerbuka = false;

  static Future<bool> _tampilkanDialogJaringan({
    required BuildContext context,
    required String judul,
    required String pesan,
    required NadaDialog nada,
    required String labelTetapLanjutkan,
    required String labelTutup,
  }) async {
    if (_dialogTerbuka) return false;
    _dialogTerbuka = true;
    bool tetapLanjut = false;
    try {
      await DialogAplikasi.tampilkanAlert<void>(
        context: context,
        judul: judul,
        pesan: pesan,
        nada: nada,
        aksi: [
          AksiDialog(
            label: labelTutup,
            onTekan: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
          AksiDialog(
            label: labelTetapLanjutkan,
            utama: true,
            onTekan: () {
              tetapLanjut = true;
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ],
      );
    } finally {
      _dialogTerbuka = false;
    }
    return tetapLanjut;
  }

  static Future<bool> cekUntukAksi({
    required BuildContext context,
    required WidgetRef ref,
    TingkatKekakuanJaringan kekakuan = TingkatKekakuanJaringan.sedang,
  }) async {
    final t = ref.read(teksProvider);
    final layanan = LayananKualitasJaringan.instance;
    final hasil = await layanan.cek();
    if (!context.mounted) return false;

    final bolehLanjut = _evaluasi(hasil, kekakuan);
    if (bolehLanjut) return true;

    final (judul, pesan, nada) = _pesanUntukStatus(hasil, kekakuan, t);
    return _tampilkanDialogJaringan(
      context: context,
      judul: judul,
      pesan: pesan,
      nada: nada,
      labelTetapLanjutkan: t.tetapLanjutkan,
      labelTutup: t.tutup,
    );
  }

  static bool _evaluasi(
    HasilKualitasJaringan hasil,
    TingkatKekakuanJaringan kekakuan,
  ) {
    if (hasil.aktifOffline) return false;
    switch (kekakuan) {
      case TingkatKekakuanJaringan.ringan:
        return !hasil.aktifOffline;
      case TingkatKekakuanJaringan.sedang:
        return hasil.aktifBaik;
      case TingkatKekakuanJaringan.ketat:
        return hasil.bolehUploadBesar;
    }
  }

  static (String, String, NadaDialog) _pesanUntukStatus(
    HasilKualitasJaringan hasil,
    TingkatKekakuanJaringan kekakuan,
    Teks t,
  ) {
    switch (hasil.status) {
      case StatusKualitasJaringan.offline:
        return (
          t.jaringanTidakAdaJudul,
          t.jaringanTidakAdaPesan,
          NadaDialog.bahaya,
        );
      case StatusKualitasJaringan.serverTakTerjangkau:
        return (
          t.jaringanServerTakTerjangkauJudul,
          t.jaringanServerTakTerjangkauPesan,
          NadaDialog.peringatan,
        );
      case StatusKualitasJaringan.tidakStabil:
      case StatusKualitasJaringan.batasWaktu:
        return (
          t.jaringanTidakStabilJudul,
          t.jaringanTidakStabilPesan,
          NadaDialog.peringatan,
        );
      case StatusKualitasJaringan.sedang:
        if (kekakuan == TingkatKekakuanJaringan.ketat) {
          return (
            t.jaringanLambatUntukUploadJudul,
            t.jaringanLambatUntukUploadPesan,
            NadaDialog.peringatan,
          );
        }
        return (
          t.jaringanTidakStabilJudul,
          t.jaringanTidakStabilPesan,
          NadaDialog.peringatan,
        );
      case StatusKualitasJaringan.stabil:
      case StatusKualitasJaringan.belumDicek:
      case StatusKualitasJaringan.memeriksa:
        return (
          t.jaringanTidakStabilJudul,
          t.jaringanTidakStabilPesan,
          NadaDialog.peringatan,
        );
    }
  }
}
