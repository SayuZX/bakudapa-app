import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/ai/data/repositori_ai_chat_api.dart';
import '../../features/ai/domain/repositori_ai_chat.dart';
import '../../features/applications/data/repositori_permohonan_api.dart';
import '../../features/applications/domain/repositori_permohonan.dart';
import '../../features/auth/data/repositori_otentikasi_api.dart';
import '../../features/auth/domain/repositori_otentikasi.dart';
import '../../features/help/data/repositori_kebijakan.dart';
import '../../features/notifications/data/repositori_pemberitahuan.dart';
import '../../features/perangkat/data/repositori_perangkat_api.dart';
import '../../features/perangkat/domain/repositori_perangkat.dart';
import '../../features/registration/data/repositori_registrasi.dart';
import '../../features/settings/data/repositori_profil.dart';
import '../../features/wilayah/data/repositori_wilayah.dart';

final penyediaRepositoriOtentikasi =
    Provider<RepositoriOtentikasi>((ref) => RepositoriOtentikasiApi());

final penyediaRepositoriPermohonan =
    Provider<RepositoriPermohonan>((ref) => RepositoriPermohonanApi());

final penyediaRepositoriPemberitahuan =
    Provider<RepositoriPemberitahuan>((ref) => RepositoriPemberitahuanApi());

final penyediaRepositoriPerangkat =
    Provider<RepositoriPerangkat>((ref) => RepositoriPerangkatApi());

final penyediaRepositoriWilayah =
    Provider<RepositoriWilayah>((ref) => RepositoriWilayahApi());

final penyediaRepositoriRegistrasi =
    Provider<RepositoriRegistrasi>((ref) => RepositoriRegistrasiApi());

final penyediaRepositoriAiChat =
    Provider<RepositoriAiChat>((ref) => RepositoriAiChatApi());

final penyediaRepositoriProfil =
    Provider<RepositoriProfil>((ref) => RepositoriProfilApi());

final penyediaRepositoriKebijakan =
    Provider<RepositoriKebijakan>((ref) => RepositoriKebijakanApi());
