import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/activity/jenis_aktivitas.dart';
import '../../../core/activity/layanan_pencatat_aktivitas.dart';
import '../../../core/dialogs/dialog_aplikasi.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/network/penjaga_jaringan.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../core/utils/penunda.dart';
import '../../../shared/models/jenis_layanan.dart';
import '../../../shared/providers/penyedia_muat_global.dart';
import '../../../shared/providers/penyedia_pemberitahuan.dart';
import '../../../shared/providers/penyedia_permohonan.dart';
import '../../../shared/providers/penyedia_repositori.dart';
import '../../../shared/widgets/kondisi_galat.dart';
import '../../../shared/widgets/pemuat_lingkar.dart';
import '../../../shared/widgets/tombol_utama.dart';
import '../domain/definisi_formulir.dart';
import '../domain/detail_layanan.dart';
import '../providers/penyedia_layanan.dart';
import 'widgets/indikator_langkah.dart';
import 'widgets/pengunggah_berkas.dart';
import 'widgets/ruas_dinamis.dart';

class HalamanFormulirPermohonan extends ConsumerWidget {
  const HalamanFormulirPermohonan({super.key, required this.ringkasan});

  final RingkasanLayanan ringkasan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final detail = ref.watch(penyediaDetailLayanan(ringkasan.kode));

    return detail.when(
      loading: () => Scaffold(
        backgroundColor: Warna.latar,
        appBar: AppBar(title: Text(t.katalog(ringkasan.namaSingkat))),
        body: PemuatLingkar(pesan: t.mohonTungguSebentar),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: Warna.latar,
        appBar: AppBar(title: Text(t.katalog(ringkasan.namaSingkat))),
        body: KondisiGalat(
          pesan: pesanRamah(e, fallback: t.terjadiKesalahan, teks: t),
          saatCobaLagi: () =>
              ref.invalidate(penyediaDetailLayanan(ringkasan.kode)),
        ),
      ),
      data: (layanan) => _FormulirIsi(ringkasan: ringkasan, layanan: layanan),
    );
  }
}

class _FormulirIsi extends ConsumerStatefulWidget {
  const _FormulirIsi({required this.ringkasan, required this.layanan});

  final RingkasanLayanan ringkasan;
  final DetailLayanan layanan;

  @override
  ConsumerState<_FormulirIsi> createState() => _FormulirIsiState();
}

class _FormulirIsiState extends ConsumerState<_FormulirIsi> {
  late final List<GrupFormulir> _grup = widget.layanan.formulir;
  late final List<DefinisiDokumen> _dokumen = widget.layanan.slotDokumen;
  late final List<GlobalKey<FormState>> _kunciForm;
  final _pengaturHalaman = PageController();
  final _pembatas = Pembatas();

  final Map<String, String> _nilai = {};
  final Map<String, File?> _berkas = {};
  final Map<String, String> _galatBerkas = {};
  final Map<String, String> _galatRuas = {};
  int _langkah = 0;
  bool _mengirim = false;

  int get _jumlahLangkah => _grup.length + 2;
  int get _indeksDokumen => _grup.length;
  int get _indeksRingkasan => _grup.length + 1;

  @override
  void initState() {
    super.initState();
    _kunciForm = List.generate(_grup.length, (_) => GlobalKey<FormState>());
  }

  @override
  void dispose() {
    _pengaturHalaman.dispose();
    super.dispose();
  }

  String _judulLangkah(Teks t, int indeks) {
    if (indeks == _indeksDokumen) return t.unggahDokumenLangkah;
    if (indeks == _indeksRingkasan) return t.ringkasanLangkah;
    return t.katalog(_grup[indeks].judul);
  }

  bool _ruasTampil(DefinisiRuas ruas) =>
      ruas.kondisi == null || ruas.kondisi!.terpenuhi(_nilai);

  bool _dokumenTampil(DefinisiDokumen dokumen) =>
      dokumen.kondisi == null || dokumen.kondisi!.terpenuhi(_nilai);

