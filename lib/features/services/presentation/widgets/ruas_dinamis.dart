import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../../core/utils/validasi.dart';
import '../../../../shared/widgets/kotak_isian.dart';
import '../../domain/definisi_formulir.dart';

class RuasDinamis extends ConsumerWidget {
  const RuasDinamis({
    super.key,
    required this.definisi,
    required this.nilai,
    required this.saatUbah,
    this.galat,
  });

  final DefinisiRuas definisi;
  final String nilai;
  final ValueChanged<String> saatUbah;
  final String? galat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final field = _bangunField(context, ref);
    if (galat == null || galat!.isEmpty) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        field,
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 4),
          child: Text(
            galat!,
            style: context.teks.bodySmall?.copyWith(color: Warna.bahaya),
          ),
        ),
      ],
    );
  }

  Widget _bangunField(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final label = t.katalog(definisi.label);
    final placeholder =
        definisi.placeholder == null ? null : t.katalog(definisi.placeholder!);
    switch (definisi.tipe) {
      case TipeRuas.teks:
        final angkaMurni = definisi.hanyaAngka || definisi.nomorIdentitas16;
        return KotakIsian(
          label: label,
          wajib: definisi.wajib,
          petunjuk: placeholder,
          nilaiAwal: nilai,
          panjangMaks: definisi.panjangMaks,
          tipeMasukan:
              angkaMurni ? TextInputType.number : TextInputType.text,
          formatter: angkaMurni
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          saatBerubah: saatUbah,
          validator: (v) => _validasiTeks(t, label, v),
        );
      case TipeRuas.email:
        return KotakIsian(
          label: label,
          wajib: definisi.wajib,
          petunjuk: placeholder,
          nilaiAwal: nilai,
          panjangMaks: definisi.panjangMaks,
          tipeMasukan: TextInputType.emailAddress,
          saatBerubah: saatUbah,
          validator: (v) => _validasiEmail(t, label, v),
        );
      case TipeRuas.angka:
        return KotakIsian(
          label: label,
          wajib: definisi.wajib,
          petunjuk: placeholder,
          nilaiAwal: nilai,
          tipeMasukan: TextInputType.numberWithOptions(
            decimal: definisi.desimal,
          ),
          formatter: [
            if (definisi.desimal)
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))
            else
              FilteringTextInputFormatter.digitsOnly,
          ],
          saatBerubah: (v) => saatUbah(v.replaceAll(',', '.')),
          validator: (v) => _validasiAngka(t, label, v),
        );
      case TipeRuas.areaTeks:
        return KotakIsian(
          label: label,
          wajib: definisi.wajib,
          petunjuk: placeholder,
          nilaiAwal: nilai,
          barisMin: 3,
          barisMaks: 5,
          panjangMaks: definisi.panjangMaks,
          tipeMasukan: TextInputType.multiline,
          saatBerubah: saatUbah,
          validator: (v) => _validasiTeks(t, label, v),
        );
      case TipeRuas.tanggal:
        return _RuasPemilih(
          definisi: definisi,
          label: label,
          placeholder: placeholder,
          tampilan: nilai,
          ikon: HugeIcons.strokeRoundedCalendar03,
          teks: t,
          saatKetuk: () => _pilihTanggal(context, label),
        );
      case TipeRuas.jam:
        return _RuasPemilih(
          definisi: definisi,
          label: label,
          placeholder: placeholder,
          tampilan: nilai,
          ikon: HugeIcons.strokeRoundedClock01,
          teks: t,
          saatKetuk: () => _pilihJam(context, label),
        );
      case TipeRuas.pilihan:
        final labelTerpilih = definisi.pilihan
            .where((p) => p.nilai == nilai)
            .map((p) => t.katalog(p.label))
            .firstOrNull;
        return _RuasPemilih(
          definisi: definisi,
          label: label,
          placeholder: placeholder,
          tampilan: labelTerpilih ?? '',
          ikon: HugeIcons.strokeRoundedArrowDown01,
          teks: t,
          saatKetuk: () => _pilihOpsi(context, t, label),
        );
      case TipeRuas.multiPilihan:
        final terpilih = nilai
            .split(';')
            .where((e) => e.isNotEmpty)
            .toSet();
        final tampilan = definisi.pilihan
            .where((p) => terpilih.contains(p.nilai))
            .map((p) => t.katalog(p.label))
            .join(', ');
        return _RuasPemilih(
          definisi: definisi,
          label: label,
          placeholder: placeholder,
          tampilan: tampilan,
          ikon: HugeIcons.strokeRoundedCheckList,
          teks: t,
          saatKetuk: () => _pilihMulti(context, t, label, terpilih),
        );
      case TipeRuas.daftarNik:
        return _RuasDaftarNik(
          definisi: definisi,
          label: label,
          placeholder: placeholder,
          nilai: nilai,
          teks: t,
          saatUbah: saatUbah,
        );
      case TipeRuas.perubahanBiodata:
        return _RuasPerubahanBiodata(
          definisi: definisi,
          label: label,
          nilai: nilai,
          teks: t,
          saatUbah: saatUbah,
        );
    }
  }

  Future<void> _pilihMulti(
    BuildContext context,
    Teks t,
    String label,
    Set<String> terpilih,
  ) async {
    final hasil = await showModalBottomSheet<List<String>>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Warna.permukaan,
      builder: (_) => _LembarMultiPilihan(
        judul: label,
        pilihan: definisi.pilihan,
        terpilih: terpilih,
        teks: t,
      ),
    );
    if (hasil != null) saatUbah(hasil.join(';'));
  }

  String? _validasiTeks(Teks t, String label, String? v) {
    final isi = v?.trim() ?? '';
    if (definisi.wajib && isi.isEmpty) {
      return t.wajibDiisi(label);
    }
    if (isi.isEmpty) return null;
    if (definisi.nomorIdentitas16) {
      if (definisi.adalahNik) return Validasi.nik(isi);
      if (definisi.adalahNoKk) return Validasi.noKk(isi);
      final digit = isi.replaceAll(RegExp(r'\s'), '');
      if (digit.length != 16 || !RegExp(r'^\d{16}$').hasMatch(digit)) {
        return t.harusJumlahDigit(label, 16);
      }
      return null;
    }
    final min = definisi.panjangMin;
    if (min != null && isi.length < min) {
      return t.minimalKarakter(label, min);
    }
    return null;
  }

  String? _validasiEmail(Teks t, String label, String? v) {
    final isi = v?.trim() ?? '';
    if (definisi.wajib && isi.isEmpty) {
      return t.wajibDiisi(label);
    }
    if (isi.isEmpty) return null;
    return Validasi.surel(isi);
  }

  String? _validasiAngka(Teks t, String label, String? v) {
    final isi = (v ?? '').replaceAll(',', '.').trim();
    if (definisi.wajib && isi.isEmpty) {
      return t.wajibDiisi(label);
    }
    if (isi.isEmpty) return null;
    final angka = double.tryParse(isi);
    if (angka == null) return t.angkaTidakValid;
    if (definisi.min != null && angka < definisi.min!) {
      return t.minimalNilai(_angkaRapi(definisi.min!));
    }
    if (definisi.maks != null && angka > definisi.maks!) {
      return t.maksimalNilai(_angkaRapi(definisi.maks!));
    }
    return null;
  }

  String _angkaRapi(double angka) =>
      angka == angka.roundToDouble() ? '${angka.toInt()}' : '$angka';

  Future<void> _pilihTanggal(BuildContext context, String label) async {
    final sekarang = DateTime.now();
    final awal = DateTime.tryParse(nilai) ?? sekarang;
    final hasil = await showDatePicker(
      context: context,
      initialDate: awal.isAfter(sekarang) ? sekarang : awal,
      firstDate: DateTime(1900),
      lastDate: sekarang,
      helpText: label,
    );
    if (hasil != null) {
      saatUbah(
        '${hasil.year.toString().padLeft(4, '0')}-'
        '${hasil.month.toString().padLeft(2, '0')}-'
        '${hasil.day.toString().padLeft(2, '0')}',
      );
    }
  }

  Future<void> _pilihJam(BuildContext context, String label) async {
    final bagian = nilai.split(':');
    final hasil = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(bagian.first) ?? 8,
        minute: bagian.length > 1 ? int.tryParse(bagian[1]) ?? 0 : 0,
      ),
      helpText: label,
    );
    if (hasil != null) {
      saatUbah(
        '${hasil.hour.toString().padLeft(2, '0')}:'
        '${hasil.minute.toString().padLeft(2, '0')}',
      );
    }
  }

  Future<void> _pilihOpsi(BuildContext context, Teks t, String label) async {
    final hasil = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Warna.permukaan,
      builder: (sheetContext) => _LembarPilihan(
        judul: label,
        pilihan: definisi.pilihan,
        terpilih: nilai,
        teks: t,
      ),
    );
    if (hasil != null) saatUbah(hasil);
  }
}

