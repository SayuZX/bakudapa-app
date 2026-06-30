import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/kesalahan.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../core/utils/penunda.dart';
import '../../../core/utils/validasi.dart';
import '../../../shared/providers/penyedia_muat_global.dart';
import '../../../shared/providers/penyedia_repositori.dart';
import '../../../shared/widgets/kotak_isian.dart';
import '../../../shared/widgets/tombol_utama.dart';

class HalamanGantiKataSandi extends ConsumerStatefulWidget {
  const HalamanGantiKataSandi({super.key});

  @override
  ConsumerState<HalamanGantiKataSandi> createState() =>
      _HalamanGantiKataSandiState();
}

class _HalamanGantiKataSandiState extends ConsumerState<HalamanGantiKataSandi> {
  final _kunciForm = GlobalKey<FormState>();
  final _lama = TextEditingController();
  final _baru = TextEditingController();
  final _konfirmasi = TextEditingController();
  final _pembatas = Pembatas();
  bool _mengirim = false;

  @override
  void dispose() {
    _lama.dispose();
    _baru.dispose();
    _konfirmasi.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    FocusScope.of(context).unfocus();
    if (!(_kunciForm.currentState?.validate() ?? false)) return;

    final t = ref.read(teksProvider);
    final boleh = _pembatas.cobaJalan(() async {
      setState(() => _mengirim = true);
      try {
        await ref.read(penyediaMuatGlobal.notifier).jalankan(
              () => ref.read(penyediaRepositoriOtentikasi).gantiKataSandi(
                    kataSandiLama: _lama.text,
                    kataSandiBaru: _baru.text,
                  ),
              judul: t.menyimpanKataSandi,
            );
        if (!mounted) return;
        context.tampilkanSukses(t.kataSandiBerhasilDiubah);
        context.pop();
      } on Kesalahan catch (e) {
        if (!mounted) return;
        context.tampilkanGalat(e.pesan);
      } catch (_) {
        if (!mounted) return;
        context.tampilkanGalat(t.gagalUbahSandi);
      } finally {
        if (mounted) setState(() => _mengirim = false);
      }
    });
    if (!boleh && mounted) {
      context.tampilkanGalat(t.permintaanDiproses);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);
    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(title: Text(t.gantiKataSandiJudul)),
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
              t.gantiSandiInfo,
              style: context.teks.bodySmall?.copyWith(
                color: Warna.teksKedua,
                height: 1.5,
              ),
            ),
            const SizedBox(height: Jarak.xl),
            _IsianSandi(
              label: t.kataSandiSaatIni,
              pengatur: _lama,
              validator: (v) => Validasi.wajib(v, label: t.kataSandiSaatIni),
            ),
            const SizedBox(height: Jarak.lg),
            _IsianSandi(
              label: t.kataSandiBaru,
              pengatur: _baru,
              validator: Validasi.kataSandi,
            ),
            const SizedBox(height: Jarak.lg),
            _IsianSandi(
              label: t.konfirmasiKataSandiBaru,
              pengatur: _konfirmasi,
              validator: (v) => Validasi.konfirmasiKataSandi(v, _baru.text),
            ),
            const SizedBox(height: Jarak.xxl),
            TombolUtama(
              label: t.simpanKataSandiBaru,
              memuat: _mengirim,
              saatTekan: _simpan,
            ),
          ],
        ),
      ),
    );
  }
}

class _IsianSandi extends StatelessWidget {
  const _IsianSandi({
    required this.label,
    required this.pengatur,
    required this.validator,
  });

  final String label;
  final TextEditingController pengatur;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return KotakIsian(
      label: label,
      wajib: true,
      pengatur: pengatur,
      tersembunyi: true,
      tipeMasukan: TextInputType.visiblePassword,
      validator: validator,
    );
  }
}
