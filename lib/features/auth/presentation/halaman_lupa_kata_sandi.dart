import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/kesalahan.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../core/utils/validasi.dart';
import '../../../shared/providers/penyedia_repositori.dart';
import 'widgets/bingkai_otentikasi.dart';
import 'widgets/isian_garis_bawah.dart';

class HalamanLupaKataSandi extends ConsumerStatefulWidget {
  const HalamanLupaKataSandi({super.key});

  @override
  ConsumerState<HalamanLupaKataSandi> createState() => _HalamanLupaKataSandiState();
}

class _HalamanLupaKataSandiState extends ConsumerState<HalamanLupaKataSandi> {
  final _kunci = GlobalKey<FormState>();
  final _identitas = TextEditingController();
  bool _memuat = false;

  @override
  void dispose() {
    _identitas.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    final t = ref.read(teksProvider);
    if (!(_kunci.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _memuat = true);
    String? galatJaringan;
    try {
      await ref.read(penyediaRepositoriOtentikasi).mintaResetKataSandi(
            identitas: _identitas.text.trim(),
          );
    } on KesalahanJaringan catch (e) {
      galatJaringan = e.pesan;
    } on KesalahanBatasWaktu catch (e) {
      galatJaringan = e.pesan;
    } on KesalahanBatasFrekuensi catch (e) {
      galatJaringan = e.pesan;
    } on KesalahanBatasFrekuensiDenganRetry catch (e) {
      galatJaringan = e.pesan;
    } catch (_) {
      galatJaringan = null;
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
    if (!mounted) return;
    if (galatJaringan != null) {
      context.tampilkanPesan(galatJaringan, galat: true);
      return;
    }
    context.tampilkanPesan(t.lupaPesanNetral);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);
    return BingkaiOtentikasi(
      tampilkanKembali: true,
      judul: t.lupaKataSandiJudul,
      subJudul: t.masukkanNikEmail,
      anak: Form(
        key: _kunci,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IsianGarisBawah(
              petunjuk: t.nikEmail,
              pengatur: _identitas,
              tipeMasukan: TextInputType.emailAddress,
              aksiMasukan: TextInputAction.done,
              validator: Validasi.identitasAtauSurel,
              saatKirim: (_) => _kirim(),
            ),
            const SizedBox(height: Jarak.xxl),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _memuat ? null : _kirim,
                style: FilledButton.styleFrom(
                  backgroundColor: Warna.primer,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Warna.netral200,
                  elevation: 0,
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                child: _memuat
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(t.kirimTautanReset),
              ),
            ),
            const SizedBox(height: Jarak.lg),
            Center(
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Text(
                  t.kembaliKeHalamanMasuk,
                  style: const TextStyle(
                    color: Warna.primer,
                    fontWeight: FontWeight.w700,
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
