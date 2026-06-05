import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/router/nama_rute.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../providers/penyedia_registrasi.dart';
import '../widgets/stepper_registrasi.dart';

class HalamanPersetujuanSidikJari extends ConsumerStatefulWidget {
  const HalamanPersetujuanSidikJari({super.key});

  @override
  ConsumerState<HalamanPersetujuanSidikJari> createState() =>
      _HalamanPersetujuanSidikJariState();
}

class _HalamanPersetujuanSidikJariState
    extends ConsumerState<HalamanPersetujuanSidikJari> {
  bool _setuju = false;

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);
    final poin = [
      t.poinSidikJari1,
      t.poinSidikJari2,
      t.poinSidikJari3,
      t.poinSidikJari4,
      t.poinSidikJari5,
      t.poinSidikJari6,
    ];
    return Scaffold(
      backgroundColor: Warna.permukaan,
      appBar: AppBar(
        title: Text(t.verifikasiSidikJari),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(HugeIcons.strokeRoundedArrowLeft01),
        ),
      ),
      body: Column(
        children: [
          StepperRegistrasi(
            langkahAktif: LangkahRegistrasi.sidikJari,
            judulLangkah: t.verifikasiSidikJari,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Warna.merahLembut,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        HugeIcons.strokeRoundedFingerPrintScan,
                        color: Warna.merahUtama,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.masukDenganBiometrik,
                            style: context.teks.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.persetujuanSebelumAktivasi,
                            style: context.teks.bodySmall?.copyWith(
                              color: Warna.teksKedua,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Jarak.xl),
                for (var i = 0; i < poin.length; i++) ...[
                  _BarisPoin(nomor: i + 1, teks: poin[i]),
                  if (i < poin.length - 1) const SizedBox(height: Jarak.md),
                ],
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Warna.permukaan,
              border: Border(
                top: BorderSide(color: Warna.pemisah, width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _KotakCentang(
                      label: t.persetujuanAktivasiBiometrik,
                      nilai: _setuju,
                      onTap: () => setState(() => _setuju = !_setuju),
                    ),
                    const SizedBox(height: Jarak.md),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _setuju
                            ? () => context.push(NamaRute.daftarSidikJari)
                            : null,
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
                        child: Text(t.lanjut),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarisPoin extends StatelessWidget {
  const _BarisPoin({required this.nomor, required this.teks});
  final int nomor;
  final String teks;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Text(
            '$nomor.',
            style: context.teks.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Warna.teksUtama,
              height: 1.55,
            ),
          ),
        ),
        Expanded(
          child: Text(
            teks,
            style: context.teks.bodyMedium?.copyWith(
              color: Warna.teksUtama,
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}

class _KotakCentang extends StatelessWidget {
  const _KotakCentang({
    required this.label,
    required this.nilai,
    required this.onTap,
  });
  final String label;
  final bool nilai;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: nilai ? Warna.merahUtama : Warna.permukaan,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: nilai ? Warna.merahUtama : Warna.garisTegas,
                  width: 1.6,
                ),
              ),
              child: nilai
                  ? const Icon(
                      HugeIcons.strokeRoundedCheckmarkSquare01,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Warna.teksUtama,
                      height: 1.5,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
