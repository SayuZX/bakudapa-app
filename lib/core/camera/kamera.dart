import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';

enum ArahKamera { depan, belakang }

class LayananKamera {
  LayananKamera._();
  static final LayananKamera instance = LayananKamera._();

  List<CameraDescription>? _daftar;

  Future<List<CameraDescription>> daftar() async {
    _daftar ??= await availableCameras();
    return _daftar!;
  }

  static ImageFormatGroup get formatDeteksiWajah =>
      Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888;

  Future<CameraController?> buat({
    required ArahKamera arah,
    ResolutionPreset resolusi = ResolutionPreset.high,
    bool aktifkanAudio = false,
    ImageFormatGroup formatGambar = ImageFormatGroup.jpeg,
  }) async {
    final semua = await daftar();
    if (semua.isEmpty) return null;

    final cocok = semua.firstWhere(
      (c) => arah == ArahKamera.depan
          ? c.lensDirection == CameraLensDirection.front
          : c.lensDirection == CameraLensDirection.back,
      orElse: () => semua.first,
    );

    final c = CameraController(
      cocok,
      resolusi,
      enableAudio: aktifkanAudio,
      imageFormatGroup: formatGambar,
    );
    await c.initialize();
    return c;
  }

  Future<void> tutup(CameraController? c) async {
    if (c == null) return;
    try {
      if (c.value.isRecordingVideo) {
        await c.stopVideoRecording();
      }
    } catch (_) {}
    try {
      await c.dispose();
    } catch (_) {}
  }
}
