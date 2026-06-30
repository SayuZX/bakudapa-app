import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/ai/model_ai_chat.dart';
import '../../../core/localization/teks.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/router/navigasi_aman.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/models/jenis_layanan.dart';
import '../../../shared/providers/penyedia_ai_chat.dart';
import '../../../shared/providers/penyedia_otentikasi.dart';
import 'widgets/bilah_input_ai.dart';
import 'widgets/gelembung_pesan_ai.dart';
import 'widgets/indikator_mengetik_ai.dart';
import 'widgets/sambutan_ai.dart';

class HalamanAiChat extends ConsumerStatefulWidget {
  const HalamanAiChat({super.key});

  @override
  ConsumerState<HalamanAiChat> createState() => _HalamanAiChatState();
}

class _HalamanAiChatState extends ConsumerState<HalamanAiChat> {
  final _pengaturInput = TextEditingController();
  final _pengaturGulir = ScrollController();
  bool _tampilkanKeBawah = false;

  @override
  void initState() {
    super.initState();
    _pengaturGulir.addListener(_pantauGulir);
  }

  void _pantauGulir() {
    if (!_pengaturGulir.hasClients) return;
    final pos = _pengaturGulir.position;
    final tampil = (pos.maxScrollExtent - pos.pixels) > 280;
    if (tampil != _tampilkanKeBawah) {
      setState(() => _tampilkanKeBawah = tampil);
    }
  }

  @override
  void dispose() {
    _pengaturGulir.removeListener(_pantauGulir);
    _pengaturInput.dispose();
    _pengaturGulir.dispose();
    super.dispose();
  }

