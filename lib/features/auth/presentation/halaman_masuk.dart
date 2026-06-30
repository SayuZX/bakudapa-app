import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/dialogs/dialog_aplikasi.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/network/penjaga_jaringan.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/system/penjaga_maintenance.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../core/utils/penunda.dart';
import '../../../core/utils/validasi.dart';
import '../../../shared/providers/penyedia_muat_global.dart';
import '../../../shared/providers/penyedia_otentikasi.dart';
import '../../perangkat/presentation/widgets/lembar_keluarkan_perangkat.dart';
import '../data/model_otp.dart';
import '../domain/repositori_otentikasi.dart';
import 'widgets/bingkai_otentikasi.dart';
import 'widgets/isian_garis_bawah.dart';

class HalamanMasuk extends ConsumerStatefulWidget {
  const HalamanMasuk({super.key});

  @override
  ConsumerState<HalamanMasuk> createState() => _HalamanMasukState();
}

class _HalamanMasukState extends ConsumerState<HalamanMasuk> {
  final _kunciForm = GlobalKey<FormState>();
  final _identitas = TextEditingController();
  final _kataSandi = TextEditingController();
  final _pembatas = Pembatas();
  bool _memuat = false;
  bool _bolehKirim = false;
  String? _galatIdentitas;
  String? _galatKataSandi;

  @override
  void initState() {
    super.initState();
    _identitas.addListener(_perbaruiValiditas);
    _kataSandi.addListener(_perbaruiValiditas);
  }

  @override
  void dispose() {
    _identitas.removeListener(_perbaruiValiditas);
    _kataSandi.removeListener(_perbaruiValiditas);
    _identitas.dispose();
    _kataSandi.dispose();
    super.dispose();
  }

  void _perbaruiValiditas() {
    final boleh =
        Validasi.identitasAtauSurel(_identitas.text) == null &&
        _kataSandi.text.trim().isNotEmpty;
    if (boleh != _bolehKirim) {
      setState(() => _bolehKirim = boleh);
    }
  }

  void _bersihkanGalat() {
    if (_galatIdentitas != null || _galatKataSandi != null) {
      setState(() {
        _galatIdentitas = null;
        _galatKataSandi = null;
      });
    }
  }

