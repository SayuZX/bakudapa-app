import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../core/extensions/konteks.dart';
import '../../core/localization/teks.dart';
import '../../core/theme/dimensi.dart';
import '../../core/theme/warna.dart';
import '../../features/wilayah/providers/penyedia_wilayah.dart';
import '../models/wilayah.dart';

class HasilDomisili {
  const HasilDomisili({
    required this.kabupaten,
    required this.kecamatan,
    required this.desa,
  });

  final Wilayah kabupaten;
  final Wilayah kecamatan;
  final Wilayah desa;
}

class PemilihDomisili extends ConsumerWidget {
  const PemilihDomisili({
    super.key,
    required this.label,
    required this.kabupaten,
    required this.kecamatan,
    required this.desa,
    required this.saatPilih,
    this.wajib = false,
    this.galat,
  });

  final String label;
  final Wilayah? kabupaten;
  final Wilayah? kecamatan;
  final Wilayah? desa;
  final ValueChanged<HasilDomisili> saatPilih;
  final bool wajib;
  final String? galat;

  bool get _lengkap => kabupaten != null && kecamatan != null && desa != null;

  String _ringkas() {
    final bagian = [
      desa?.nama,
      kecamatan?.nama,
      kabupaten?.nama,
    ].where((e) => e != null && e.isNotEmpty).toList();
    return bagian.join(' · ');
  }

  Future<void> _buka(BuildContext context) async {
    final hasil = await showModalBottomSheet<HasilDomisili>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Warna.permukaan,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _LembarDomisili(
        kabupatenAwal: kabupaten,
        kecamatanAwal: kecamatan,
        desaAwal: desa,
      ),
    );
    if (hasil != null) saatPilih(hasil);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: context.teks.titleSmall),
            if (wajib) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: context.teks.titleSmall?.copyWith(color: Warna.bahaya),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _buka(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Warna.netral25,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: galat != null ? Warna.bahaya : Warna.garis,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  HugeIcons.strokeRoundedLocation01,
                  size: 18,
                  color: Warna.teksKedua,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _lengkap ? _ringkas() : t.pilihDomisili,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.teks.bodyMedium?.copyWith(
                      color: _lengkap ? Warna.teksUtama : Warna.teksKetiga,
                      fontWeight: _lengkap ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                const Icon(
                  HugeIcons.strokeRoundedArrowRight01,
                  size: 18,
                  color: Warna.teksKedua,
                ),
              ],
            ),
          ),
        ),
        if (galat != null) ...[
          const SizedBox(height: 4),
          Text(
            galat!,
            style: context.teks.bodySmall?.copyWith(color: Warna.bahaya),
          ),
        ],
      ],
    );
  }
}

class _LembarDomisili extends ConsumerStatefulWidget {
  const _LembarDomisili({
    required this.kabupatenAwal,
    required this.kecamatanAwal,
    required this.desaAwal,
  });

  final Wilayah? kabupatenAwal;
  final Wilayah? kecamatanAwal;
  final Wilayah? desaAwal;

  @override
  ConsumerState<_LembarDomisili> createState() => _LembarDomisiliState();
}

class _LembarDomisiliState extends ConsumerState<_LembarDomisili> {
  final _cari = TextEditingController();
  String _kueri = '';
  int _level = 0;
  Wilayah? _kabupaten;
  Wilayah? _kecamatan;
  Wilayah? _desa;

  @override
  void initState() {
    super.initState();
    _kabupaten = widget.kabupatenAwal;
    _kecamatan = widget.kecamatanAwal;
    _desa = widget.desaAwal;
  }

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  void _keLevel(int level) {
    if (level == _level) return;
    setState(() {
      _level = level;
      _cari.clear();
      _kueri = '';
    });
  }

  void _pilih(Wilayah w) {
    if (_level == 0) {
      final berubah = w.kode != _kabupaten?.kode;
      setState(() {
        _kabupaten = w;
        if (berubah) {
          _kecamatan = null;
          _desa = null;
        }
        _level = 1;
        _cari.clear();
        _kueri = '';
      });
    } else if (_level == 1) {
      final berubah = w.kode != _kecamatan?.kode;
      setState(() {
        _kecamatan = w;
        if (berubah) _desa = null;
        _level = 2;
        _cari.clear();
        _kueri = '';
      });
    } else {
      _desa = w;
      Navigator.of(context).pop(
        HasilDomisili(
          kabupaten: _kabupaten!,
          kecamatan: _kecamatan!,
          desa: w,
        ),
      );
    }
  }

  AsyncValue<List<Wilayah>> _opsi() {
    switch (_level) {
      case 0:
        return ref.watch(penyediaKabupaten);
      case 1:
        return ref.watch(penyediaKecamatan(_kabupaten!.kode));
      default:
        return ref.watch(penyediaDesa(_kecamatan!.kode));
    }
  }