class _RuasPemilih extends StatelessWidget {
  const _RuasPemilih({
    required this.definisi,
    required this.label,
    required this.placeholder,
    required this.tampilan,
    required this.ikon,
    required this.teks,
    required this.saatKetuk,
  });

  final DefinisiRuas definisi;
  final String label;
  final String? placeholder;
  final String tampilan;
  final IconData ikon;
  final Teks teks;
  final VoidCallback saatKetuk;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: ValueKey('${definisi.kunci}_$tampilan'),
      initialValue: tampilan,
      validator: (_) {
        if (definisi.wajib && tampilan.trim().isEmpty) {
          return teks.wajibDiisi(label);
        }
        return null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: context.teks.titleSmall?.copyWith(
                    color: Warna.teksUtama,
                  ),
                ),
                if (definisi.wajib)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      '*',
                      style: context.teks.titleSmall?.copyWith(
                        color: Warna.bahaya,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: saatKetuk,
              borderRadius: BorderRadius.circular(Sudut.md),
              child: InputDecorator(
                decoration: InputDecoration(
                  hintText: placeholder ?? teks.pilihLabel(label),
                  errorText: state.errorText,
                  suffixIcon: Icon(ikon, size: 18, color: Warna.teksKedua),
                ),
                isEmpty: tampilan.isEmpty,
                child: Text(
                  tampilan,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.teks.bodyMedium,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LabelRuas extends StatelessWidget {
  const _LabelRuas({required this.label, required this.wajib});

  final String label;
  final bool wajib;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: context.teks.titleSmall?.copyWith(color: Warna.teksUtama),
        ),
        if (wajib)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '*',
              style: context.teks.titleSmall?.copyWith(color: Warna.bahaya),
            ),
          ),
      ],
    );
  }
}

