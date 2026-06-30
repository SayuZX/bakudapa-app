import 'dart:math';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class HasilDeteksiWajah {
  const HasilDeteksiWajah({
    required this.ada,
    this.pusatRelatif = const ui.Offset(0, 0),
    this.bukaMataKiri,
    this.bukaMataKanan,
    this.senyum,
    this.sudutY,
    this.sudutX,
    this.sudutZ,
    this.boundingBox,
    this.ukuranGambar,
    this.bukaMulutNormal,
    this.luminansi,
    this.jumlahWajah = 0,
  });

  final bool ada;
  final ui.Offset pusatRelatif;
  final double? bukaMataKiri;
  final double? bukaMataKanan;
  final double? senyum;
  final double? sudutY;
  final double? sudutX;
  final double? sudutZ;
  final ui.Rect? boundingBox;
  final ui.Size? ukuranGambar;
  final double? bukaMulutNormal;
  final double? luminansi;
  final int jumlahWajah;

  static const tidakAda = HasilDeteksiWajah(ada: false);
}

class LayananDeteksiWajah {
  LayananDeteksiWajah._();
  static final LayananDeteksiWajah instance = LayananDeteksiWajah._();

  FaceDetector? _detektor;

  FaceDetector get _deteksi => _detektor ??= FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.fast,
          enableLandmarks: false,
          enableContours: true,
          enableClassification: true,
          enableTracking: false,
          minFaceSize: 0.12,
        ),
      );

  bool _sedangProses = false;

  Future<HasilDeteksiWajah?> prosesFrame(
    CameraImage gambar,
    CameraDescription kamera,
  ) async {
    if (_sedangProses) return null;
    _sedangProses = true;
    try {
      final lum = _luminansiRata(gambar);
      final input = _konversi(gambar, kamera);
      if (input == null) return HasilDeteksiWajah(ada: false, luminansi: lum);
      final wajah = await _deteksi.processImage(input);
      if (wajah.isEmpty) return HasilDeteksiWajah(ada: false, luminansi: lum);

      final terbesar = wajah.reduce((a, b) =>
          a.boundingBox.width * a.boundingBox.height >
                  b.boundingBox.width * b.boundingBox.height
              ? a
              : b);
      final box = terbesar.boundingBox;
      final ukuran = ui.Size(gambar.width.toDouble(), gambar.height.toDouble());

      var pusatX = (box.left + box.right) / 2 / ukuran.width;
      var pusatY = (box.top + box.bottom) / 2 / ukuran.height;

      pusatX = pusatX.clamp(0.0, 1.0);
      pusatY = pusatY.clamp(0.0, 1.0);

      var dxFromCenter = (pusatX - 0.5) * 2;
      var dyFromCenter = (pusatY - 0.5) * 2;

      double? yaw = terbesar.headEulerAngleY;
      if (kamera.lensDirection == CameraLensDirection.front) {
        dxFromCenter = -dxFromCenter;
        if (yaw != null) yaw = -yaw;
      }

      final bukaMulut = _hitungBukaMulut(terbesar, box.height);

      return HasilDeteksiWajah(
        ada: true,
        pusatRelatif: ui.Offset(dxFromCenter, dyFromCenter),
        bukaMataKiri: terbesar.leftEyeOpenProbability,
        bukaMataKanan: terbesar.rightEyeOpenProbability,
        senyum: terbesar.smilingProbability,
        sudutY: yaw,
        sudutX: terbesar.headEulerAngleX,
        sudutZ: terbesar.headEulerAngleZ,
        boundingBox: box,
        ukuranGambar: ukuran,
        bukaMulutNormal: bukaMulut,
        luminansi: lum,
        jumlahWajah: wajah.length,
      );
    } catch (_) {
      return HasilDeteksiWajah.tidakAda;
    } finally {
      _sedangProses = false;
    }
  }

  double? _luminansiRata(CameraImage gambar) {
    try {
      final y = gambar.planes.first.bytes;
      final maks = gambar.width * gambar.height;
      final batas = maks < y.length ? maks : y.length;
      if (batas <= 0) return null;
      var total = 0;
      var n = 0;
      for (var i = 0; i < batas; i += 17) {
        total += y[i];
        n++;
      }
      return n == 0 ? null : total / n;
    } catch (_) {
      return null;
    }
  }

  double? _hitungBukaMulut(Face wajah, double tinggiWajah) {
    if (tinggiWajah <= 0) return null;
    final bibirAtas = wajah.contours[FaceContourType.upperLipBottom];
    final bibirBawah = wajah.contours[FaceContourType.lowerLipTop];
    if (bibirAtas == null || bibirBawah == null) return null;
    if (bibirAtas.points.isEmpty || bibirBawah.points.isEmpty) return null;

    final yAtas = _rataY(bibirAtas.points);
    final yBawah = _rataY(bibirBawah.points);
    final jarak = (yBawah - yAtas).abs();
    return (jarak / tinggiWajah).clamp(0.0, 1.0);
  }

  double _rataY(List<Point<int>> titik) {
    var total = 0.0;
    for (final p in titik) {
      total += p.y;
    }
    return total / titik.length;
  }

  InputImage? _konversi(CameraImage gambar, CameraDescription kamera) {
    try {
      final group = gambar.format.group;
      final InputImageFormat format;
      if (group == ImageFormatGroup.nv21) {
        format = InputImageFormat.nv21;
      } else if (group == ImageFormatGroup.bgra8888) {
        format = InputImageFormat.bgra8888;
      } else {
        return null;
      }
      final plane = gambar.planes.first;
      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: ui.Size(gambar.width.toDouble(), gambar.height.toDouble()),
          rotation: _rotasi(kamera),
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  InputImageRotation _rotasi(CameraDescription kamera) {
    final sensor = kamera.sensorOrientation;
    switch (sensor) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation90deg;
    }
  }

  Future<void> buang() async {
    final d = _detektor;
    _detektor = null;
    await d?.close();
  }
}
