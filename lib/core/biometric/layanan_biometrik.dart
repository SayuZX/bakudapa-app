import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

import 'model_hasil_biometrik.dart';

class LayananBiometrik {
  LayananBiometrik._();
  static final LayananBiometrik instance = LayananBiometrik._();

  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> punyaSensor() async {
    try {
      final didukung = await _auth.isDeviceSupported();
      if (!didukung) return false;
      final dapat = await _auth.canCheckBiometrics;
      return dapat;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> jenisYangTersedia() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return const [];
    }
  }

  Future<bool> tersediaSidikJari() async {
    final jenis = await jenisYangTersedia();
    return jenis.contains(BiometricType.fingerprint) ||
        jenis.contains(BiometricType.strong);
  }

  Future<HasilBiometrikSidikJari> verifikasi({
    String pesanLokal =
        'Tempelkan jari Anda pada sensor untuk verifikasi registrasi BAKUDAPA MOBILE.',
  }) async {
    final mulai = DateTime.now();
    try {
      final didukung = await _auth.isDeviceSupported();
      if (!didukung) {
        return const HasilBiometrikSidikJari(
          status: StatusBiometrik.tidakDidukung,
          tipeBiometrik: 'fingerprint',
        );
      }
      final tersedia = await _auth.canCheckBiometrics;
      if (!tersedia) {
        return const HasilBiometrikSidikJari(
          status: StatusBiometrik.tidakDidukung,
          tipeBiometrik: 'fingerprint',
        );
      }
      final daftarJenis = await _auth.getAvailableBiometrics();
      if (daftarJenis.isEmpty) {
        return const HasilBiometrikSidikJari(
          status: StatusBiometrik.belumTerdaftar,
          tipeBiometrik: 'fingerprint',
        );
      }

      final sukses = await _auth.authenticate(
        localizedReason: pesanLokal,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      if (sukses) {
        return HasilBiometrikSidikJari(
          status: StatusBiometrik.diverifikasi,
          diverifikasiPada: DateTime.now(),
          tipeBiometrik: 'fingerprint',
        );
      }
      return HasilBiometrikSidikJari(
        status: StatusBiometrik.gagal,
        diverifikasiPada: DateTime.now(),
        tipeBiometrik: 'fingerprint',
        alasan: 'Verifikasi tidak selesai.',
      );
    } on PlatformException catch (e) {
      return HasilBiometrikSidikJari(
        status: _statusDariKode(e.code),
        diverifikasiPada: mulai,
        tipeBiometrik: 'fingerprint',
        alasan: _pesanRamah(e.code),
      );
    } catch (_) {
      return HasilBiometrikSidikJari(
        status: StatusBiometrik.gagal,
        diverifikasiPada: mulai,
        tipeBiometrik: 'fingerprint',
      );
    }
  }

  StatusBiometrik _statusDariKode(String kode) {
    switch (kode) {
      case auth_error.notAvailable:
      case auth_error.passcodeNotSet:
        return StatusBiometrik.tidakDidukung;
      case auth_error.notEnrolled:
        return StatusBiometrik.belumTerdaftar;
      case 'auth_in_progress':
      case 'UserCancel':
      case 'UserCanceled':
        return StatusBiometrik.ditolakPengguna;
      case auth_error.lockedOut:
      case auth_error.permanentlyLockedOut:
        return StatusBiometrik.gagal;
      default:
        return StatusBiometrik.gagal;
    }
  }

  String _pesanRamah(String kode) {
    switch (kode) {
      case auth_error.notAvailable:
        return 'Perangkat ini tidak mendukung verifikasi sidik jari.';
      case auth_error.passcodeNotSet:
        return 'Aktifkan kunci layar pada perangkat Anda terlebih dahulu.';
      case auth_error.notEnrolled:
        return 'Belum ada sidik jari yang terdaftar di perangkat.';
      case auth_error.lockedOut:
        return 'Sensor terkunci sementara. Tunggu beberapa saat lalu coba lagi.';
      case auth_error.permanentlyLockedOut:
        return 'Sensor terkunci permanen. Buka kunci dengan PIN/pola perangkat.';
      default:
        return 'Verifikasi belum berhasil.';
    }
  }

  Map<String, Object?> metadataPerangkat() {
    return {
      'platform': Platform.operatingSystem,
      'os_version': Platform.operatingSystemVersion,
      'is_physical': true,
    };
  }
}
