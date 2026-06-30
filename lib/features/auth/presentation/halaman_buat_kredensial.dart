import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/errors/kesalahan.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../core/utils/penunda.dart';
import '../../../core/utils/validasi.dart';
import '../../../shared/providers/penyedia_muat_global.dart';
import '../../../shared/providers/penyedia_otentikasi.dart';
import '../../../shared/providers/penyedia_repositori.dart';
import '../../../shared/widgets/kotak_isian.dart';
import '../../../shared/widgets/tombol_utama.dart';
import '../domain/repositori_otentikasi.dart';

enum _StatusUsername { kosong, takValid, memeriksa, tersedia, terpakai }

class HalamanBuatKredensial extends ConsumerStatefulWidget {
  const HalamanBuatKredensial({super.key});

  @override
  ConsumerState<HalamanBuatKredensial> createState() =>
      _HalamanBuatKredensialState();
}

class _HalamanBuatKredensialState extends ConsumerState<HalamanBuatKredensial> {
  final _kunciForm = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _kataSandi = TextEditingController();
  final _konfirmasi = TextEditingController();
  final _pembatas = Pembatas();
  Timer? _debounce;
  _StatusUsername _statusUsername = _StatusUsername.kosong;
  bool _mengirim = false;

  @override
  void initState() {
    super.initState();
    _username.addListener(_saatUsernameBerubah);
    _kataSandi.addListener(_perbarui);
    _konfirmasi.addListener(_perbarui);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _username.dispose();
    _kataSandi.dispose();
    _konfirmasi.dispose();
    super.dispose();
  }

  void _perbarui() {
    if (mounted) setState(() {});
  }

  void _saatUsernameBerubah() {
    final v = _username.text.trim();
    _debounce?.cancel();
    if (Validasi.username(v) != null) {
      setState(() => _statusUsername =
          v.isEmpty ? _StatusUsername.kosong : _StatusUsername.takValid);
      return;
    }
    setState(() => _statusUsername = _StatusUsername.memeriksa);
    _debounce = Timer(const Duration(milliseconds: 500), () => _cek(v));
  }

  Future<void> _cek(String v) async {
    if (Validasi.username(v) != null) return;
    try {
      final tersedia =
          await ref.read(penyediaRepositoriOtentikasi).cekUsername(v);
      if (!mounted || _username.text.trim() != v) return;
      setState(() => _statusUsername =
          tersedia ? _StatusUsername.tersedia : _StatusUsername.terpakai);
    } catch (_) {
      if (!mounted) return;
      setState(() => _statusUsername = _StatusUsername.kosong);
    }
  }

  bool get _min8 => _kataSandi.text.length >= 8;
  bool get _hurufBesar => RegExp(r'[A-Z]').hasMatch(_kataSandi.text);
  bool get _hurufKecil => RegExp(r'[a-z]').hasMatch(_kataSandi.text);
  bool get _angka => RegExp(r'[0-9]').hasMatch(_kataSandi.text);
  bool get _sandiKuat => _min8 && _hurufBesar && _hurufKecil && _angka;

  bool get _bolehKirim =>
      _statusUsername == _StatusUsername.tersedia &&
      _sandiKuat &&
      _konfirmasi.text == _kataSandi.text &&
      !_mengirim;

