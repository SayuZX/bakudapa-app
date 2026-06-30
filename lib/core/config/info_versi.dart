import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class InfoVersi {
  InfoVersi._();

  static const String _tanggalBuild =
      String.fromEnvironment('TANGGAL_BUILD', defaultValue: '');

  static String? _ringkas;

  static Future<String> ringkas() async {
    final tersimpan = _ringkas;
    if (tersimpan != null) return tersimpan;

    var versi = '0.0.0';
    var build = '0';
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) versi = info.version;
      if (info.buildNumber.isNotEmpty) build = info.buildNumber;
    } catch (_) {}

    final deret = _tanggalBuild.isEmpty
        ? '$versi.$build'
        : '$versi.$build.$_tanggalBuild';
    final hasil = '$deret · ${_kode('$versi+$build')}';
    _ringkas = hasil;
    return hasil;
  }

  static String _kode(String benih) {
    var h = 2166136261;
    for (final unit in benih.codeUnits) {
      h ^= unit;
      h = (h * 16777619) & 0xffffffff;
    }
    const abjad = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final sb = StringBuffer();
    for (var i = 0; i < 4; i++) {
      sb.write(abjad[h % abjad.length]);
      h ~/= abjad.length;
    }
    return sb.toString();
  }
}

final penyediaVersiAplikasi =
    FutureProvider<String>((ref) => InfoVersi.ringkas());