class _LembarMultiPilihan extends StatefulWidget {
  const _LembarMultiPilihan({
    required this.judul,
    required this.pilihan,
    required this.terpilih,
    required this.teks,
  });

  final String judul;
  final List<PilihanRuas> pilihan;
  final Set<String> terpilih;
  final Teks teks;

  @override
  State<_LembarMultiPilihan> createState() => _LembarMultiPilihanState();
}

class _LembarMultiPilihanState extends State<_LembarMultiPilihan> {
  late final Set<String> _terpilih = {...widget.terpilih};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Jarak.layarH,
                0,
                Jarak.layarH,
                Jarak.md,
              ),
              child: Text(
                widget.judul,
                style: context.teks.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: widget.pilihan.length,
                separatorBuilder: (_, _) => const Divider(
                  indent: Jarak.layarH,
                  endIndent: Jarak.layarH,
                  color: Warna.pemisah,
                ),
                itemBuilder: (context, indeks) {
                  final opsi = widget.pilihan[indeks];
                  final aktif = _terpilih.contains(opsi.nilai);
                  return InkWell(
                    onTap: () => setState(() {
                      if (aktif) {
                        _terpilih.remove(opsi.nilai);
                      } else {
                        _terpilih.add(opsi.nilai);
                      }
                    }),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Jarak.layarH,
                        vertical: Jarak.md,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            aktif
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            size: 20,
                            color: aktif ? Warna.primer : Warna.teksKetiga,
                          ),
                          const SizedBox(width: Jarak.md),
                          Expanded(
                            child: Text(
                              widget.teks.katalog(opsi.label),
                              style: context.teks.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
                height: 50,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_terpilih.toList()),
                  style: FilledButton.styleFrom(
                    backgroundColor: Warna.primer,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(widget.teks.selesai),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuasDaftarNik extends StatefulWidget {
  const _RuasDaftarNik({
    required this.definisi,
    required this.label,
    required this.placeholder,
    required this.nilai,
    required this.teks,
    required this.saatUbah,
  });

  final DefinisiRuas definisi;
  final String label;
  final String? placeholder;
  final String nilai;
  final Teks teks;
  final ValueChanged<String> saatUbah;

  @override
  State<_RuasDaftarNik> createState() => _RuasDaftarNikState();
}

class _RuasDaftarNikState extends State<_RuasDaftarNik> {
  late List<TextEditingController> _kontroler;

  @override
  void initState() {
    super.initState();
    final awal =
        widget.nilai.split(';').where((e) => e.trim().isNotEmpty).toList();
    _kontroler = (awal.isEmpty ? [''] : awal)
        .map((e) => TextEditingController(text: e.trim()))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _kontroler) {
      c.dispose();
    }
    super.dispose();
  }

  void _sync() => widget.saatUbah(
        _kontroler
            .map((c) => c.text.trim())
            .where((e) => e.isNotEmpty)
            .join(';'),
      );

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.nilai,
      validator: (_) {
        final isi = _kontroler
            .map((c) => c.text.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (widget.definisi.wajib && isi.isEmpty) {
          return widget.teks.wajibDiisi(widget.label);
        }
        for (final nik in isi) {
          if (nik.length != 16 || !RegExp(r'^\d{16}$').hasMatch(nik)) {
            return widget.teks.harusJumlahDigit(widget.teks.nikLabel, 16);
          }
        }
        return null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LabelRuas(label: widget.label, wajib: widget.definisi.wajib),
            const SizedBox(height: 6),
            for (var i = 0; i < _kontroler.length; i++) ...[
              if (i > 0) const SizedBox(height: Jarak.sm),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _kontroler[i],
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                      decoration: InputDecoration(
                        hintText:
                            widget.placeholder ?? '${widget.teks.nikLabel} ${i + 1}',
                        counterText: '',
                      ),
                      onChanged: (_) => _sync(),
                    ),
                  ),
                  if (_kontroler.length > 1)
                    IconButton(
                      onPressed: () => setState(() {
                        _kontroler.removeAt(i).dispose();
                        _sync();
                      }),
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        size: 20,
                        color: Warna.bahaya,
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: Jarak.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () =>
                    setState(() => _kontroler.add(TextEditingController())),
                icon: const Icon(Icons.add, size: 18),
                label: Text(widget.teks.tambahNik),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  state.errorText!,
                  style: context.teks.bodySmall?.copyWith(color: Warna.bahaya),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EntriBiodata {
  _EntriBiodata({required this.elemen, required this.kontroler});
  String elemen;
  final TextEditingController kontroler;
}

class _RuasPerubahanBiodata extends StatefulWidget {
  const _RuasPerubahanBiodata({
    required this.definisi,
    required this.label,
    required this.nilai,
    required this.teks,
    required this.saatUbah,
  });

  final DefinisiRuas definisi;
  final String label;
  final String nilai;
  final Teks teks;
  final ValueChanged<String> saatUbah;

  @override
  State<_RuasPerubahanBiodata> createState() => _RuasPerubahanBiodataState();
}

class _RuasPerubahanBiodataState extends State<_RuasPerubahanBiodata> {
  final List<_EntriBiodata> _entri = [];

  @override
  void initState() {
    super.initState();
    try {
      final raw = jsonDecode(widget.nilai);
      if (raw is List) {
        for (final item in raw) {
          if (item is Map) {
            _entri.add(
              _EntriBiodata(
                elemen: item['elemen']?.toString() ?? '',
                kontroler: TextEditingController(
                  text: item['nilai_baru']?.toString() ?? '',
                ),
              ),
            );
          }
        }
      }
    } catch (_) {}
    if (_entri.isEmpty) {
      _entri.add(_EntriBiodata(elemen: '', kontroler: TextEditingController()));
    }
  }

  @override
  void dispose() {
    for (final e in _entri) {
      e.kontroler.dispose();
    }
    super.dispose();
  }

  void _sync() {
    final data = [
      for (final e in _entri)
        if (e.elemen.isNotEmpty)
          {'elemen': e.elemen, 'nilai_baru': e.kontroler.text.trim()},
    ];
    widget.saatUbah(data.isEmpty ? '' : jsonEncode(data));
  }

  String _labelElemen(String nilai) => widget.definisi.pilihan
      .where((p) => p.nilai == nilai)
      .map((p) => widget.teks.katalog(p.label))
      .firstOrNull ??
      '';

  Future<void> _pilihElemen(int indeks) async {
    final hasil = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Warna.permukaan,
      builder: (_) => _LembarPilihan(
        judul: widget.teks.pilihElemen,
        pilihan: widget.definisi.pilihan,
        terpilih: _entri[indeks].elemen,
        teks: widget.teks,
      ),
    );
    if (hasil != null) {
      setState(() {
        _entri[indeks].elemen = hasil;
        _sync();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.nilai,
      validator: (_) {
        final isi = _entri.where((e) => e.elemen.isNotEmpty).toList();
        if (widget.definisi.wajib && isi.isEmpty) {
          return widget.teks.wajibDiisi(widget.label);
        }
        for (final e in isi) {
          if (e.kontroler.text.trim().isEmpty) {
            return widget.teks.wajibDiisi(widget.teks.nilaiBaru);
          }
        }
        return null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LabelRuas(label: widget.label, wajib: widget.definisi.wajib),
            const SizedBox(height: 6),
            for (var i = 0; i < _entri.length; i++) ...[
              if (i > 0) const SizedBox(height: Jarak.md),
              Container(
                padding: const EdgeInsets.all(Jarak.md),
                decoration: BoxDecoration(
                  color: Warna.netral50,
                  borderRadius: BorderRadius.circular(Sudut.md),
                  border: Border.all(color: Warna.garis),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pilihElemen(i),
                            borderRadius: BorderRadius.circular(Sudut.md),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                hintText: widget.teks.pilihElemen,
                                suffixIcon: const Icon(
                                  HugeIcons.strokeRoundedArrowDown01,
                                  size: 18,
                                  color: Warna.teksKedua,
                                ),
                              ),
                              isEmpty: _entri[i].elemen.isEmpty,
                              child: Text(
                                _labelElemen(_entri[i].elemen),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.teks.bodyMedium,
                              ),
                            ),
                          ),
                        ),
                        if (_entri.length > 1)
                          IconButton(
                            onPressed: () => setState(() {
                              _entri.removeAt(i).kontroler.dispose();
                              _sync();
                            }),
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 20,
                              color: Warna.bahaya,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: Jarak.sm),
                    TextFormField(
                      controller: _entri[i].kontroler,
                      decoration: InputDecoration(hintText: widget.teks.nilaiBaru),
                      onChanged: (_) => _sync(),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: Jarak.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _entri.add(
                      _EntriBiodata(
                        elemen: '',
                        kontroler: TextEditingController(),
                      ),
                    )),
                icon: const Icon(Icons.add, size: 18),
                label: Text(widget.teks.tambahPerubahan),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  state.errorText!,
                  style: context.teks.bodySmall?.copyWith(color: Warna.bahaya),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LembarPilihan extends StatelessWidget {
  const _LembarPilihan({
    required this.judul,
    required this.pilihan,
    required this.terpilih,
    required this.teks,
  });

  final String judul;
  final List<PilihanRuas> pilihan;
  final String terpilih;
  final Teks teks;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Jarak.layarH,
                0,
                Jarak.layarH,
                Jarak.md,
              ),
              child: Text(
                judul,
                style: context.teks.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: Jarak.lg),
                itemCount: pilihan.length,
                separatorBuilder: (_, _) => const Divider(
                  indent: Jarak.layarH,
                  endIndent: Jarak.layarH,
                  color: Warna.pemisah,
                ),
                itemBuilder: (context, indeks) {
                  final opsi = pilihan[indeks];
                  final aktif = opsi.nilai == terpilih;
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(opsi.nilai),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Jarak.layarH,
                        vertical: Jarak.md,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              teks.katalog(opsi.label),
                              style: context.teks.bodyMedium?.copyWith(
                                fontWeight:
                                    aktif ? FontWeight.w700 : FontWeight.w500,
                                color: aktif
                                    ? Warna.primer
                                    : Warna.teksUtama,
                              ),
                            ),
                          ),
                          if (aktif)
                            const Icon(
                              HugeIcons.strokeRoundedTick02,
                              size: 18,
                              color: Warna.primer,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