  void _keLangkah(int tujuan) {
    setState(() => _langkah = tujuan);
    _pengaturHalaman.animateToPage(
      tujuan,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  bool _validasiLangkahSaatIni() {
    if (_langkah < _grup.length) {
      return _kunciForm[_langkah].currentState?.validate() ?? true;
    }
    if (_langkah == _indeksDokumen) {
      final t = ref.read(teksProvider);
      final galat = <String, String>{};
      for (final dokumen in _dokumen) {
        if (!_dokumenTampil(dokumen)) continue;
        if (dokumen.wajib && _berkas[dokumen.kunci] == null) {
          galat[dokumen.kunci] = t.wajibDiisi(t.katalog(dokumen.label));
        }
      }
      setState(() {
        _galatBerkas
          ..clear()
          ..addAll(galat);
      });
      return galat.isEmpty;
    }
    return true;
  }

  Future<void> _lanjut() async {
    FocusScope.of(context).unfocus();
    if (!_validasiLangkahSaatIni()) {
      context.tampilkanGalat(ref.read(teksProvider).periksaIsian);
      return;
    }
    if (_langkah < _indeksRingkasan) {
      _keLangkah(_langkah + 1);
      return;
    }
    await _kirim();
  }

  Future<void> _kirim() async {
    final jaringanOk = await PenjagaJaringan.cekUntukAksi(
      context: context,
      ref: ref,
    );
    if (!mounted || !jaringanOk) return;

    final t = ref.read(teksProvider);
    final boleh = _pembatas.cobaJalan(() async {
      setState(() => _mengirim = true);
      try {
        final hasil = await ref
            .read(penyediaMuatGlobal.notifier)
            .jalankan(
              () => ref
                  .read(penyediaRepositoriPermohonan)
                  .ajukan(
                    kodeLayanan: widget.layanan.kode,
                    dataFormulir: _bangunRuas(),
                    berkas: _bangunBerkas(),
                    wajibBerkas: _bangunWajibBerkas(),
                    labelBerkas: _bangunLabelBerkas(),
                    onProgressKeseluruhan: (progress) {
                      ref.read(penyediaMuatGlobal.notifier).perbaruiKemajuan(progress);
                    },
                  ),
              judul: t.mengirimPermohonan,
              pesan: t.mengunggahDokumenPesan,
            );
        if (!mounted) return;
        unawaited(
          LayananPencatatAktivitas.instance.catat(
            JenisAktivitas.kirimPermohonan,
            metadata: {'kode_layanan': widget.layanan.kode},
            sertakanLokasi: true,
          ),
        );
        ref.invalidate(penyediaPengaturRiwayat);
        ref.read(penyediaJumlahBelumDibaca.notifier).segarkan();
        context.pushReplacement(NamaRute.layananSukses, extra: hasil);
      } on KesalahanValidasi catch (e) {
        if (!mounted) return;
        _terapkanGalatValidasi(e);
      } on Kesalahan catch (e) {
        if (!mounted) return;
        await DialogAplikasi.tampilkanAlert<void>(
          context: context,
          judul: t.permohonanGagalKirim,
          pesan: e.pesan,
          nada: NadaDialog.bahaya,
        );
      } catch (_) {
        if (!mounted) return;
        context.tampilkanGalat(t.terjadiKesalahan);
      } finally {
        if (mounted) setState(() => _mengirim = false);
      }
    });
    if (!boleh && mounted) {
      context.tampilkanGalat(t.permohonanDiproses);
    }
  }

  void _terapkanGalatValidasi(KesalahanValidasi e) {
    final t = ref.read(teksProvider);
    final ruas = e.kesalahanRuas;
    if (ruas == null || ruas.isEmpty) {
      context.tampilkanGalat(e.pesan.isNotEmpty ? e.pesan : t.dataBelumValid);
      return;
    }

    final kunciDokumen = {for (final d in _dokumen) d.kunci};
    final galatRuas = <String, String>{};
    final galatDok = <String, String>{};
    ruas.forEach((kunci, pesan) {
      if (kunciDokumen.contains(kunci)) {
        galatDok[kunci] = pesan;
      } else {
        galatRuas[kunci] = pesan;
      }
    });

    setState(() {
      _galatRuas
        ..clear()
        ..addAll(galatRuas);
      _galatBerkas
        ..clear()
        ..addAll(galatDok);
    });

    final tujuan = _langkahPertamaBermasalah(galatRuas, galatDok);
    if (tujuan != null && tujuan != _langkah) {
      _keLangkah(tujuan);
    }
    context.tampilkanGalat(e.pesan.isNotEmpty ? e.pesan : t.dataBelumValid);
  }

  int? _langkahPertamaBermasalah(
    Map<String, String> galatRuas,
    Map<String, String> galatDok,
  ) {
    for (var i = 0; i < _grup.length; i++) {
      if (_grup[i].ruas.any((r) => galatRuas.containsKey(r.kunci))) return i;
    }
    if (galatDok.isNotEmpty) return _indeksDokumen;
    return null;
  }

  Map<String, String> _bangunRuas() {
    final hasil = <String, String>{};
    for (final grup in _grup) {
      for (final ruas in grup.ruas) {
        if (!_ruasTampil(ruas)) continue;
        final nilai = (_nilai[ruas.kunci] ?? '').trim();
        if (nilai.isNotEmpty) hasil[ruas.kunci] = nilai;
      }
    }
    return hasil;
  }

  Map<String, File> _bangunBerkas() {
    final hasil = <String, File>{};
    for (final dokumen in _dokumen) {
      if (!_dokumenTampil(dokumen)) continue;
      final berkas = _berkas[dokumen.kunci];
      if (berkas != null) hasil[dokumen.kunci] = berkas;
    }
    return hasil;
  }

  Map<String, bool> _bangunWajibBerkas() {
    final hasil = <String, bool>{};
    for (final dokumen in _dokumen) {
      if (!_dokumenTampil(dokumen)) continue;
      if (_berkas[dokumen.kunci] != null) hasil[dokumen.kunci] = dokumen.wajib;
    }
    return hasil;
  }

  Map<String, String> _bangunLabelBerkas() {
    final t = ref.read(teksProvider);
    final hasil = <String, String>{};
    for (final dokumen in _dokumen) {
      if (!_dokumenTampil(dokumen)) continue;
      if (_berkas[dokumen.kunci] != null) {
        hasil[dokumen.kunci] = t.katalog(dokumen.label);
      }
    }
    return hasil;
  }

  Future<bool> _konfirmasiKeluar() async {
    final adaIsi =
        _nilai.values.any((v) => v.trim().isNotEmpty) ||
        _berkas.values.any((v) => v != null);
    if (!adaIsi) return true;
    final t = ref.read(teksProvider);
    return DialogAplikasi.tampilkanKonfirmasi(
      context: context,
      judul: t.batalkanPengisianJudul,
      pesan: t.batalkanPengisianPesan,
      labelKonfirmasi: t.yaKeluar,
      labelBatal: t.lanjutMengisi,
      destruktif: true,
      nada: NadaDialog.peringatan,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (sudahPop, _) async {
        if (sudahPop || _mengirim) return;
        if (_langkah > 0) {
          _keLangkah(_langkah - 1);
          return;
        }
        final keluar = await _konfirmasiKeluar();
        if (keluar && context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: Warna.latar,
        appBar: AppBar(
          title: Text(t.katalog(widget.ringkasan.namaSingkat)),
          scrolledUnderElevation: 0,
          shape: const Border(
            bottom: BorderSide(color: Warna.garis, width: 0.6),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_langkah > 0) {
                _keLangkah(_langkah - 1);
                return;
              }
              final keluar = await _konfirmasiKeluar();
              if (keluar && mounted) {
                if (context.mounted) context.pop();
              }
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(IndikatorLangkah.tinggi),
            child: IndikatorLangkah(
              langkah: _langkah,
              jumlah: _jumlahLangkah,
              judul: _judulLangkah(t, _langkah),
              labelLangkah: t.langkahXDariY(_langkah + 1, _jumlahLangkah),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pengaturHalaman,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (var i = 0; i < _grup.length; i++)
                    _LangkahRuas(
                      kunciForm: _kunciForm[i],
                      grup: _grup[i],
                      nilai: _nilai,
                      galatRuas: _galatRuas,
                      ruasTampil: _ruasTampil,
                      saatUbah: (kunci, v) => setState(() {
                        _nilai[kunci] = v;
                        _galatRuas.remove(kunci);
                      }),
                    ),
                  _LangkahDokumen(
                    dokumen: _dokumen,
                    berkas: _berkas,
                    galat: _galatBerkas,
                    dokumenTampil: _dokumenTampil,
                    saatUbah: (kunci, berkas) => setState(() {
                      _berkas[kunci] = berkas;
                      _galatBerkas.remove(kunci);
                    }),
                  ),
                  _LangkahRingkasan(
                    grup: _grup,
                    dokumen: _dokumen,
                    nilai: _nilai,
                    berkas: _berkas,
                    ruasTampil: _ruasTampil,
                    dokumenTampil: _dokumenTampil,
                  ),
                ],
              ),
            ),
            _BilahNavigasi(
              langkah: _langkah,
              terakhir: _langkah == _indeksRingkasan,
              mengirim: _mengirim,
              saatKembali: _langkah == 0
                  ? null
                  : () => _keLangkah(_langkah - 1),
              saatLanjut: _lanjut,
            ),
          ],
        ),
      ),
    );
  }
}

