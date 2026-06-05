import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/applications/presentation/halaman_detail_permohonan.dart';
import '../../features/applications/presentation/halaman_riwayat.dart';
import '../../features/auth/data/model_otp.dart';
import '../../features/auth/presentation/halaman_lupa_kata_sandi.dart';
import '../../features/auth/presentation/halaman_reset_kata_sandi_baru.dart';
import '../../features/auth/presentation/halaman_masuk.dart';
import '../../features/auth/presentation/halaman_otp.dart';
import '../../features/dashboard/presentation/kerangka_utama.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/help/presentation/halaman_bantuan.dart';
import '../../features/ai/presentation/halaman_ai_chat.dart';
import '../../features/help/presentation/halaman_kebijakan.dart';
import '../../features/maintenance/presentation/halaman_maintenance.dart';
import '../../features/notifications/presentation/halaman_pemberitahuan.dart';
import '../../features/onboarding/presentation/halaman_onboarding.dart';
import '../../features/profile/presentation/halaman_profil.dart';
import '../../features/registration/presentation/pages/halaman_foto_dokumen.dart';
import '../../features/registration/presentation/pages/halaman_foto_wajah.dart';
import '../../features/registration/presentation/pages/halaman_gagal_foto_wajah.dart';
import '../../features/registration/presentation/pages/halaman_identitas.dart';
import '../../features/registration/presentation/pages/halaman_intro_foto_wajah.dart';
import '../../features/registration/presentation/pages/halaman_intro_liveness.dart';
import '../../features/registration/presentation/pages/halaman_kebijakan_registrasi.dart';
import '../../features/registration/presentation/pages/halaman_liveness.dart';
import '../../features/registration/presentation/pages/halaman_persetujuan_sidik_jari.dart';
import '../../features/registration/presentation/pages/halaman_proses_verifikasi_ai.dart';
import '../../features/registration/presentation/pages/halaman_sidik_jari.dart';
import '../../features/registration/presentation/pages/halaman_suara.dart';
import '../../features/registration/presentation/pages/halaman_sukses_registrasi.dart';
import '../../features/services/presentation/halaman_detail_layanan.dart';
import '../../features/services/presentation/halaman_formulir_layanan.dart';
import '../../features/services/presentation/halaman_layanan.dart';
import '../../features/settings/presentation/halaman_pengaturan.dart';
import '../../features/splash/presentation/halaman_splash.dart';
import '../../features/tutorial/presentation/halaman_panduan.dart';
import '../../shared/models/jenis_layanan.dart';
import '../../shared/providers/penyedia_maintenance.dart';
import '../../shared/providers/penyedia_otentikasi.dart';
import '../dialogs/dialog_aplikasi.dart';
import 'nama_rute.dart';

String? _tujuanTertunda;

