import 'dart:async';
import 'dart:math';

import 'package:record/record.dart';

import '../storage/berkas_sementara.dart';

class PerekamSuara {
  PerekamSuara._();
  static final PerekamSuara instance = PerekamSuara._();

  final AudioRecorder _rekam = AudioRecorder();
  StreamSubscription<Amplitude>? _langgan;
  String? _jalurAktif;

  bool get sedangMerekam => _jalurAktif != null;

  Future<bool> izinDiberikan() => _rekam.hasPermission();

  Future<void> mulai({void Function(double level)? onAmplitudo}) async {
    final dapat = await _rekam.hasPermission();
    if (!dapat) {
      throw StateError('Izin mikrofon belum diberikan.');
    }
    final jalur = await BerkasSementara.instance.jalurBaru('suara');
    final fixed = '$jalur.m4a';
    await _rekam.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
        numChannels: 1,
      ),
      path: fixed,
    );
    _jalurAktif = fixed;
    if (onAmplitudo != null) {
      _langgan = _rekam
          .onAmplitudeChanged(const Duration(milliseconds: 120))
          .listen((a) {
        final db = a.current;
        final dinorm = ((db + 45) / 45).clamp(0.0, 1.0);
        onAmplitudo(dinorm);
      });
    }
  }

  Future<String?> selesai() async {
    final hasil = await _rekam.stop();
    await _langgan?.cancel();
    _langgan = null;
    _jalurAktif = null;
    return hasil;
  }

  Future<void> batal() async {
    try {
      await _rekam.stop();
    } catch (_) {}
    await _langgan?.cancel();
    _langgan = null;
    final j = _jalurAktif;
    _jalurAktif = null;
    if (j != null) await BerkasSementara.instance.hapus(j);
  }

  void buang() {
    _langgan?.cancel();
    _langgan = null;
    _rekam.dispose();
  }
}

class LayananTantanganSuara {
  LayananTantanganSuara._();
  static final LayananTantanganSuara instance = LayananTantanganSuara._();

  static const List<String> _kalimat = [
    'Saya mendaftar di BAKUDAPA MOBILE untuk layanan administrasi kependudukan Provinsi Maluku Utara.',
    'Saya warga Maluku Utara dan mendaftar layanan BAKUDAPA dengan data benar dan sah.',
    'Saya menggunakan BAKUDAPA MOBILE untuk mengakses layanan Dinas Kependudukan dan Pencatatan Sipil.',
  ];

  String acakKalimat({int? benih}) {
    final rng = benih != null ? Random(benih) : Random.secure();
    return _kalimat[rng.nextInt(_kalimat.length)];
  }

  String kodeTantangan({int? benih}) {
    final rng = benih != null ? Random(benih) : Random.secure();
    final empat = (rng.nextInt(9000) + 1000).toString();
    return 'BAKUDAPA $empat Maluku Utara';
  }
}