class _LangkahRuas extends StatelessWidget {
  const _LangkahRuas({
    required this.kunciForm,
    required this.grup,
    required this.nilai,
    required this.galatRuas,
    required this.ruasTampil,
    required this.saatUbah,
  });

  final GlobalKey<FormState> kunciForm;
  final GrupFormulir grup;
  final Map<String, String> nilai;
  final Map<String, String> galatRuas;
  final bool Function(DefinisiRuas) ruasTampil;
  final void Function(String, String) saatUbah;

  @override
  Widget build(BuildContext context) {
    final tampil = grup.ruas.where(ruasTampil).toList();
    return Form(
      key: kunciForm,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          Jarak.layarH,
          Jarak.xl,
          Jarak.layarH,
          Jarak.xxxl,
        ),
        itemCount: tampil.length,
        separatorBuilder: (_, _) => const SizedBox(height: Jarak.lg),
        itemBuilder: (context, indeks) {
          final ruas = tampil[indeks];
          return RuasDinamis(
                key: ValueKey(ruas.kunci),
                definisi: ruas,
                nilai: nilai[ruas.kunci] ?? '',
                galat: galatRuas[ruas.kunci],
                saatUbah: (v) => saatUbah(ruas.kunci, v),
              )
              .animate(delay: (indeks * 30).ms)
              .fadeIn(duration: 240.ms, curve: Curves.easeOutCubic);
        },
      ),
    );
  }
}

