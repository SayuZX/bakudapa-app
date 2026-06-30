import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../core/dialogs/dialog_aplikasi.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../core/utils/penyamaran.dart';
import '../../../shared/providers/penyedia_muat_global.dart';
import '../../../shared/providers/penyedia_otentikasi.dart';
import '../../../shared/providers/penyedia_repositori.dart';
import '../data/model_otp.dart';
import 'widgets/bingkai_otentikasi.dart';

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
          ref.read(penyediaOtentikasi.notifier).tandaiSudahMasukDariOtp(
                hasil.pengguna,
                wajibAturKredensial: hasil.wajibGantiKataSandi,
              );
          context.tampilkanPesan(t.verifikasiBerhasil);
          context.go(
            hasil.wajibGantiKataSandi
                ? NamaRute.buatKredensial
                : NamaRute.beranda,
          );
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

  Future<void> _fiturTidakTersedia() async {
    final t = ref.read(teksProvider);
    await DialogAplikasi.tampilkanAlert<void>(
      context: context,
      judul: t.fiturTidakTersediaJudul,
      pesan: t.fiturTidakTersediaSementara,
      nada: NadaDialog.info,
    );
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

    return BingkaiOtentikasi(
      tampilkanKembali: true,
      tinggiHero: 240,
      judul: t.masukkanKodeUnik,
      subJudul: t.silakanPeriksaSmsKe(identitasSamar),
      anak: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _KotakOtp(
            pengatur: _pengaturKode,
            saatLengkap: (_) => _kirim(),
          ),
          const SizedBox(height: Jarak.xl),
          _BarisKirimUlang(
            detik: _detik,
            saatTekan: _kirimUlang,
          ),
          const SizedBox(height: Jarak.xl),
          _TombolGarisMerah(
            label: t.kirimKodeLewatEmail,
            ikon: Icons.mail_outline,
            onTap: _kirimUlang,
          ),
          const SizedBox(height: Jarak.md),
          _TombolGarisMerah(
            label: t.kirimKodeLewatTelepon,
            ikon: Icons.call_outlined,
            onTap: _fiturTidakTersedia,
            gelap: true,
          ),
          const SizedBox(height: Jarak.xxl),
          Text(
            t.butuhBantuan,
            textAlign: TextAlign.center,
            style: context.teks.bodyMedium?.copyWith(color: Warna.teksKedua),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => context.push(NamaRute.bantuan),
            child: Text(
              t.hubungiDisdukcapil,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Warna.info,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
        activeColor: Warna.primer,
        selectedColor: Warna.primer,
        inactiveColor: Warna.garisTegas,
        disabledColor: Warna.garisTegas,
        activeFillColor: Warna.netral50,
        selectedFillColor: Warna.putih,
        inactiveFillColor: Warna.netral50,
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
        textAlign: TextAlign.center,
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
                  color: Warna.primer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _TombolGarisMerah extends StatelessWidget {
  const _TombolGarisMerah({
    required this.label,
    required this.ikon,
    required this.onTap,
    this.gelap = false,
  });
  final String label;
  final IconData ikon;
  final VoidCallback onTap;
  final bool gelap;

  @override
  Widget build(BuildContext context) {
    if (gelap) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton.icon(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: Warna.netral200,
            foregroundColor: Warna.teksNonaktif,
            elevation: 0,
            shape: const StadiumBorder(),
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
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Warna.primer, width: 1.4),
          shape: const StadiumBorder(),
          foregroundColor: Warna.primer,
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
