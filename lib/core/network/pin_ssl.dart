import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../config/lingkungan.dart';

class PinSsl {
  PinSsl._();

  static const List<String> _pinnedFingerprints = [
    'EXPECTED_SHA256_FINGERPRINT_HERE',
  ];

  static bool get aktif =>
      KonfigurasiLingkungan.pinningAktif &&
      KonfigurasiLingkungan.baseUrl.startsWith('https');

  static void pasang(Dio dio) {
    if (!aktif) return;
    
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        // Jangan gunakan custom SecurityContext dengan Root CA Let's Encrypt,
        // biarkan OS memvalidasi rantai sertifikat (default).
        final klien = HttpClient();
        
        klien.badCertificateCallback = (X509Certificate cert, String host, int port) {
          // Jika SSL bawaan OS gagal, kembalikan false.
          return false;
        };
        return klien;
      },
      validateCertificate: (X509Certificate? cert, String host, int port) {
        if (cert == null) return false;
        
        // Hanya lakukan pinning pada domain production.
        if (host != 'bakudapa.malutprov.go.id') {
           return true; 
        }

        // Ekstraksi SHA-256 fingerprint dari sertifikat
        final certHash = sha256.convert(cert.der).toString().toLowerCase();
        
        for (final pin in _pinnedFingerprints) {
          final cleanPin = pin.replaceAll(':', '').toLowerCase();
          if (certHash == cleanPin) {
            return true;
          }
        }
        
        // Jika tidak ada fingerprint yang cocok, tolak koneksi.
        return false;
      },
    );
  }
}
