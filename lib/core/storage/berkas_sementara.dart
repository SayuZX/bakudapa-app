import 'dart:io';

import 'package:path_provider/path_provider.dart';

class BerkasSementara {
  BerkasSementara._();
  static final BerkasSementara instance = BerkasSementara._();

  Future<Directory> _direktori() async {
    final tmp = await getTemporaryDirectory();
    final folder = Directory('${tmp.path}/bakudapa_reg');
    if (!folder.existsSync()) {
      await folder.create(recursive: true);
    }
    return folder;
  }

  Future<String> jalurBaru(String namaDasar) async {
    final dir = await _direktori();
    final waktu = DateTime.now().millisecondsSinceEpoch;
    return '${dir.path}/${namaDasar}_$waktu';
  }

  Future<void> hapus(String? jalur) async {
    if (jalur == null || jalur.isEmpty) return;
    try {
      final f = File(jalur);
      if (f.existsSync()) await f.delete();
    } catch (_) {}
  }

  Future<void> bersihkan() async {
    try {
      final dir = await _direktori();
      if (dir.existsSync()) {
        await dir.delete(recursive: true);
      }
    } catch (_) {}
  }
}
