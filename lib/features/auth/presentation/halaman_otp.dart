import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../core/errors/kesalahan.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/theme/warna.dart';
import '../../../core/utils/penyamaran.dart';
import '../../../shared/providers/penyedia_muat_global.dart';
import '../../../shared/providers/penyedia_otentikasi.dart';
import '../../../shared/providers/penyedia_repositori.dart';
import '../data/model_otp.dart';

class HalamanOtp extends ConsumerStatefulWidget {
  const HalamanOtp({
    super.key,
    required this.identitas,
    this.tipe = TipeOtp.login,
  });
  final String identitas;
  final TipeOtp tipe;

  @override
  ConsumerState<HalamanOtp> createState() => _HalamanOtpState();
}

class _HalamanOtpState extends ConsumerState<HalamanOtp> {
  final _pengaturKode = TextEditingController();
  Timer? _pencacah;
  int _detik = 60;
  bool _memuat = false;
  bool _kirimUlangSedang = false;

  @override
  void initState() {
    super.initState();
    _mulaiPencacah();
  }

  void _mulaiPencacah() {
    _detik = 60;
    _pencacah?.cancel();
    _pencacah = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_detik <= 1) {
        t.cancel();
        if (mounted) setState(() => _detik = 0);
      } else {
        if (mounted) setState(() => _detik--);
      }
    });
  }

  @override
  void dispose() {
    _pengaturKode.dispose();
    _pencacah?.cancel();
    super.dispose();
  }

  Future<void> _kirim() async {
    // Guard anti double-submit: PinCodeTextField.onCompleted bisa terpicu
    // berulang (paste / autofill / ketik cepat). Tolak kalau sedang proses.
    if (_memuat) return;
    final t = ref.read(teksProvider);
    if (_pengaturKode.text.length != 6) return;
    setState(() => _memuat = true);
    try {
      final hasil = await ref.read(penyediaMuatGlobal.notifier).jalankan(
            () => ref.read(penyediaRepositoriOtentikasi).verifikasiOtp(
                  identitas: widget.identitas,
                  kode: _pengaturKode.text,
                  tipe: widget.tipe,
                ),
            judul: t.mohonTunggu,
            pesan: t.memverifikasiKode,
          );
      if (!mounted) return;
      switch (hasil) {
        case HasilVerifikasiOtpLogin():
          ref
              .read(penyediaOtentikasi.notifier)
              .tandaiSudahMasukDariOtp(hasil.pengguna);
          context.tampilkanPesan(t.verifikasiBerhasil);
          context.go(NamaRute.beranda);
        case HasilVerifikasiOtpReset():
          context.go(
            NamaRute.resetKataSandiBaru,
            extra: hasil.tokenReset,
          );
        case HasilVerifikasiOtpUmum():
          context.tampilkanPesan(t.verifikasiBerhasil);
          context.pop();
      }
    } on Kesalahan catch (e) {
      if (!mounted) return;
      context.tampilkanPesan(e.pesan, galat: true);
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  Future<void> _kirimUlang() async {
    final t = ref.read(teksProvider);
    if (_detik > 0 || _kirimUlangSedang) return;
    _kirimUlangSedang = true;
    try {
      await ref.read(penyediaRepositoriOtentikasi).kirimUlangOtp(
            identitas: widget.identitas,
            tipe: widget.tipe,
          );
      _mulaiPencacah();
      if (!mounted) return;
      context.tampilkanPesan(t.kodeTerkirimUlang);
    } on Kesalahan catch (e) {
      if (!mounted) return;
      context.tampilkanPesan(e.pesan, galat: true);
    } finally {
      _kirimUlangSedang = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);
    final identitasSamar = widget.identitas.contains('@')
        ? Penyamaran.surel(widget.identitas)
        : widget.identitas.length >= 9
            ? Penyamaran.noHp(widget.identitas)
            : Penyamaran.nik(widget.identitas);

    const tinggiHero = 240.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Warna.permukaan,
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFC8102E), Color(0xFFEA8528)],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      shadowColor: Colors.black.withValues(alpha: 0.15),
                      child: InkWell(
                        onTap: () => context.canPop()
                            ? context.pop()
                            : context.go(NamaRute.masuk),
                        customBorder: const CircleBorder(),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(Icons.arrow_back,
                              color: Warna.teksUtama, size: 22),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              top: tinggiHero - 36,
              child: Container(
                decoration: const BoxDecoration(
                  color: Warna.permukaan,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    28,
                    40,
                    28,
                    28 + MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: Column(
                    children: [
                      Text(
                        t.masukkanKodeUnik,
                        textAlign: TextAlign.center,
                        style: context.teks.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        t.silakanPeriksaSmsKe(identitasSamar),
                        textAlign: TextAlign.center,
                        style: context.teks.bodyMedium?.copyWith(
                          color: Warna.teksKedua,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _KotakOtp(
                        pengatur: _pengaturKode,
                        saatLengkap: (_) => _kirim(),
                      ),
                      const SizedBox(height: 24),
                      _BarisKirimUlang(
                        detik: _detik,
                        saatTekan: _kirimUlang,
                      ),
                      const SizedBox(height: 32),
                      _TombolGarisMerah(
                        label: t.kirimKodeLewatEmail,
                        ikon: Icons.mail_outline,
                        onTap: _kirimUlang,
                      ),
                      const SizedBox(height: 12),
                      _TombolGarisMerah(
                        label: t.kirimKodeLewatTelepon,
                        ikon: Icons.call_outlined,
                        onTap: _kirimUlang,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        t.butuhBantuan,
                        style: context.teks.bodyMedium?.copyWith(
                          color: Warna.teksKedua,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => context.push(NamaRute.bantuan),
                        child: Text(
                          t.hubungiDisdukcapil,
                          style: const TextStyle(
                            color: Warna.info,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KotakOtp extends StatelessWidget {
  const _KotakOtp({required this.pengatur, required this.saatLengkap});
  final TextEditingController pengatur;
  final void Function(String) saatLengkap;

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      controller: pengatur,
      length: 6,
      keyboardType: TextInputType.number,
      animationType: AnimationType.fade,
      animationDuration: const Duration(milliseconds: 180),
      autoDisposeControllers: false,
      enableActiveFill: true,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(14),
        fieldHeight: 56,
        fieldWidth: 44,
        activeColor: Warna.merahUtama,
        selectedColor: Warna.merahUtama,
        inactiveColor: Colors.transparent,
        activeFillColor: Warna.permukaan,
        selectedFillColor: Warna.permukaan,
        inactiveFillColor: Warna.permukaan,
        borderWidth: 1.4,
      ),
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: Warna.teksUtama,
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      onCompleted: saatLengkap,
      onChanged: (_) {},
    );
  }
}

class _BarisKirimUlang extends ConsumerWidget {
  const _BarisKirimUlang({required this.detik, required this.saatTekan});
  final int detik;
  final VoidCallback saatTekan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final teksDasar = context.teks.bodyMedium?.copyWith(
      color: Warna.teksKedua,
    );
    if (detik > 0) {
      return Text.rich(
        TextSpan(
          text: t.tidakMenerimaSms,
          style: teksDasar,
          children: [
            TextSpan(
              text: t.kirimUlangDalam(detik),
              style: const TextStyle(
                color: Warna.teksKetiga,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return Text.rich(
      TextSpan(
        text: t.tidakMenerimaSms,
        style: teksDasar,
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: saatTekan,
              child: Text(
                t.kirimUlang,
                style: const TextStyle(
                  color: Warna.merahUtama,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TombolGarisMerah extends StatelessWidget {
  const _TombolGarisMerah({
    required this.label,
    required this.ikon,
    required this.onTap,
  });
  final String label;
  final IconData ikon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Warna.merahUtama, width: 1.4),
          shape: const StadiumBorder(),
          foregroundColor: Warna.merahUtama,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        icon: Icon(ikon, size: 20),
        label: Text(label),
      ),
    );
  }
}
