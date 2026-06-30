import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/kesalahan.dart';
import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../../core/utils/format.dart';
import '../../../../features/auth/domain/repositori_otentikasi.dart';
import '../../../../shared/models/perangkat_aktif.dart';
import '../../../../shared/providers/penyedia_muat_global.dart';
import '../../../../shared/providers/penyedia_otentikasi.dart';

class LembarKeluarkanPerangkat extends ConsumerStatefulWidget {
  const LembarKeluarkanPerangkat({
    super.key,
    required this.identitas,
    required this.kataSandi,
    required this.perangkatAwal,
  });

  final String identitas;
  final String kataSandi;
  final List<PerangkatAktif> perangkatAwal;

  static Future<HasilLogin?> tampilkan(
    BuildContext context, {
    required String identitas,
    required String kataSandi,
    required List<PerangkatAktif> perangkat,
  }) {
    return showModalBottomSheet<HasilLogin>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Warna.permukaan,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => LembarKeluarkanPerangkat(
        identitas: identitas,
        kataSandi: kataSandi,
        perangkatAwal: perangkat,
      ),
    );
  }

  @override
  ConsumerState<LembarKeluarkanPerangkat> createState() =>
      _LembarKeluarkanPerangkatState();
}

class _LembarKeluarkanPerangkatState
    extends ConsumerState<LembarKeluarkanPerangkat> {
  late final List<PerangkatAktif> _perangkat = [...widget.perangkatAwal];
  String? _dipilih;
  String? _galat;

  Future<void> _kirim() async {
    final t = ref.read(teksProvider);
    final dipilih = _dipilih;
    if (dipilih == null) {
      setState(() => _galat = t.pilihPerangkatDahulu);
      return;
    }
    setState(() => _galat = null);

    try {
      final hasil = await ref
          .read(penyediaMuatGlobal.notifier)
          .jalankan(
            () => ref
                .read(penyediaOtentikasi.notifier)
                .cabutDanMasuk(
                  identitas: widget.identitas,
                  kataSandi: widget.kataSandi,
                  idSesiDicabut: dipilih,
                ),
            judul: t.keluarkanDanMasuk,
          );
      if (mounted) Navigator.of(context).pop(hasil);
    } on KesalahanKredensialSalah {
      if (mounted) setState(() => _galat = t.kataSandiSalah);
    } on KesalahanSesiTidakValid {
      await _muatUlang(t.perangkatTidakValidRefresh);
    } on KesalahanSesiSudahTidakAktif {
      await _muatUlang(t.perangkatSudahKeluarPilihUlang);
    } on KesalahanBatasFrekuensiDenganRetry catch (e) {
      if (mounted) setState(() => _galat = e.pesan);
    } on KesalahanBatasFrekuensi catch (e) {
      if (mounted) setState(() => _galat = e.pesan);
    } on KesalahanBatasPerangkat catch (e) {
      if (mounted) {
        setState(() {
          _perangkat
            ..clear()
            ..addAll(e.perangkatAktif);
          _dipilih = null;
        });
      }
    } on Kesalahan catch (e) {
      if (mounted) setState(() => _galat = e.pesan);
    } catch (_) {
      if (mounted) setState(() => _galat = t.gagalLogoutPerangkat);
    }
  }

  Future<void> _muatUlang(String pesan) async {
    try {
      final hasil = await ref
          .read(penyediaOtentikasi.notifier)
          .masuk(identitas: widget.identitas, kataSandi: widget.kataSandi);
      if (mounted) Navigator.of(context).pop(hasil);
    } on KesalahanBatasPerangkat catch (e) {
      if (!mounted) return;
      setState(() {
        _perangkat
          ..clear()
          ..addAll(e.perangkatAktif);
        _dipilih = null;
        _galat = pesan;
      });
    } catch (_) {
      if (mounted) setState(() => _galat = pesan);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);
    final bawah = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bawah),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Jarak.layarH,
                Jarak.lg,
                Jarak.layarH,
                Jarak.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.keluarkanPerangkatJudul,
                    style: context.teks.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: Jarak.xs),
                  Text(
                    t.keluarkanPerangkatPesan,
                    style: context.teks.bodySmall?.copyWith(
                      color: Warna.teksKedua,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: RadioGroup<String>(
                groupValue: _dipilih,
                onChanged: (v) => setState(() {
                  _dipilih = v;
                  _galat = null;
                }),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: Jarak.sm),
                  itemCount: _perangkat.length,
                  itemBuilder: (_, i) {
                    final p = _perangkat[i];
                    final nama = p.namaTampil.isNotEmpty
                        ? p.namaTampil
                        : t.perangkatTidakDikenal;
                    final sub = [
                      if (p.label.isEmpty && p.os.isNotEmpty) p.os,
                      if (p.terakhirAktif != null)
                        '${t.terakhirAktif}: ${Format.relatif(p.terakhirAktif!)}',
                    ].join(' • ');
                    return RadioListTile<String>(
                      value: p.sesiId,
                      activeColor: Warna.primer,
                      title: Text(
                        nama,
                        style: context.teks.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: sub.isEmpty
                          ? null
                          : Text(
                              sub,
                              style: context.teks.bodySmall?.copyWith(
                                color: Warna.teksKetiga,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ),
            if (_galat != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Jarak.layarH,
                  Jarak.xs,
                  Jarak.layarH,
                  0,
                ),
                child: Text(
                  _galat!,
                  style: context.teks.bodySmall?.copyWith(color: Warna.bahaya),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Jarak.layarH,
                Jarak.md,
                Jarak.layarH,
                Jarak.lg,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _dipilih == null ? null : _kirim,
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
                    ),
                  ),
                  child: Text(t.keluarkanDanMasuk),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
