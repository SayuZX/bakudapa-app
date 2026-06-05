import 'package:flutter/material.dart';

import '../dialogs/dialog_aplikasi.dart';

extension EkstensiKonteks on BuildContext {
  ThemeData get tema => Theme.of(this);
  ColorScheme get warna => tema.colorScheme;
  TextTheme get teks => tema.textTheme;
  MediaQueryData get mq => MediaQuery.of(this);
  Size get ukuran => mq.size;
  EdgeInsets get aman => mq.padding;
  bool get layarKecil => ukuran.width < 360;

  void tampilkanPesan(String pesan, {bool galat = false}) {
    DialogAplikasi.tampilkanToast(
      this,
      pesan,
      nada: galat ? NadaDialog.bahaya : NadaDialog.sukses,
    );
  }

  void tampilkanSukses(String pesan) {
    DialogAplikasi.tampilkanToast(this, pesan, nada: NadaDialog.sukses);
  }

  void tampilkanGalat(String pesan) {
    DialogAplikasi.tampilkanToast(this, pesan, nada: NadaDialog.bahaya);
  }

  void tampilkanInfo(String pesan) {
    DialogAplikasi.tampilkanToast(this, pesan, nada: NadaDialog.info);
  }
}