  String _judul(Teks t) {
    switch (_level) {
      case 0:
        return t.pilihKabupaten;
      case 1:
        return t.pilihKecamatan;
      default:
        return t.pilihDesa;
    }
  }

  Wilayah? _terpilihLevel() {
    switch (_level) {
      case 0:
        return _kabupaten;
      case 1:
        return _kecamatan;
      default:
        return _desa;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);
    final bawah = MediaQuery.of(context).viewInsets.bottom;
    final tinggi = MediaQuery.of(context).size.height * 0.75;
    final opsi = _opsi();

    return Padding(
      padding: EdgeInsets.only(bottom: bawah),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: tinggi),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Jarak.layarH,
                Jarak.lg,
                Jarak.sm,
                Jarak.sm,
              ),
              child: Row(
                children: [
                  if (_level > 0)
                    IconButton(
                      onPressed: () => _keLevel(_level - 1),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        HugeIcons.strokeRoundedArrowLeft01,
                        size: 22,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      _judul(t),
                      style: context.teks.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      HugeIcons.strokeRoundedCancel01,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            _Langkah(
              kabupaten: _kabupaten,
              kecamatan: _kecamatan,
              level: _level,
              saatKetuk: _keLevel,
            ),
            if ((opsi.valueOrNull?.length ?? 0) > 8)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Jarak.layarH,
                  Jarak.sm,
                  Jarak.layarH,
                  Jarak.sm,
                ),
                child: TextField(
                  controller: _cari,
                  onChanged: (v) => setState(() => _kueri = v),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: t.cariWilayah,
                    prefixIcon: const Icon(
                      HugeIcons.strokeRoundedSearch01,
                      size: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            Flexible(
              child: opsi.when(
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(vertical: Jarak.xxxl),
                  child: Center(
                    child: LoadingAnimationWidget.fourRotatingDots(
                      color: Warna.primer,
                      size: 40,
                    ),
                  ),
                ),
                error: (_, _) => Padding(
                  padding: const EdgeInsets.all(Jarak.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.gagalMuatWilayah,
                        style: context.teks.bodyMedium?.copyWith(
                          color: Warna.teksKedua,
                        ),
                      ),
                      const SizedBox(height: Jarak.md),
                      OutlinedButton(
                        onPressed: () => setState(() {}),
                        child: Text(t.cobaLagi),
                      ),
                    ],
                  ),
                ),
                data: (semua) {
                  final terpilih = _terpilihLevel();
                  final terfilter = _kueri.isEmpty
                      ? semua
                      : semua
                            .where(
                              (w) => w.nama.toLowerCase().contains(
                                _kueri.toLowerCase(),
                              ),
                            )
                            .toList();
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: terfilter.length,
                    itemBuilder: (_, i) {
                      final w = terfilter[i];
                      final aktif = w.kode == terpilih?.kode;
                      return ListTile(
                        title: Text(w.nama),
                        trailing: aktif
                            ? const Icon(
                                HugeIcons.strokeRoundedTick02,
                                color: Warna.primer,
                                size: 20,
                              )
                            : null,
                        onTap: () => _pilih(w),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: Jarak.sm),
          ],
        ),
      ),
    );
  }
}

class _Langkah extends StatelessWidget {
  const _Langkah({
    required this.kabupaten,
    required this.kecamatan,
    required this.level,
    required this.saatKetuk,
  });

  final Wilayah? kabupaten;
  final Wilayah? kecamatan;
  final int level;
  final ValueChanged<int> saatKetuk;

  @override
  Widget build(BuildContext context) {
    if (kabupaten == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(Jarak.layarH, 0, Jarak.layarH, Jarak.sm),
      child: Wrap(
        spacing: Jarak.sm,
        runSpacing: Jarak.xs,
        children: [
          _Cip(
            teks: kabupaten!.nama,
            aktif: level == 0,
            saatKetuk: () => saatKetuk(0),
          ),
          if (kecamatan != null)
            _Cip(
              teks: kecamatan!.nama,
              aktif: level == 1,
              saatKetuk: () => saatKetuk(1),
            ),
        ],
      ),
    );
  }
}

class _Cip extends StatelessWidget {
  const _Cip({
    required this.teks,
    required this.aktif,
    required this.saatKetuk,
  });

  final String teks;
  final bool aktif;
  final VoidCallback saatKetuk;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: saatKetuk,
      borderRadius: BorderRadius.circular(Sudut.pil),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: aktif ? Warna.primer.withValues(alpha: 0.12) : Warna.netral100,
          borderRadius: BorderRadius.circular(Sudut.pil),
          border: Border.all(
            color: aktif ? Warna.primer : Warna.garis,
          ),
        ),
        child: Text(
          teks,
          style: context.teks.labelMedium?.copyWith(
            color: aktif ? Warna.primer : Warna.teksKedua,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