  Future<void> _simpan() async {
    FocusScope.of(context).unfocus();
    if (!(_kunciForm.currentState?.validate() ?? false)) return;
    final t = ref.read(teksProvider);
    if (_statusUsername == _StatusUsername.terpakai) {
      context.tampilkanGalat(t.usernameTerpakai);
      return;
    }

    final boleh = _pembatas.cobaJalan(() async {
      setState(() => _mengirim = true);
      try {
        final hasil = await ref
            .read(penyediaMuatGlobal.notifier)
            .jalankan<HasilKredensial>(
              () => ref.read(penyediaRepositoriOtentikasi).aturKredensial(
                    username: _username.text.trim(),
                    kataSandiBaru: _kataSandi.text,
                  ),
              judul: t.mohonTunggu,
              pesan: t.menyimpanKataSandi,
            );
        if (!mounted) return;
        if (!hasil.diatur) {
          context.tampilkanGalat(t.terjadiKesalahan);
          return;
        }
        ref.read(penyediaOtentikasi.notifier).selesaiAturKredensial(
              username: hasil.username ?? _username.text.trim(),
            );
        if (!mounted) return;
        context.tampilkanSukses(t.kredensialBerhasil);
        context.go(NamaRute.beranda);
      } on Kesalahan catch (e) {
        if (!mounted) return;
        context.tampilkanGalat(e.pesan);
      } catch (_) {
        if (!mounted) return;
        context.tampilkanGalat(t.terjadiKesalahan);
      } finally {
        if (mounted) setState(() => _mengirim = false);
      }
    });
    if (!boleh && mounted) context.tampilkanGalat(t.permintaanDiproses);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Warna.latar,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(t.buatKredensialJudul),
        ),
        body: Form(
          key: _kunciForm,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              Jarak.layarH,
              Jarak.xl,
              Jarak.layarH,
              Jarak.xxxl,
            ),
            children: [
              Text(
                t.buatKredensialSub,
                style: context.teks.bodyMedium?.copyWith(
                  color: Warna.teksKedua,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: Jarak.xl),
              KotakIsian(
                label: t.usernameLabel,
                wajib: true,
                petunjuk: t.usernamePetunjuk,
                pengatur: _username,
                tipeMasukan: TextInputType.text,
                aksiMasukan: TextInputAction.next,
                panjangMaks: 20,
                ikonAwal: HugeIcons.strokeRoundedAt,
                ikonAkhir: _IndikatorUsername(status: _statusUsername),
                formatter: [
                  TextInputFormatter.withFunction(
                    (lama, baru) =>
                        baru.copyWith(text: baru.text.toLowerCase()),
                  ),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9._]')),
                ],
                validator: Validasi.username,
              ),
              const SizedBox(height: 6),
              _StatusUsernameTeks(status: _statusUsername),
              const SizedBox(height: Jarak.lg),
              KotakIsian(
                label: t.kataSandiBaru,
                wajib: true,
                pengatur: _kataSandi,
                tersembunyi: true,
                tipeMasukan: TextInputType.visiblePassword,
                aksiMasukan: TextInputAction.next,
                validator: (_) => _sandiKuat ? null : t.syaratMin8,
              ),
              const SizedBox(height: Jarak.md),
              _Syarat(label: t.syaratMin8, terpenuhi: _min8),
              _Syarat(label: t.syaratHurufBesar, terpenuhi: _hurufBesar),
              _Syarat(label: t.syaratHurufKecil, terpenuhi: _hurufKecil),
              _Syarat(label: t.syaratAngka, terpenuhi: _angka),
              const SizedBox(height: Jarak.lg),
              KotakIsian(
                label: t.konfirmasiKataSandiBaru,
                wajib: true,
                pengatur: _konfirmasi,
                tersembunyi: true,
                tipeMasukan: TextInputType.visiblePassword,
                aksiMasukan: TextInputAction.done,
                validator: (v) =>
                    Validasi.konfirmasiKataSandi(v, _kataSandi.text),
                saatKirim: (_) => _simpan(),
              ),
              const SizedBox(height: Jarak.xxl),
              TombolUtama(
                label: t.simpanLanjutkan,
                memuat: _mengirim,
                saatTekan: _bolehKirim ? _simpan : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndikatorUsername extends StatelessWidget {
  const _IndikatorUsername({required this.status});
  final _StatusUsername status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case _StatusUsername.memeriksa:
        return const Padding(
          padding: EdgeInsets.all(14),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case _StatusUsername.tersedia:
        return const Icon(
          HugeIcons.strokeRoundedCheckmarkCircle02,
          color: Warna.sukses,
          size: 20,
        );
      case _StatusUsername.terpakai:
        return const Icon(
          HugeIcons.strokeRoundedCancelCircle,
          color: Warna.bahaya,
          size: 20,
        );
      case _StatusUsername.kosong:
      case _StatusUsername.takValid:
        return const SizedBox.shrink();
    }
  }
}

class _StatusUsernameTeks extends ConsumerWidget {
  const _StatusUsernameTeks({required this.status});
  final _StatusUsername status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final (String teks, Color warna) = switch (status) {
      _StatusUsername.memeriksa => (t.usernameMemeriksa, Warna.teksKedua),
      _StatusUsername.tersedia => (t.usernameTersedia, Warna.sukses),
      _StatusUsername.terpakai => (t.usernameTerpakai, Warna.bahaya),
      _StatusUsername.kosong || _StatusUsername.takValid => ('', Warna.teksKedua),
    };
    if (teks.isEmpty) return const SizedBox.shrink();
    return Text(
      teks,
      style: context.teks.bodySmall?.copyWith(
        color: warna,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _Syarat extends StatelessWidget {
  const _Syarat({required this.label, required this.terpenuhi});
  final String label;
  final bool terpenuhi;

  @override
  Widget build(BuildContext context) {
    final warna = terpenuhi ? Warna.sukses : Warna.teksKetiga;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            terpenuhi
                ? HugeIcons.strokeRoundedCheckmarkCircle02
                : HugeIcons.strokeRoundedCircle,
            size: 16,
            color: warna,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: context.teks.bodySmall?.copyWith(color: warna),
          ),
        ],
      ),
    );
  }
}
