import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/system/layanan_status_sistem.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/providers/penyedia_bahasa.dart';
import '../../../shared/providers/penyedia_maintenance.dart';

class HalamanMaintenance extends ConsumerStatefulWidget {
  const HalamanMaintenance({super.key});

  @override
  ConsumerState<HalamanMaintenance> createState() =>
      _HalamanMaintenanceState();
}

class _HalamanMaintenanceState extends ConsumerState<HalamanMaintenance> {
  bool _memuatManual = false;

  Future<void> _cobaSekarang() async {
    if (_memuatManual) return;
    setState(() => _memuatManual = true);
    await LayananStatusSistem.instance.cek(paksaUlang: true);
    if (mounted) setState(() => _memuatManual = false);
  }

  void _keluarAplikasi() {
    if (Platform.isAndroid) SystemNavigator.pop();
  }

  String _formatTanggal(DateTime tanggal, KodeBahasa bahasa) {
    final lokal = bahasa == KodeBahasa.en ? 'en_US' : 'id_ID';
    return DateFormat('d MMMM yyyy, HH:mm', lokal).format(tanggal.toLocal());
  }

  String _formatJam(DateTime tanggal, KodeBahasa bahasa) {
    final lokal = bahasa == KodeBahasa.en ? 'en_US' : 'id_ID';
    return DateFormat('HH:mm', lokal).format(tanggal.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(statusMaintenanceProvider);
    final t = ref.watch(teksProvider);
    final bahasa = ref.watch(penyediaBahasa);
    final memeriksa = _memuatManual;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Warna.permukaan,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Jarak.xxl),
            child: Column(
              children: [
                const Spacer(),
                const _IkonPemeliharaan(),
                const SizedBox(height: Jarak.xxl),
                Text(
                  status.judul?.isNotEmpty == true
                      ? status.judul!
                      : t.maintenanceHalamanJudul,
                  textAlign: TextAlign.center,
                  style: context.teks.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: Jarak.md),
                Text(
                  status.pesan?.isNotEmpty == true
                      ? status.pesan!
                      : t.maintenanceSubPesan,
                  textAlign: TextAlign.center,
                  style: context.teks.bodyMedium?.copyWith(
                    color: Warna.teksKedua,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: Jarak.lg),
                _BarisInfo(
                  ikon: HugeIcons.strokeRoundedClock01,
                  teks: status.estimasiSelesai != null
                      ? t.estimasiSelesai(
                          _formatTanggal(status.estimasiSelesai!, bahasa),
                        )
                      : t.maintenanceSegeraKembali,
                ),
                if (status.kontakDukungan != null &&
                    status.kontakDukungan!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _BarisInfo(
                    ikon: HugeIcons.strokeRoundedCustomerService01,
                    teks: t.kontakLayanan(status.kontakDukungan!),
                  ),
                ],
                const Spacer(),
                _StatusRealtime(
                  memeriksa: memeriksa,
                  label: memeriksa
                      ? t.maintenanceStatusMemeriksa
                      : status.diperiksaPada != null
                      ? t.maintenanceTerakhirDiperiksa(
                          _formatJam(status.diperiksaPada!, bahasa),
                        )
                      : t.maintenanceStatusAktif,
                ),
                const SizedBox(height: Jarak.lg),
                _TombolUtama(
                  label: t.maintenanceCobaSekarang,
                  memuat: _memuatManual,
                  saatTekan: _cobaSekarang,
                ),
                const SizedBox(height: Jarak.sm),
                _TombolKedua(
                  label: t.keluarAplikasiLabel,
                  saatTekan: _keluarAplikasi,
                ),
                const SizedBox(height: Jarak.xl),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
              .slideY(begin: 0.04, end: 0, duration: 320.ms),
        ),
      ),
    );
  }
}

class _IkonPemeliharaan extends StatelessWidget {
  const _IkonPemeliharaan();

  @override
  Widget build(BuildContext context) {
    return Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Warna.primerLembut,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            HugeIcons.strokeRoundedWrench01,
            size: 42,
            color: Warna.primer,
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
          begin: 1,
          end: 1.06,
          duration: 1600.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _StatusRealtime extends StatelessWidget {
  const _StatusRealtime({required this.memeriksa, required this.label});
  final bool memeriksa;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (memeriksa)
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2, color: Warna.primer),
          )
        else
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Warna.peringatan,
              shape: BoxShape.circle,
            ),
          ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.teks.labelMedium?.copyWith(
              color: Warna.teksKetiga,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _BarisInfo extends StatelessWidget {
  const _BarisInfo({required this.ikon, required this.teks});
  final IconData ikon;
  final String teks;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ikon, size: 14, color: Warna.teksKetiga),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            teks,
            textAlign: TextAlign.center,
            style: context.teks.bodySmall?.copyWith(
              color: Warna.teksKetiga,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _TombolUtama extends StatelessWidget {
  const _TombolUtama({
    required this.label,
    required this.memuat,
    required this.saatTekan,
  });
  final String label;
  final bool memuat;
  final VoidCallback saatTekan;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: memuat ? null : saatTekan,
        style: FilledButton.styleFrom(
          backgroundColor: Warna.primer,
          disabledBackgroundColor: Warna.netral200,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
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

class _TombolKedua extends StatelessWidget {
  const _TombolKedua({required this.label, required this.saatTekan});
  final String label;
  final VoidCallback saatTekan;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: saatTekan,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Warna.garisTegas, width: 1.2),
          foregroundColor: Warna.teksUtama,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}
