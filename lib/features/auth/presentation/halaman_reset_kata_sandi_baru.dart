import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/kesalahan.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../core/utils/validasi.dart';
import '../../../shared/providers/penyedia_muat_global.dart';
import '../../../shared/providers/penyedia_repositori.dart';
import 'widgets/bingkai_otentikasi.dart';
import 'widgets/isian_garis_bawah.dart';

class HalamanResetKataSandiBaru extends ConsumerStatefulWidget {
  const HalamanResetKataSandiBaru({super.key, required this.tokenReset});

  final String tokenReset;

  @override
  ConsumerState<HalamanResetKataSandiBaru> createState() =>
      _HalamanResetKataSandiBaruState();
}

class _HalamanResetKataSandiBaruState
    extends ConsumerState<HalamanResetKataSandiBaru> {
  final _kunci = GlobalKey<FormState>();
  final _kataSandi = TextEditingController();
  final _konfirmasi = TextEditingController();
  bool _sedang = false;

  @override
  void dispose() {
    _kataSandi.dispose();
    _konfirmasi.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (_sedang) return;
    final t = ref.read(teksProvider);
    if (!(_kunci.currentState?.validate() ?? false)) return;
    if (widget.tokenReset.isEmpty) {
      context.tampilkanPesan('Token reset tidak valid.', galat: true);
      return;
    }
    FocusScope.of(context).unfocus();

    setState(() => _sedang = true);
    final muat = ref.read(penyediaMuatGlobal.notifier);
    try {
      await muat.jalankan<void>(
        () => ref.read(penyediaRepositoriOtentikasi).setKataSandiBaru(
              tokenReset: widget.tokenReset,
              kataSandiBaru: _kataSandi.text,
            ),
        judul: t.mohonTunggu,
        pesan: t.memprosesPermintaan,
      );
      if (!mounted) return;
      context.tampilkanSukses(t.kataSandiBerhasilDiubah);
      context.go(NamaRute.masuk);
    } on Kesalahan catch (e) {
      if (!mounted) return;
      context.tampilkanPesan(e.pesan, galat: true);
    } catch (_) {
      if (!mounted) return;
      context.tampilkanPesan(t.terjadiKesalahan, galat: true);
    } finally {
      if (mounted) setState(() => _sedang = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);

    return BingkaiOtentikasi(
      tampilkanKembali: true,
      judul: t.buatKataSandiBaruJudul,
      subJudul: t.buatKataSandiBaruSub,
      anak: Form(
        key: _kunci,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IsianGarisBawah(
              petunjuk: t.kataSandiBaru,
              pengatur: _kataSandi,
              tersembunyi: true,
              tampilkanToggleSandi: true,
              aksiMasukan: TextInputAction.next,
              validator: Validasi.kataSandi,
            ),
            const SizedBox(height: Jarak.xl),
            IsianGarisBawah(
              petunjuk: t.konfirmasiKataSandiBaru,
              pengatur: _konfirmasi,
              tersembunyi: true,
              tampilkanToggleSandi: true,
              aksiMasukan: TextInputAction.done,
              validator: (v) =>
                  Validasi.konfirmasiKataSandi(v, _kataSandi.text),
              saatKirim: (_) => _simpan(),
            ),
            const SizedBox(height: Jarak.xxl),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _sedang ? null : _simpan,
                style: FilledButton.styleFrom(
                  backgroundColor: Warna.merahUtama,
                  disabledBackgroundColor: Warna.netral200,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(t.simpanKataSandiBaru),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
