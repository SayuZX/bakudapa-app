import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router/nama_rute.dart';
import '../../../shared/models/permohonan.dart';
import '../../../shared/models/status_permohonan.dart';
import '../../../shared/providers/penyedia_permohonan.dart';
import 'layanan_utama_section.dart';

class _Palet {
  const _Palet._();

  static const Color primer = Color(0xFFC8102E);
  static const Color primerTerang = Color(0xFFE21D3A);
  static const Color latar = Color(0xFFFFFFFF);
  static const Color permukaan = Color(0xFFF5F6F8);
  static const Color garis = Color(0xFFE3E6EB);
  static const Color teksUtama = Color(0xFF14171F);
  static const Color teksKedua = Color(0xFF5A6171);
  static const Color teksKetiga = Color(0xFF8A93A2);
  static const Color sukses = Color(0xFF1F8A4C);
  static const Color suksesLembut = Color(0xFFE7F4ED);
  static const Color peringatan = Color(0xFFB7791F);
  static const Color peringatanLembut = Color(0xFFFDF3DC);
  static const Color info = Color(0xFF1F6FB8);
  static const Color infoLembut = Color(0xFFE4F0FB);
  static const Color bahaya = Color(0xFFB42318);
  static const Color bahayaLembut = Color(0xFFFEE4E2);
  static const Color tunda = Color(0xFF6B7280);
  static const Color tundaLembut = Color(0xFFF1F2F4);
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const List<String> _bulan = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  double _skala(BuildContext context) =>
      (MediaQuery.of(context).size.width / 375).clamp(0.85, 1.15);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: _Palet.latar,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: 14, bottom: 24 * _skala(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildHeader(context),
                ),
                SizedBox(height: 18 * _skala(context)),
                const LayananUtamaSection(),
                SizedBox(height: 14 * _skala(context)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildJudulBagian(context, 'Riwayat Permohonan',
                          onLihat: () => context.go(NamaRute.riwayat)),
                      SizedBox(height: 14 * _skala(context)),
                      _buildRiwayat(context, ref),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final double s = _skala(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Selamat datang kembali,',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w500,
                  color: _Palet.teksKedua,
                ),
              ),
              SizedBox(height: 3 * s),
              Text(
                'Ahmad 👋',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22 * s,
                  fontWeight: FontWeight.w800,
                  color: _Palet.teksUtama,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
        _buildFotoProfil(context),
      ],
    );
  }

  Widget _buildFotoProfil(BuildContext context) {
    final double s = _skala(context);
    final double diameter = 46 * s;
    return SizedBox(
      width: diameter + 5,
      height: diameter + 5,
      child: Stack(
        children: <Widget>[
          Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: <Color>[_Palet.primerTerang, _Palet.primer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'A',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 19 * s,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 13 * s,
              height: 13 * s,
              decoration: BoxDecoration(
                color: _Palet.sukses,
                shape: BoxShape.circle,
                border: Border.all(color: _Palet.latar, width: 2.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJudulBagian(BuildContext context, String judul,
      {bool lihatSemua = true, VoidCallback? onLihat}) {
    final double s = _skala(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          judul,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15 * s,
            fontWeight: FontWeight.w700,
            color: _Palet.teksUtama,
          ),
        ),
        if (lihatSemua)
          GestureDetector(
            onTap: onLihat,
            behavior: HitTestBehavior.opaque,
            child: Text(
              'Lihat Semua',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12 * s,
                fontWeight: FontWeight.w600,
                color: _Palet.primer,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRiwayat(BuildContext context, WidgetRef ref) {
    final riwayat = ref.watch(penyediaPengaturRiwayat);
    return riwayat.when(
      loading: () => _buildRiwayatPlaceholder(context),
      error: (_, _) => _buildRiwayatPesan(context, 'Gagal memuat riwayat permohonan.'),
      data: (halaman) {
        final items = halaman.daftar.take(3).toList();
        if (items.isEmpty) {
          return _buildRiwayatPesan(context, 'Belum ada permohonan.');
        }
        return Column(
          children: <Widget>[
            for (int i = 0; i < items.length; i++) ...<Widget>[
              _buildKartuRiwayat(context, items[i]),
              if (i != items.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _buildKartuRiwayat(BuildContext context, Permohonan p) {
    final double s = _skala(context);
    final (Color fg, Color bg) = _warnaStatus(p.status);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('${NamaRute.detailPermohonan}/${p.id}'),
        child: Container(
          padding: EdgeInsets.all(14 * s),
          decoration: BoxDecoration(
            color: _Palet.latar,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _Palet.garis),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 46 * s,
                height: 46 * s,
                decoration: BoxDecoration(
                  color: _Palet.latar,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: _Palet.garis),
                ),
                child: Icon(p.jenis.ikon, color: _Palet.teksUtama, size: 22 * s),
              ),
              SizedBox(width: 13 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      p.jenis.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w700,
                        color: _Palet.teksUtama,
                      ),
                    ),
                    SizedBox(height: 3 * s),
                    Text(
                      p.kodeReferensi.isEmpty ? '—' : p.kodeReferensi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5 * s,
                        fontWeight: FontWeight.w600,
                        color: _Palet.teksKetiga,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10 * s),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      p.status.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5 * s,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                  ),
                  SizedBox(height: 7 * s),
                  Text(
                    _tanggalSingkat(p.diajukanPada),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5 * s,
                      fontWeight: FontWeight.w500,
                      color: _Palet.teksKetiga,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiwayatPlaceholder(BuildContext context) {
    final double s = _skala(context);
    return Column(
      children: <Widget>[
        for (int i = 0; i < 2; i++) ...<Widget>[
          Container(
            height: 74 * s,
            decoration: BoxDecoration(
              color: _Palet.permukaan,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _Palet.garis),
            ),
          ),
          if (i == 0) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildRiwayatPesan(BuildContext context, String pesan) {
    final double s = _skala(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 26 * s, horizontal: 16),
      decoration: BoxDecoration(
        color: _Palet.permukaan,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Palet.garis),
      ),
      child: Text(
        pesan,
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12.5 * s,
          fontWeight: FontWeight.w600,
          color: _Palet.teksKedua,
        ),
      ),
    );
  }

  (Color, Color) _warnaStatus(StatusPermohonan status) {
    switch (status) {
      case StatusPermohonan.selesai:
        return (_Palet.sukses, _Palet.suksesLembut);
      case StatusPermohonan.menunggu:
        return (_Palet.peringatan, _Palet.peringatanLembut);
      case StatusPermohonan.diverifikasi:
      case StatusPermohonan.diproses:
        return (_Palet.info, _Palet.infoLembut);
      case StatusPermohonan.ditolak:
        return (_Palet.bahaya, _Palet.bahayaLembut);
      case StatusPermohonan.tertunda:
        return (_Palet.tunda, _Palet.tundaLembut);
    }
  }

  String _tanggalSingkat(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';
}