  Future<void> _kirim() async {
    final t = ref.read(teksProvider);
    _bersihkanGalat();
    if (!(_kunciForm.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final jaringanOk = await PenjagaJaringan.cekUntukAksi(
      context: context,
      ref: ref,
    );
    if (!mounted || !jaringanOk) return;
    final maintenanceOk = await PenjagaMaintenance.cekUntukAksi(
      context: context,
      ref: ref,
    );
    if (!mounted || !maintenanceOk) return;

    final boleh = _pembatas.cobaJalan(() async {
      setState(() => _memuat = true);
      try {
        final identitas = _identitas.text.trim();
        final hasilLogin = await ref
            .read(penyediaMuatGlobal.notifier)
            .jalankan<HasilLogin>(
              () => ref
                  .read(penyediaOtentikasi.notifier)
                  .masuk(identitas: identitas, kataSandi: _kataSandi.text),
              judul: t.mohonTunggu,
              pesan: t.memverifikasiAkun,
            );
        if (!mounted) return;
        if (hasilLogin.perluOtp) {
          context.push(
            NamaRute.otp,
            extra: {'identitas': identitas, 'tipe': TipeOtp.login},
          );
          return;
        }
        if (hasilLogin.perluKelolaPerangkat) {
          context.push(
            NamaRute.kelolaPerangkat,
            extra: hasilLogin.kelolaPerangkat!.perangkatAktif,
          );
          return;
        }

        context.tampilkanSukses(t.selamatDatang);
      } on KesalahanKredensialSalah catch (e) {
        if (!mounted) return;
        setState(() {
          _galatIdentitas = t.periksaDataLogin;
          _galatKataSandi = e.pesan;
        });
        _kunciForm.currentState?.validate();
      } on KesalahanValidasi catch (e) {
        if (!mounted) return;
        final pesan = e.pesan.toLowerCase();
        setState(() {
          if (pesan.contains('kata sandi') ||
              pesan.contains('password') ||
              pesan.contains('salah')) {
            _galatIdentitas = t.periksaDataLogin;
            _galatKataSandi = e.pesan;
          } else {
            _galatIdentitas = e.pesan;
          }
        });
        _kunciForm.currentState?.validate();
      } on KesalahanTidakBerwenang catch (e) {
        if (!mounted) return;
        await DialogAplikasi.tampilkanAlert<void>(
          context: context,
          judul: t.aksesDitolak,
          pesan: e.pesan,
          nada: NadaDialog.bahaya,
        );
      } on KesalahanDilarang catch (e) {
        if (!mounted) return;
        await DialogAplikasi.tampilkanAlert<void>(
          context: context,
          judul: t.akunDiblokir,
          pesan: e.pesan,
          nada: NadaDialog.bahaya,
        );
      } on KesalahanBatasFrekuensi catch (e) {
        if (!mounted) return;
        await DialogAplikasi.tampilkanAlert<void>(
          context: context,
          judul: t.terlaluBanyakPercobaan,
          pesan: e.pesan,
          nada: NadaDialog.peringatan,
        );
      } on KesalahanBatasPerangkat catch (e) {
        if (!mounted) return;
        final identitas = _identitas.text.trim();
        final hasil = await LembarKeluarkanPerangkat.tampilkan(
          context,
          identitas: identitas,
          kataSandi: _kataSandi.text,
          perangkat: e.perangkatAktif,
        );
        if (!mounted || hasil == null) return;
        if (hasil.perluOtp) {
          context.push(
            NamaRute.otp,
            extra: {'identitas': identitas, 'tipe': TipeOtp.login},
          );
          return;
        }
        if (hasil.perluKelolaPerangkat) {
          context.push(
            NamaRute.kelolaPerangkat,
            extra: hasil.kelolaPerangkat!.perangkatAktif,
          );
          return;
        }
        context.tampilkanSukses(t.selamatDatang);
      } on Kesalahan catch (e) {
        if (!mounted) return;
        context.tampilkanGalat(e.pesan);
      } catch (_) {
        if (!mounted) return;
        context.tampilkanGalat(t.tidakDapatMasuk);
      } finally {
        if (mounted) {
          _kataSandi.clear();
          setState(() => _memuat = false);
        }
      }
    });
    if (!boleh) {
      context.tampilkanGalat(t.mohonTungguSebentar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);
    final pesanSesi = ref.watch(penyediaOtentikasi).pesan;

    return BingkaiOtentikasi(
      judul: t.masukDenganAkun,
      subJudul: t.gunakanNikAtau,
      anak: Form(
        key: _kunciForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (pesanSesi != null) ...[
              _PesanPeringatan(pesan: pesanSesi),
              const SizedBox(height: Jarak.lg),
            ],
            IsianGarisBawah(
              petunjuk: t.nikEmailNoHp,
              pengatur: _identitas,
              tipeMasukan: TextInputType.emailAddress,
              aksiMasukan: TextInputAction.next,
              validator: (v) {
                final dasar = Validasi.identitasAtauSurel(v);
                if (dasar != null) return dasar;
                return _galatIdentitas;
              },
            ),
            const SizedBox(height: Jarak.xl),
            IsianGarisBawah(
              petunjuk: t.kataSandi,
              pengatur: _kataSandi,
              tersembunyi: true,
              tampilkanToggleSandi: true,
              aksiMasukan: TextInputAction.done,
              validator: (v) {
                final dasar = Validasi.wajib(v, label: t.kataSandiLabel);
                if (dasar != null) return dasar;
                return _galatKataSandi;
              },
              saatKirim: (_) => _kirim(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: Warna.primer,
                ),
                onPressed: () => context.push(NamaRute.lupaKataSandi),
                child: Text(
                  t.lupaKataSandi,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: Jarak.lg),
            const _Disclaimer(),
            const SizedBox(height: Jarak.xl),
            _TombolPil(
              label: t.masuk,
              memuat: _memuat,
              aktif: _bolehKirim,
              saatTekan: _kirim,
            ),
            const SizedBox(height: Jarak.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${t.belumPunyaAkun} ',
                  style: context.teks.bodyMedium?.copyWith(
                    color: Warna.teksKedua,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push(NamaRute.daftar),
                  child: Text(
                    t.daftar,
                    style: const TextStyle(
                      color: Warna.primer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TombolPil extends StatelessWidget {
  const _TombolPil({
    required this.label,
    required this.memuat,
    required this.saatTekan,
    this.aktif = true,
  });
  final String label;
  final bool memuat;
  final bool aktif;
  final VoidCallback saatTekan;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: (memuat || !aktif) ? null : saatTekan,
        style: FilledButton.styleFrom(
          backgroundColor: Warna.primer,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Warna.netral200,
          disabledForegroundColor: Warna.teksNonaktif,
          elevation: 0,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        child: memuat
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

class _Disclaimer extends ConsumerWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final dasar = context.teks.bodySmall?.copyWith(
      color: Warna.teksKedua,
      height: 1.55,
    );
    final tautan = TextStyle(
      color: Warna.info,
      fontWeight: FontWeight.w600,
      height: dasar?.height,
      fontSize: dasar?.fontSize,
    );
    return Text.rich(
      TextSpan(
        text: t.denganMasukSayaSetuju,
        style: dasar,
        children: [
          TextSpan(
            text: t.syaratKetentuan,
            style: tautan,
            recognizer: TapGestureRecognizer()
              ..onTap = () => context.push(NamaRute.syaratKetentuan),
          ),
          TextSpan(text: t.danPenghubung),
          TextSpan(
            text: t.kebijakanPrivasi,
            style: tautan,
            recognizer: TapGestureRecognizer()
              ..onTap = () => context.push(NamaRute.kebijakanPrivasi),
          ),
          TextSpan(text: t.disdukcapilSuffix),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _PesanPeringatan extends StatelessWidget {
  const _PesanPeringatan({required this.pesan});
  final String pesan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Jarak.md),
      decoration: BoxDecoration(
        color: Warna.peringatanLembut,
        borderRadius: BorderRadius.circular(Sudut.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Warna.peringatan, size: 18),
          const SizedBox(width: Jarak.sm),
          Expanded(
            child: Text(
              pesan,
              style: context.teks.bodySmall?.copyWith(color: Warna.peringatan),
            ),
          ),
        ],
      ),
    );
  }
}