class _LangkahDokumen extends ConsumerWidget {
  const _LangkahDokumen({
    required this.dokumen,
    required this.berkas,
    required this.galat,
    required this.dokumenTampil,
    required this.saatUbah,
  });

  final List<DefinisiDokumen> dokumen;
  final Map<String, File?> berkas;
  final Map<String, String> galat;
  final bool Function(DefinisiDokumen) dokumenTampil;
  final void Function(String, File?) saatUbah;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final tampil = dokumen.where(dokumenTampil).toList();
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        Jarak.layarH,
        Jarak.xl,
        Jarak.layarH,
        Jarak.xxxl,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(Jarak.md),
          decoration: BoxDecoration(
            color: Warna.infoLembut,
            borderRadius: BorderRadius.circular(Sudut.md),
          ),
          child: Row(
            children: [
              const Icon(
                HugeIcons.strokeRoundedInformationCircle,
                size: 18,
                color: Warna.info,
              ),
              const SizedBox(width: Jarak.sm),
              Expanded(
                child: Text(
                  t.infoUnggahDokumen,
                  style: context.teks.bodySmall?.copyWith(
                    color: Warna.info,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Jarak.xl),
        for (var i = 0; i < tampil.length; i++) ...[
          if (i > 0) const SizedBox(height: Jarak.md),
          PengunggahBerkas(
                dokumen: tampil[i],
                berkas: berkas[tampil[i].kunci],
                galat: galat[tampil[i].kunci],
                saatUbah: (b) => saatUbah(tampil[i].kunci, b),
              )
              .animate(delay: (i * 30).ms)
              .fadeIn(duration: 240.ms, curve: Curves.easeOutCubic),
        ],
      ],
    );
  }
}

class _LangkahRingkasan extends ConsumerWidget {
  const _LangkahRingkasan({
    required this.grup,
    required this.dokumen,
    required this.nilai,
    required this.berkas,
    required this.ruasTampil,
    required this.dokumenTampil,
  });

  final List<GrupFormulir> grup;
  final List<DefinisiDokumen> dokumen;
  final Map<String, String> nilai;
  final Map<String, File?> berkas;
  final bool Function(DefinisiRuas) ruasTampil;
  final bool Function(DefinisiDokumen) dokumenTampil;

