import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/kesalahan.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../core/utils/format.dart';
import '../../../core/utils/penunda.dart';
import '../../../core/utils/validasi.dart';
import '../../../shared/models/jenis_layanan.dart';
import '../../../shared/providers/penyedia_muat_global.dart';
import '../../../shared/providers/penyedia_repositori.dart';
import '../../../shared/widgets/kotak_centang_setuju.dart';
import '../../../shared/widgets/kotak_isian.dart';
import '../../../shared/widgets/tombol_utama.dart';
import '../domain/definisi_formulir.dart';
import 'widgets/pengunggah_berkas.dart';

class HalamanFormulirLayanan extends ConsumerStatefulWidget {
  const HalamanFormulirLayanan({super.key, required this.jenis});
  final JenisLayanan jenis;

  @override
  ConsumerState<HalamanFormulirLayanan> createState() => _HalamanFormulirLayananState();
}

class _HalamanFormulirLayananState extends ConsumerState<HalamanFormulirLayanan> {
  final _kunci = GlobalKey<FormState>();
  final Map<String, TextEditingController> _pengatur = {};
  final Map<String, dynamic> _nilai = {};
  final Map<String, File?> _berkas = {};
  final _pembatas = Pembatas();
  bool _setuju = false;
  bool _kirim = false;

  late final DefinisiFormulir _formulir = KatalogFormulir.untuk(widget.jenis);

