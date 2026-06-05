import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _memeriksa = false;

  Future<void> _cobaUlang() async {
    setState(() => _memeriksa = true);
    await LayananStatusSistem.instance.cek(paksaUlang: true);
    if (mounted) setState(() => _memeriksa = false);
  }

  void _keluarAplikasi() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(statusMaintenanceProvider);
    final t = ref.watch(teksProvider);
    final bahasa = ref.watch(penyediaBahasa);

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
                _Ikon(),
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
                      : t.maintenanceHalamanPesan,
                  textAlign: TextAlign.center,
                  style: context.teks.bodyMedium?.copyWith(
                    color: Warna.teksKedua,
                    height: 1.6,
                  ),
                ),
                if (status.estimasiSelesai != null) ...[
                  const SizedBox(height: Jarak.lg),
                  _BarisInfo(
                    ikon: HugeIcons.strokeRoundedClock01,
                    teks: t.estimasiSelesai(
                      _formatTanggal(status.estimasiSelesai!, bahasa),
                    ),
                  ),
                ],
                if (status.kontakDukungan != null &&
                    status.kontakDukungan!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _BarisInfo(
                    ikon: HugeIcons.strokeRoundedCustomerService01,
                    teks: t.kontakLayanan(status.kontakDukungan!),
                  ),
                ],
                const Spacer(),
                _TombolUtama(
                  label: t.cobaLagi,
                  memuat: _memeriksa,
                  saatTekan: _cobaUlang,
                ),
                const SizedBox(height: Jarak.sm),
                _TombolKedua(
                  label: t.keluarAplikasiLabel,
                  saatTekan: _keluarAplikasi,
                ),
                const SizedBox(height: Jarak.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTanggal(DateTime tanggal, KodeBahasa bahasa) {
    final lokal = bahasa == KodeBahasa.en ? 'en_US' : 'id_ID';
    return DateFormat('d MMMM yyyy, HH:mm', lokal).format(tanggal.toLocal());
  }
}

class _Ikon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: Warna.netral50,
        shape: BoxShape.circle,
        border: Border.all(color: Warna.garis, width: 1.4),
      ),
      alignment: Alignment.center,
      child: const Icon(
        HugeIcons.strokeRoundedTools,
        size: 42,
        color: Warna.teksUtama,
      ),
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
          backgroundColor: Warna.merahUtama,
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
                    strokeWidth: 2.4, color: Colors.white),
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
