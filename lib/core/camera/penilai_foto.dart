import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

enum AlasanGagalFoto { ok, terlaluGelap, terlaluTerang, buram, tidakTerbaca }

class HasilPenilaianFoto {
  const HasilPenilaianFoto({
    required this.alasan,
    required this.luminansiRata,
    required this.varianTepi,
  });

  final AlasanGagalFoto alasan;
  final double luminansiRata;
  final double varianTepi;

  bool get layak => alasan == AlasanGagalFoto.ok;

  String get pesan {
    switch (alasan) {
      case AlasanGagalFoto.terlaluGelap:
        return 'Pencahayaan kurang. Cari tempat yang lebih terang.';
      case AlasanGagalFoto.terlaluTerang:
        return 'Pencahayaan terlalu terang. Hindari cahaya langsung di belakang Anda.';
      case AlasanGagalFoto.buram:
        return 'Foto terlihat buram. Tahan kamera lebih stabil, lalu coba lagi.';
      case AlasanGagalFoto.tidakTerbaca:
        return 'Foto tidak dapat diperiksa. Silakan ulangi.';
      case AlasanGagalFoto.ok:
        return '';
    }
  }
}

class PenilaiFoto {
  PenilaiFoto._();
  static final PenilaiFoto instance = PenilaiFoto._();

  // Ambang dilonggarkan untuk mengurangi false positive.
  // Hanya tolak yang sangat gelap / sangat over-exposure / sangat buram.
  static const double _ambangGelap = 38;
  static const double _ambangTerang = 245;
  static const double _ambangVarianMinimum = 18;
  static const int _lebarTarget = 360;

  Future<HasilPenilaianFoto> nilai(String jalur) async {
    try {
      final bytes = await File(jalur).readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: _lebarTarget,
      );
      final frame = await codec.getNextFrame();
      final img = frame.image;
      final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      img.dispose();

      if (byteData == null) {
        return const HasilPenilaianFoto(
          alasan: AlasanGagalFoto.tidakTerbaca,
          luminansiRata: 0,
          varianTepi: 0,
        );
      }

      final pixels = byteData.buffer.asUint8List();
      final lebar = img.width;
      final tinggi = img.height;

      final luminansi = _hitungLuminansi(pixels, lebar, tinggi);
      final luminansiRata = _rataLuminansi(luminansi);

      if (luminansiRata < _ambangGelap) {
        return HasilPenilaianFoto(
          alasan: AlasanGagalFoto.terlaluGelap,
          luminansiRata: luminansiRata,
          varianTepi: 0,
        );
      }
      if (luminansiRata > _ambangTerang) {
        return HasilPenilaianFoto(
          alasan: AlasanGagalFoto.terlaluTerang,
          luminansiRata: luminansiRata,
          varianTepi: 0,
        );
      }

      final varianTepi = _varianLaplacian(luminansi, lebar, tinggi);
      if (varianTepi < _ambangVarianMinimum) {
        return HasilPenilaianFoto(
          alasan: AlasanGagalFoto.buram,
          luminansiRata: luminansiRata,
          varianTepi: varianTepi,
        );
      }

      return HasilPenilaianFoto(
        alasan: AlasanGagalFoto.ok,
        luminansiRata: luminansiRata,
        varianTepi: varianTepi,
      );
    } catch (_) {
      return const HasilPenilaianFoto(
        alasan: AlasanGagalFoto.tidakTerbaca,
        luminansiRata: 0,
        varianTepi: 0,
      );
    }
  }

  Float32List _hitungLuminansi(Uint8List pixels, int lebar, int tinggi) {
    final lum = Float32List(lebar * tinggi);
    for (var i = 0, p = 0; i < pixels.length; i += 4, p++) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];
      lum[p] = 0.299 * r + 0.587 * g + 0.114 * b;
    }
    return lum;
  }

  double _rataLuminansi(Float32List lum) {
    if (lum.isEmpty) return 0;
    double s = 0;
    for (var i = 0; i < lum.length; i++) {
      s += lum[i];
    }
    return s / lum.length;
  }

  double _varianLaplacian(Float32List lum, int lebar, int tinggi) {
    if (lebar < 4 || tinggi < 4) return 0;
    double jumlah = 0;
    int n = 0;
    final laplas = <double>[];
    for (var y = 1; y < tinggi - 1; y += 2) {
      for (var x = 1; x < lebar - 1; x += 2) {
        final c = lum[y * lebar + x];
        final u = lum[(y - 1) * lebar + x];
        final d = lum[(y + 1) * lebar + x];
        final l = lum[y * lebar + x - 1];
        final r = lum[y * lebar + x + 1];
        final v = 4 * c - u - d - l - r;
        laplas.add(v);
        jumlah += v;
        n++;
      }
    }
    if (n == 0) return 0;
    final rata = jumlah / n;
    double varSum = 0;
    for (final v in laplas) {
      final d = v - rata;
      varSum += d * d;
    }
    return varSum / n;
  }
}
