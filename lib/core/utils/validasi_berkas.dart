import 'dart:io';
import 'package:mime/mime.dart';

import '../config/limits.dart';
import '../errors/kesalahan.dart';

class ValidasiBerkas {
  const ValidasiBerkas._();

  static Future<void> periksa(
    File berkas, {
    int? maksByte,
    List<String> mimeIzin = const [],
  }) async {
    final ada = await berkas.exists();
    if (!ada) {
      throw const KesalahanUnggah('Berkas tidak ditemukan.');
    }

    final ukuran = await berkas.length();
    final batas = (maksByte != null && maksByte > 0)
        ? maksByte
        : UploadLimits.dokumenPermohonanMaxByte;
    final maksimumMb = batas ~/ (1024 * 1024);
    if (ukuran <= 0) {
      throw const KesalahanUnggah('Berkas kosong tidak diizinkan.');
    }
    if (ukuran > batas) {
      throw KesalahanUnggah(
        'Ukuran berkas melebihi ${maksimumMb}MB.',
      );
    }

    final mimeHeader = await _intipMimeDariHeader(berkas);
    final mimeNama = lookupMimeType(berkas.path);
    final mime = mimeHeader ?? mimeNama;

    if (mime == null) {
      throw const KesalahanUnggah('Tipe berkas tidak dikenali.');
    }
    final tipeMimeIzin = mimeIzin.isNotEmpty
        ? mimeIzin
        : const [
            ...UploadLimits.fotoMimeTypes,
            ...UploadLimits.dokumenMimeTypes,
          ];
    if (!tipeMimeIzin.contains(mime)) {
      throw const KesalahanUnggah(
        'Format tidak diizinkan. Gunakan JPG, PNG, atau PDF.',
      );
    }
    if (mimeNama == 'application/pdf' && mimeHeader != null && mimeHeader != 'application/pdf') {
      throw const KesalahanUnggah('Berkas PDF tidak valid.');
    }
  }

  static Future<String?> _intipMimeDariHeader(File berkas) async {
    try {
      final raf = await berkas.open();
      try {
        final byte = await raf.read(12);
        return lookupMimeType(berkas.path, headerBytes: byte);
      } finally {
        await raf.close();
      }
    } catch (_) {
      return null;
    }
  }

  static String formatByte(int byte) {
    if (byte < 1024) return '$byte B';
    if (byte < 1024 * 1024) return '${(byte / 1024).toStringAsFixed(1)} KB';
    return '${(byte / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