  String _tampilkanNilai(Teks t, DefinisiRuas ruas) {
    final mentah = (nilai[ruas.kunci] ?? '').trim();
    if (mentah.isEmpty) return '—';
    switch (ruas.tipe) {
      case TipeRuas.pilihan:
        return ruas.pilihan
                .where((p) => p.nilai == mentah)
                .map((p) => t.katalog(p.label))
                .firstOrNull ??
            mentah;
      case TipeRuas.multiPilihan:
        final set = mentah.split(';').where((e) => e.isNotEmpty).toSet();
        final label = ruas.pilihan
            .where((p) => set.contains(p.nilai))
            .map((p) => t.katalog(p.label))
            .join(', ');
        return label.isEmpty ? mentah.replaceAll(';', ', ') : label;
      case TipeRuas.daftarNik:
        return mentah.split(';').where((e) => e.isNotEmpty).join(', ');
      case TipeRuas.perubahanBiodata:
        try {
          final raw = jsonDecode(mentah);
          if (raw is List) {
            return raw.whereType<Map>().map((e) {
              final el = e['elemen']?.toString() ?? '';
              final namaEl = ruas.pilihan
                      .where((p) => p.nilai == el)
                      .map((p) => t.katalog(p.label))
                      .firstOrNull ??
                  el;
              final nv = e['nilai_baru']?.toString() ?? '';
              return nv.isEmpty ? namaEl : '$namaEl: $nv';
            }).join(', ');
          }
        } catch (_) {}
        return mentah;
      default:
        return mentah;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        Jarak.layarH,
        Jarak.xl,
        Jarak.layarH,
        Jarak.xxxl,
      ),
      children: [
        Text(
          t.periksaSebelumKirim,
          style: context.teks.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: Jarak.xs),
        Text(
          t.periksaSebelumKirimSub,
          style: context.teks.bodySmall?.copyWith(color: Warna.teksKedua),
        ),
        const SizedBox(height: Jarak.xl),
        for (final g in grup) ...[
          if (g.ruas.where(ruasTampil).isNotEmpty) ...[
            _KartuRingkas(
              judul: t.katalog(g.judul),
              anak: [
                for (final ruas in g.ruas.where(ruasTampil))
                  _BarisRingkas(
                    label: t.katalog(ruas.label),
                    nilai: _tampilkanNilai(t, ruas),
                  ),
              ],
            ),
            const SizedBox(height: Jarak.md),
          ],
        ],
        _KartuRingkas(
          judul: t.dokumenTerunggah,
          anak: [
            for (final d in dokumen.where(dokumenTampil))
              _BarisRingkas(
                label: t.katalog(d.label),
                nilai: berkas[d.kunci] == null
                    ? (d.wajib ? t.belumDiunggah : '—')
                    : berkas[d.kunci]!.uri.pathSegments.last,
                bahaya: d.wajib && berkas[d.kunci] == null,
              ),
          ],
        ),
      ],
    );
  }
}

class _KartuRingkas extends StatelessWidget {
  const _KartuRingkas({required this.judul, required this.anak});

  final String judul;
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Jarak.lg),
      decoration: BoxDecoration(
        color: Warna.permukaan,
        borderRadius: BorderRadius.circular(Sudut.lg),
        border: Border.all(color: Warna.garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: context.teks.labelLarge?.copyWith(
              color: Warna.primerGelap,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: Jarak.sm),
          ...anak,
        ],
      ),
    );
  }
}

class _BarisRingkas extends StatelessWidget {
  const _BarisRingkas({
    required this.label,
    required this.nilai,
    this.bahaya = false,
  });

  final String label;
  final String nilai;
  final bool bahaya;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: context.teks.bodySmall?.copyWith(color: Warna.teksKetiga),
            ),
          ),
          const SizedBox(width: Jarak.sm),
          Expanded(
            child: Text(
              nilai,
              style: context.teks.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: bahaya ? Warna.bahaya : Warna.teksUtama,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BilahNavigasi extends ConsumerWidget {
  const _BilahNavigasi({
    required this.langkah,
    required this.terakhir,
    required this.mengirim,
    required this.saatKembali,
    required this.saatLanjut,
  });

  final int langkah;
  final bool terakhir;
  final bool mengirim;
  final VoidCallback? saatKembali;
  final VoidCallback saatLanjut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    return Container(
      decoration: const BoxDecoration(
        color: Warna.permukaan,
        border: Border(top: BorderSide(color: Warna.garis, width: 0.6)),
      ),
      padding: EdgeInsets.fromLTRB(
        Jarak.layarH,
        Jarak.md,
        Jarak.layarH,
        Jarak.md + context.aman.bottom,
      ),
      child: Row(
        children: [
          if (saatKembali != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: mengirim ? null : saatKembali,
                child: Text(t.kembali),
              ),
            ),
            const SizedBox(width: Jarak.md),
          ],
          Expanded(
            flex: 2,
            child: TombolUtama(
              label: terakhir ? t.kirimPermohonan : t.lanjut,
              memuat: mengirim,
              saatTekan: saatLanjut,
            ),
          ),
        ],
      ),
    );
  }
}
