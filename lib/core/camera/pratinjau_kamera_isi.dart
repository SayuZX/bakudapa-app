import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

enum ModePratinjauKamera { cover, fokusWajah }

class PratinjauKameraIsi extends StatelessWidget {
  const PratinjauKameraIsi({
    super.key,
    required this.kontroler,
    this.mode = ModePratinjauKamera.cover,
  });

  final CameraController kontroler;
  final ModePratinjauKamera mode;

  @override
  Widget build(BuildContext context) {
    if (!kontroler.value.isInitialized) {
      return const ColoredBox(color: Color(0xFF14171F));
    }
    final preview = kontroler.value.previewSize;
    if (preview == null) {
      return Center(child: CameraPreview(kontroler));
    }
    final lebarPotret = preview.height;
    final tinggiPotret = preview.width;

    switch (mode) {
      case ModePratinjauKamera.cover:
        return ClipRect(
          child: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.center,
              child: SizedBox(
                width: lebarPotret,
                height: tinggiPotret,
                child: CameraPreview(kontroler),
              ),
            ),
          ),
        );
      case ModePratinjauKamera.fokusWajah:
        return LayoutBuilder(
          builder: (context, c) {
            final lebarKontainer = c.maxWidth;
            final tinggiKontainer = c.maxHeight;
            final rasioKamera = lebarPotret / tinggiPotret;
            final lebarTampil = lebarKontainer;
            final tinggiTampil = lebarKontainer / rasioKamera;
            return ClipRect(
              child: SizedBox(
                width: lebarKontainer,
                height: tinggiKontainer,
                child: OverflowBox(
                  minWidth: lebarTampil,
                  maxWidth: lebarTampil,
                  minHeight: tinggiTampil,
                  maxHeight: tinggiTampil,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: lebarTampil,
                    height: tinggiTampil,
                    child: CameraPreview(kontroler),
                  ),
                ),
              ),
            );
          },
        );
    }
  }
}