  @override
  void initState() {
    super.initState();
    for (final r in _formulir.ruas) {
      _pengatur[r.nama] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _pengatur.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _ajukan() async {
    if (!(_kunci.currentState?.validate() ?? false)) return;
    if (!_setuju) {
      context.tampilkanPesan('Centang persetujuan terlebih dahulu.', galat: true);
      return;
    }
    for (final b in _formulir.berkas) {
      if (b.wajib && _berkas[b.nama] == null) {
        context.tampilkanPesan('Berkas "${b.label}" wajib diunggah.', galat: true);
        return;
      }
    }

    final boleh = _pembatas.cobaJalan(() async {
      setState(() => _kirim = true);
      try {
        for (final r in _formulir.ruas) {
          final teks = _pengatur[r.nama]!.text.trim();
          if (teks.isNotEmpty) _nilai[r.nama] = teks;
        }
        final lampiran = _berkas.values.whereType<File>().toList();
        await ref.read(penyediaMuatGlobal.notifier).jalankan<void>(
          () => ref.read(penyediaRepositoriPermohonan).ajukan(
                jenis: widget.jenis,
                data: _nilai,
                lampiran: lampiran,
              ),
          judul: 'Mohon Tunggu',
          pesan: 'Sedang mengirim permohonan Anda ke server.',
        );
        if (!mounted) return;
        context.tampilkanPesan('Permohonan berhasil diajukan.');
        context.go(NamaRute.riwayat);
      } on Kesalahan catch (e) {
        if (!mounted) return;
        context.tampilkanPesan(e.pesan, galat: true);
      } catch (_) {
        if (!mounted) return;
        context.tampilkanPesan('Gagal mengirim permohonan.', galat: true);
      } finally {
        if (mounted) setState(() => _kirim = false);
      }
    });
    if (!boleh) {
      context.tampilkanPesan('Mohon tunggu sebentar.', galat: true);
    }
  }

  Future<void> _pilihTanggal(String nama) async {
    final pilih = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pilih == null) return;
    final teks = DateFormat('dd-MM-yyyy').format(pilih);
    _pengatur[nama]!.text = teks;
    _nilai[nama] = DateFormat('yyyy-MM-dd').format(pilih);
  }

  String? _validatorRuas(DefinisiRuas r, String? nilai) {
    if (!r.wajib && (nilai == null || nilai.isEmpty)) return null;
    switch (r.tipe) {
      case TipeRuas.nik:
        return Validasi.nik(nilai);
      case TipeRuas.noKk:
        return Validasi.noKk(nilai);
      case TipeRuas.email:
        return Validasi.surel(nilai);
      case TipeRuas.telepon:
        return Validasi.noHp(nilai);
      case TipeRuas.teks:
      case TipeRuas.areaTeks:
      case TipeRuas.angka:
      case TipeRuas.tanggal:
      case TipeRuas.pilihan:
        return Validasi.wajib(nilai, label: r.label);
    }
  }

  Widget _bangunRuas(DefinisiRuas r) {
    switch (r.tipe) {
      case TipeRuas.areaTeks:
        return KotakIsian(
          label: r.label,
          petunjuk: r.petunjuk,
          pengatur: _pengatur[r.nama],
          barisMaks: 5,
          barisMin: 3,
          panjangMaks: r.panjangMaks,
          wajib: r.wajib,
          validator: (v) => _validatorRuas(r, v),
        );
      case TipeRuas.angka:
        return KotakIsian(
          label: r.label,
          petunjuk: r.petunjuk,
          pengatur: _pengatur[r.nama],
          tipeMasukan: TextInputType.number,
          formatter: [HanyaDigitFormatter(panjangMaks: r.panjangMaks)],
          wajib: r.wajib,
          validator: (v) => _validatorRuas(r, v),
        );
      case TipeRuas.nik:
      case TipeRuas.noKk:
        return KotakIsian(
          label: r.label,
          petunjuk: '16 digit',
          pengatur: _pengatur[r.nama],
          tipeMasukan: TextInputType.number,
          formatter: [HanyaDigitFormatter(panjangMaks: 16)],
          wajib: r.wajib,
          validator: (v) => _validatorRuas(r, v),
        );
      case TipeRuas.email:
        return KotakIsian(
          label: r.label,
          pengatur: _pengatur[r.nama],
          tipeMasukan: TextInputType.emailAddress,
          wajib: r.wajib,
          validator: (v) => _validatorRuas(r, v),
        );
      case TipeRuas.telepon:
        return KotakIsian(
          label: r.label,
          pengatur: _pengatur[r.nama],
          tipeMasukan: TextInputType.phone,
          wajib: r.wajib,
          validator: (v) => _validatorRuas(r, v),
        );
      case TipeRuas.tanggal:
        return KotakIsian(
          label: r.label,
          petunjuk: 'Pilih tanggal',
          pengatur: _pengatur[r.nama],
          bacaSaja: true,
          saatKetuk: () => _pilihTanggal(r.nama),
          ikonAkhir: const Icon(HugeIcons.strokeRoundedCalendar03, size: 20),
          wajib: r.wajib,
          validator: (v) => _validatorRuas(r, v),
        );
      case TipeRuas.pilihan:
        return _PilihanDropdown(
          label: r.label,
          pilihan: r.pilihan,
          pengatur: _pengatur[r.nama]!,
          wajib: r.wajib,
        );
      case TipeRuas.teks:
        return KotakIsian(
          label: r.label,
          petunjuk: r.petunjuk,
          pengatur: _pengatur[r.nama],
          wajib: r.wajib,
          validator: (v) => _validatorRuas(r, v),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(title: Text('Formulir ${widget.jenis.nama}')),
      body: SafeArea(
        top: false,
        child: Form(
          key: _kunci,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Jarak.layarH, Jarak.md, Jarak.layarH, 120),
            children: [
              Text('Data Permohonan', style: context.teks.titleMedium),
              const SizedBox(height: Jarak.md),
              for (final r in _formulir.ruas) ...[
                _bangunRuas(r),
                const SizedBox(height: Jarak.lg),
              ],
              const SizedBox(height: Jarak.xs),
              Text('Dokumen Pendukung', style: context.teks.titleMedium),
              const SizedBox(height: Jarak.md),
              for (final b in _formulir.berkas) ...[
                PengunggahBerkas(
                  label: b.label,
                  berkas: _berkas[b.nama],
                  wajib: b.wajib,
                  saatBerubah: (f) => setState(() => _berkas[b.nama] = f),
                ),
                const SizedBox(height: Jarak.lg),
              ],
              const SizedBox(height: Jarak.xs),
              KotakCentangSetuju(
                nilai: _setuju,
                saatBerubah: (v) => setState(() => _setuju = v),
                label:
                    'Saya menyatakan data yang diisi adalah benar dan menyetujui Kebijakan Privasi, Kebijakan Layanan, serta Penafian Ketersediaan Sistem.',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Jarak.layarH),
          child: TombolUtama(
            label: 'Kirim Permohonan',
            memuat: _kirim,
            saatTekan: _ajukan,
          ),
        ),
      ),
    );
  }
}

class _PilihanDropdown extends StatefulWidget {
  const _PilihanDropdown({
    required this.label,
    required this.pilihan,
    required this.pengatur,
    required this.wajib,
  });
  final String label;
  final List<String> pilihan;
  final TextEditingController pengatur;
  final bool wajib;

  @override
  State<_PilihanDropdown> createState() => _PilihanDropdownState();
}

class _PilihanDropdownState extends State<_PilihanDropdown> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.label, style: context.teks.titleSmall),
            if (widget.wajib)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text('*', style: context.teks.titleSmall?.copyWith(color: Warna.bahaya)),
              ),
          ],
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: widget.pengatur.text.isEmpty ? null : widget.pengatur.text,
          isExpanded: true,
          hint: const Text('Pilih opsi'),
          items: widget.pilihan
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          validator: (v) =>
              widget.wajib && (v == null || v.isEmpty) ? '${widget.label} wajib dipilih.' : null,
          onChanged: (v) {
            setState(() => widget.pengatur.text = v ?? '');
          },
        ),
      ],
    );
  }
}