final penyediaRuteAplikasi = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: DialogAplikasi.kunciNavigatorRoot,
    initialLocation: NamaRute.splash,
    debugLogDiagnostics: false,
    refreshListenable: _Pendengar(ref),
    redirect: (context, state) {
      final otentikasi = ref.read(penyediaOtentikasi);
      final maintenance = ref.read(statusMaintenanceProvider);
      final status = otentikasi.status;
      final lokasi = state.matchedLocation;

      if (maintenance.aktif && lokasi != NamaRute.maintenance) {
        return NamaRute.maintenance;
      }
      if (!maintenance.aktif && lokasi == NamaRute.maintenance) {
        return NamaRute.splash;
      }

      final rutePublikHanyaAnonim = {
        NamaRute.onboarding,
        NamaRute.masuk,
        NamaRute.daftar,
        NamaRute.otp,
        NamaRute.lupaKataSandi,
        NamaRute.resetKataSandiBaru,
      };
      const prefixHanyaAnonim = ['/daftar'];
      const prefixBebas = [
        '/kebijakan-',
        '/syarat-',
        '/penafian-',
        '/pernyataan-',
      ];
      final hanyaAnonim = rutePublikHanyaAnonim.contains(lokasi) ||
          prefixHanyaAnonim.any((p) => lokasi.startsWith(p));
      final bebas = prefixBebas.any((p) => lokasi.startsWith(p));

      if (status == StatusOtentikasi.memuat ||
          otentikasi.terblokirOlehKeamanan) {
        if (lokasi != NamaRute.splash && !hanyaAnonim && !bebas) {
          _tujuanTertunda = lokasi;
        }
        return lokasi == NamaRute.splash ? null : NamaRute.splash;
      }

      if (status == StatusOtentikasi.belumMasuk) {
        if (hanyaAnonim || bebas) return null;
        return NamaRute.masuk;
      }
      if (bebas) return null;
      if (hanyaAnonim || lokasi == NamaRute.splash) {
        final tertunda = _tujuanTertunda;
        _tujuanTertunda = null;
        if (tertunda != null && tertunda != NamaRute.splash) return tertunda;
        return NamaRute.beranda;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: NamaRute.splash,
        builder: (_, _) => const HalamanSplash(),
      ),
      GoRoute(
        path: NamaRute.maintenance,
        builder: (_, _) => const HalamanMaintenance(),
      ),
      GoRoute(
        path: NamaRute.onboarding,
        builder: (_, _) => const HalamanOnboarding(),
      ),
      GoRoute(
        path: NamaRute.masuk,
        builder: (_, _) => const HalamanMasuk(),
      ),
      GoRoute(
        path: NamaRute.daftar,
        builder: (_, _) => const HalamanIdentitasRegistrasi(),
      ),
      GoRoute(
        path: NamaRute.daftarFotoDokumen,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanFotoDokumen(),
      ),
      GoRoute(
        path: NamaRute.daftarFotoWajah,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanIntroFotoWajah(),
      ),
      GoRoute(
        path: NamaRute.daftarKameraFotoWajah,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanFotoWajah(),
      ),
      GoRoute(
        path: NamaRute.daftarGagalFotoWajah,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, state) {
          final alasan = state.extra is String ? state.extra! as String : null;
          return HalamanGagalFotoWajah(alasanTerakhir: alasan);
        },
      ),
      GoRoute(
        path: NamaRute.daftarLiveness,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanIntroLiveness(),
      ),
      GoRoute(
        path: NamaRute.daftarKameraLiveness,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanLiveness(),
      ),
      GoRoute(
        path: NamaRute.daftarSuara,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanSuara(),
      ),
      GoRoute(
        path: NamaRute.daftarPersetujuanSidikJari,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanPersetujuanSidikJari(),
      ),
      GoRoute(
        path: NamaRute.daftarSidikJari,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanSidikJari(),
      ),
      GoRoute(
        path: NamaRute.daftarSukses,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanSuksesRegistrasi(),
      ),
      GoRoute(
        path: NamaRute.daftarKebijakan,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanKebijakanRegistrasi(),
      ),
      GoRoute(
        path: NamaRute.daftarProsesVerifikasi,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanProsesVerifikasiAi(),
      ),
      GoRoute(
        path: NamaRute.otp,
        builder: (_, state) {
          final ekstra = state.extra;
          if (ekstra is Map<String, Object?>) {
            return HalamanOtp(
              identitas: ekstra['identitas']?.toString() ?? '',
              tipe: ekstra['tipe'] is TipeOtp
                  ? ekstra['tipe']! as TipeOtp
                  : TipeOtp.login,
            );
          }
          final identitas = ekstra is String ? ekstra : '';
          return HalamanOtp(identitas: identitas);
        },
      ),
      GoRoute(
        path: NamaRute.lupaKataSandi,
        builder: (_, _) => const HalamanLupaKataSandi(),
      ),
      GoRoute(
        path: NamaRute.resetKataSandiBaru,
        builder: (_, state) => HalamanResetKataSandiBaru(
          tokenReset: state.extra is String ? state.extra as String : '',
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            KerangkaUtama(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: NamaRute.beranda,
                pageBuilder: (_, _) =>
                    const NoTransitionPage(child: HomePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: NamaRute.riwayat,
                pageBuilder: (_, _) =>
                    const NoTransitionPage(child: HalamanRiwayat()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: NamaRute.asistenAi,
                pageBuilder: (_, _) =>
                    const NoTransitionPage(child: HalamanAiChat()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: NamaRute.pemberitahuan,
                pageBuilder: (_, _) =>
                    const NoTransitionPage(child: HalamanPemberitahuan()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: NamaRute.profil,
                pageBuilder: (_, _) =>
                    const NoTransitionPage(child: HalamanProfil()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: NamaRute.layanan,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanLayanan(),
      ),
      GoRoute(
        path: '${NamaRute.detailLayanan}/:kode',
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, state) {
          final kode = state.pathParameters['kode'] ?? '';
          return HalamanDetailLayanan(jenis: JenisLayanan.dariKode(kode));
        },
      ),
      GoRoute(
        path: '${NamaRute.formulir}/:kode',
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, state) {
          final kode = state.pathParameters['kode'] ?? '';
          return HalamanFormulirLayanan(jenis: JenisLayanan.dariKode(kode));
        },
      ),
      GoRoute(
        path: '${NamaRute.detailPermohonan}/:id',
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return HalamanDetailPermohonan(id: id);
        },
      ),
      GoRoute(
        path: NamaRute.pengaturan,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanPengaturan(),
      ),
      GoRoute(
        path: NamaRute.bantuan,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanBantuan(),
      ),
      GoRoute(
        path: NamaRute.panduan,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanPanduan(),
      ),
      GoRoute(
        path: NamaRute.kebijakanPrivasi,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanKebijakan(
          jenis: JenisKebijakan.privasi,
        ),
      ),
      GoRoute(
        path: NamaRute.kebijakanLayanan,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanKebijakan(
          jenis: JenisKebijakan.layanan,
        ),
      ),
      GoRoute(
        path: NamaRute.syaratKetentuan,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanKebijakan(
          jenis: JenisKebijakan.syaratKetentuan,
        ),
      ),
      GoRoute(
        path: NamaRute.penafianSistem,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanKebijakan(
          jenis: JenisKebijakan.penafian,
        ),
      ),
      GoRoute(
        path: NamaRute.kebijakanBiometrik,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanKebijakan(
          jenis: JenisKebijakan.biometrik,
        ),
      ),
      GoRoute(
        path: NamaRute.pernyataanKebenaranData,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanKebijakan(
          jenis: JenisKebijakan.kebenaranData,
        ),
      ),
      GoRoute(
        path: NamaRute.kebijakanPrivasiSetuju,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanKebijakan(
          jenis: JenisKebijakan.privasi,
          modePersetujuan: true,
        ),
      ),
      GoRoute(
        path: NamaRute.kebijakanLayananSetuju,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanKebijakan(
          jenis: JenisKebijakan.layanan,
          modePersetujuan: true,
        ),
      ),
      GoRoute(
        path: NamaRute.syaratKetentuanSetuju,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanKebijakan(
          jenis: JenisKebijakan.syaratKetentuan,
          modePersetujuan: true,
        ),
      ),
      GoRoute(
        path: NamaRute.penafianSistemSetuju,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanKebijakan(
          jenis: JenisKebijakan.penafian,
          modePersetujuan: true,
        ),
      ),
      GoRoute(
        path: NamaRute.kebijakanBiometrikSetuju,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanKebijakan(
          jenis: JenisKebijakan.biometrik,
          modePersetujuan: true,
        ),
      ),
      GoRoute(
        path: NamaRute.pernyataanKebenaranDataSetuju,
        parentNavigatorKey: DialogAplikasi.kunciNavigatorRoot,
        builder: (_, _) => const HalamanKebijakan(
          jenis: JenisKebijakan.kebenaranData,
          modePersetujuan: true,
        ),
      ),
    ],
  );
});

class _Pendengar extends ChangeNotifier {
  _Pendengar(Ref ref) {
    _otentikasi = ref.listen(penyediaOtentikasi, (_, _) => notifyListeners());
    _maintenance =
        ref.listen(statusMaintenanceProvider, (_, _) => notifyListeners());
  }

  late final ProviderSubscription _otentikasi;
  late final ProviderSubscription _maintenance;

  @override
  void dispose() {
    _otentikasi.close();
    _maintenance.close();
    super.dispose();
  }
}
