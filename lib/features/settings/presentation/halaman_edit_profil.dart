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
import '../../../shared/providers/penyedia_otentikasi.dart';
import '../../../shared/providers/penyedia_repositori.dart';
import '../../../shared/widgets/kotak_isian.dart';
import '../../../shared/widgets/tombol_utama.dart';

class HalamanEditProfil extends ConsumerStatefulWidget {
  const HalamanEditProfil({super.key});

  @override
  ConsumerState<HalamanEditProfil> createState() => _HalamanEditProfilState();
}

class _HalamanEditProfilState extends ConsumerState<HalamanEditProfil> {
  final _kunciForm = GlobalKey<FormState>();
  late final TextEditingController _nama;
  late final TextEditingController _telepon;
  late final TextEditingController _alamat;
  final _pembatas = Pembatas();
  bool _mengirim = false;

  @override
  void initState() {
    super.initState();
    final pengguna = ref.read(penyediaOtentikasi).pengguna;
    _nama = TextEditingController(text: pengguna?.namaLengkap ?? '');
    _telepon = TextEditingController(text: pengguna?.noHp ?? '');
    _alamat = TextEditingController(text: pengguna?.alamat ?? '');
  }

  @override
  void dispose() {
    _nama.dispose();
    _telepon.dispose();
    _alamat.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    FocusScope.of(context).unfocus();
    if (!(_kunciForm.currentState?.validate() ?? false)) return;

    final t = ref.read(teksProvider);
    final boleh = _pembatas.cobaJalan(() async {
      setState(() => _mengirim = true);
      try {
        final pengguna = await ref.read(penyediaMuatGlobal.notifier).jalankan(
              () => ref.read(penyediaRepositoriOtentikasi).perbaruiProfil(
                    namaLengkap: _nama.text.trim(),
                    telepon: _telepon.text.trim(),
                    alamat: _alamat.text.trim(),
                  ),
              judul: t.menyimpanProfil,
            );
        if (!mounted) return;
        await ref.read(penyediaOtentikasi.notifier).perbaruiProfil(pengguna);
        if (!mounted) return;
        context.tampilkanSukses(t.profilDiperbarui);
        context.pop();
      } on Kesalahan catch (e) {
        if (!mounted) return;
        context.tampilkanGalat(e.pesan);
      } catch (_) {
        if (!mounted) return;
        context.tampilkanGalat(t.gagalSimpanProfil);
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
    final pengguna = ref.watch(penyediaOtentikasi).pengguna;

    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(title: Text(t.dataPribadi)),
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
            KotakIsian(
              label: t.nikLabel,
              nilaiAwal: pengguna?.nik ?? '',
              bacaSaja: true,
              aktif: false,
              bantuan: t.nikTidakDapatDiubah,
            ),
            const SizedBox(height: Jarak.lg),
            KotakIsian(
              label: t.namaLengkap,
              wajib: true,
              pengatur: _nama,
              panjangMaks: 100,
              validator: (v) => Validasi.wajib(v, label: t.namaLengkap),
            ),
            const SizedBox(height: Jarak.lg),
            KotakIsian(
              label: t.nomorHp,
              pengatur: _telepon,
              tipeMasukan: TextInputType.phone,
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? null : Validasi.noHp(v),
            ),
            const SizedBox(height: Jarak.lg),
            KotakIsian(
              label: t.alamatDomisili,
              pengatur: _alamat,
              barisMin: 2,
              barisMaks: 4,
              tipeMasukan: TextInputType.multiline,
            ),
            const SizedBox(height: Jarak.xxl),
            TombolUtama(
              label: t.simpanPerubahan,
              memuat: _mengirim,
              saatTekan: _simpan,
            ),
            const SizedBox(height: Jarak.md),
            Text(
              t.infoUbahIdentitas,
              textAlign: TextAlign.center,
              style: context.teks.labelSmall?.copyWith(
                color: Warna.teksKetiga,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