  void _gulirKeBawah() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pengaturGulir.hasClients) {
        _pengaturGulir.animateTo(
          _pengaturGulir.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _kirim() async {
    if (ref.read(penyediaAiChat).memuat) return;
    final teks = _pengaturInput.text.trim();
    if (teks.isEmpty) return;
    HapticFeedback.lightImpact();
    _pengaturInput.clear();
    await ref.read(penyediaAiChat.notifier).kirim(teks);
    _gulirKeBawah();
  }

  void _batalkan() {
    HapticFeedback.mediumImpact();
    ref.read(penyediaAiChat.notifier).batalkan();
  }

  Future<void> _regenerasi() async {
    await ref.read(penyediaAiChat.notifier).regenerasi();
    _gulirKeBawah();
  }

  Future<void> _saran(String teks) async {
    await ref.read(penyediaAiChat.notifier).kirim(teks);
    _gulirKeBawah();
  }

  Future<void> _lanjutkan() async {
    await ref.read(penyediaAiChat.notifier).lanjutkan();
    _gulirKeBawah();
  }

  Future<void> _cobaLagi() async {
    await ref.read(penyediaAiChat.notifier).cobaLagi();
    _gulirKeBawah();
  }

  void _jalankanAksi(AksiAi aksi) {
    final target = aksi.target;
    switch (aksi.tipe) {
      case TipeAksiAi.bukaLayanan:
        final jenis = JenisLayanan.dariSlug(target);
        if (jenis != null) {
          context.pushAman(NamaRute.layananAwal, extra: jenis);
        } else {
          context.pushAman(NamaRute.layanan);
        }
      case TipeAksiAi.lihatStatus:
        context.go(NamaRute.riwayat);
      case TipeAksiAi.lihatPermohonan:
        context.go(NamaRute.riwayat);
      case TipeAksiAi.mulaiPengaduan:
      case TipeAksiAi.bukaFaq:
      case TipeAksiAi.hubungiOperator:
        context.pushAman(NamaRute.bantuan);
      case TipeAksiAi.takDikenal:
        break;
    }
  }

  List<String> _saranBawaan(Teks t) => [
    t.saranStatusPermohonan,
    t.saranSyaratKk,
    t.saranApaItuKia,
    t.saranPindahDomisili,
  ];

  @override
  Widget build(BuildContext context) {
    final kondisi = ref.watch(penyediaAiChat);
    final t = ref.watch(teksProvider);
    final nama = ref.watch(penyediaOtentikasi).pengguna?.namaLengkap;

    ref.listen(penyediaAiChat, (sebelum, sesudah) {
      if (sebelum?.pesan.length != sesudah.pesan.length ||
          sebelum?.memuat != sesudah.memuat) {
        _gulirKeBawah();
      }
    });

    final pesan = kondisi.pesan;
    final indeksTerakhir = pesan.length - 1;
    final balasanTerakhir = pesan.isNotEmpty ? pesan.last : null;
    final perluLanjutkan =
        balasanTerakhir != null &&
        balasanTerakhir.peran == PeranPesanAi.asisten &&
        !balasanTerakhir.selesai &&
        !balasanTerakhir.terjadiGalat &&
        !kondisi.memuat;

    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(
        title: Text(t.asistenAi),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  pesan.isEmpty
                      ? SambutanAi(
                          teks: t,
                          namaPengguna: nama,
                          saran: _saranBawaan(t),
                          saatSaran: _saran,
                        )
                      : ListView.builder(
                          controller: _pengaturGulir,
                          padding: const EdgeInsets.fromLTRB(
                            Jarak.layarH,
                            Jarak.xl,
                            Jarak.layarH,
                            Jarak.sm,
                          ),
                          itemCount: pesan.length + (kondisi.memuat ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (i >= pesan.length) {
                              return IndikatorMengetikAi(
                                labelSemantik: t.asistenMengetik,
                              );
                            }
                            final p = pesan[i];
                            final terakhirAsisten =
                                i == indeksTerakhir &&
                                p.peran == PeranPesanAi.asisten &&
                                !kondisi.memuat;
                            return GelembungPesanAi(
                              key: ValueKey(
                                '${p.peran.name}-${p.dibuatPada.microsecondsSinceEpoch}',
                              ),
                              pesan: p,
                              teks: t,
                              saatAksi: _jalankanAksi,
                              saatOperator: () =>
                                  context.pushAman(NamaRute.bantuan),
                              saatCobaLagi: _cobaLagi,
                              saatSaran: _saran,
                              tampilkanSaran: terakhirAsisten,
                              bisaLanjutkan:
                                  perluLanjutkan && i == indeksTerakhir,
                              saatLanjutkan: _lanjutkan,
                              bisaRegenerasi:
                                  terakhirAsisten && !p.terjadiGalat,
                              saatRegenerasi: _regenerasi,
                            );
                          },
                        ),
                  Positioned(
                    right: Jarak.layarH,
                    bottom: Jarak.md,
                    child: _TombolKeBawah(
                      tampil: _tampilkanKeBawah && pesan.isNotEmpty,
                      label: t.keBalasanTerbaru,
                      saatKetuk: () {
                        HapticFeedback.selectionClick();
                        _gulirKeBawah();
                      },
                    ),
                  ),
                ],
              ),
            ),
            BilahInputAi(
              pengatur: _pengaturInput,
              memuat: kondisi.memuat,
              saatKirim: _kirim,
              saatBatal: _batalkan,
              placeholder: t.ketikPertanyaan,
              disclaimer: t.disclaimerAi,
              labelHenti: t.hentikan,
            ),
          ],
        ),
      ),
    );
  }
}

class _TombolKeBawah extends StatelessWidget {
  const _TombolKeBawah({
    required this.tampil,
    required this.label,
    required this.saatKetuk,
  });

  final bool tampil;
  final String label;
  final VoidCallback saatKetuk;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !tampil,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        opacity: tampil ? 1 : 0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          offset: tampil ? Offset.zero : const Offset(0, 0.4),
          child: Material(
            color: Warna.permukaan,
            shape: const CircleBorder(side: BorderSide(color: Warna.garis)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: saatKetuk,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Tooltip(
                  message: label,
                  child: const Icon(
                    HugeIcons.strokeRoundedArrowDown01,
                    size: 20,
                    color: Warna.primer,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
