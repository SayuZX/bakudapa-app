import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/model_ai_chat.dart';
import '../../core/config/storage_keys.dart';
import '../../core/errors/kesalahan.dart';
import '../../core/services/penyimpanan_aman.dart';
import '../../features/ai/domain/repositori_ai_chat.dart';
import 'penyedia_bahasa.dart';
import 'penyedia_otentikasi.dart';
import 'penyedia_permohonan.dart';
import 'penyedia_repositori.dart';

class KondisiAiChat {
  const KondisiAiChat({
    this.sesiId,
    this.pesan = const [],
    this.memuat = false,
    this.tidakTersedia = false,
  });

  final String? sesiId;
  final List<PesanAi> pesan;
  final bool memuat;
  final bool tidakTersedia;

  KondisiAiChat salin({
    String? sesiId,
    List<PesanAi>? pesan,
    bool? memuat,
    bool? tidakTersedia,
  }) {
    return KondisiAiChat(
      sesiId: sesiId ?? this.sesiId,
      pesan: pesan ?? this.pesan,
      memuat: memuat ?? this.memuat,
      tidakTersedia: tidakTersedia ?? this.tidakTersedia,
    );
  }
}

class PengaturAiChat extends StateNotifier<KondisiAiChat> {
  PengaturAiChat(this._repo, this._ref) : super(const KondisiAiChat()) {
    _pulihkan();
  }

  final RepositoriAiChat _repo;
  final Ref _ref;

  static const int _maksSimpan = 30;

  Map<String, dynamic> _bangunKonteks() {
    final auth = _ref.read(penyediaOtentikasi);
    final bahasa = _ref.read(penyediaBahasa);
    final ringkasan = _ref.read(penyediaRingkasanStatus).valueOrNull;
    final p = auth.pengguna;
    return {
      'locale': bahasa.kode,
      if (p != null)
        'pengguna': {
          'nama': p.namaLengkap,
          if (p.kabupatenKota != null) 'kab_kota': p.kabupatenKota,
          if (p.kecamatan != null) 'kecamatan': p.kecamatan,
          'terverifikasi': p.terverifikasi,
        },
      if (ringkasan != null)
        'ringkasan_permohonan': {
          'menunggu': ringkasan.menunggu,
          'berjalan': ringkasan.berjalan,
          'selesai': ringkasan.selesai,
        },
    };
  }

  Future<void> kirim(String pesan) async {
    final isi = pesan.trim();
    if (isi.isEmpty || state.memuat) return;
    state = state.salin(
      pesan: [
        ...state.pesan,
        PesanAi(
          peran: PeranPesanAi.pengguna,
          isi: isi,
          dibuatPada: DateTime.now(),
        ),
      ],
      memuat: true,
    );
    await _tanya(isi);
  }

  Future<void> lanjutkan() async {
    if (state.memuat) return;
    state = state.salin(memuat: true);
    await _tanya('', lanjutkan: true);
  }

  Future<void> _tanya(String isi, {bool lanjutkan = false}) async {
    try {
      final hasil = await _repo.tanya(
        pesan: isi,
        sesiId: state.sesiId,
        konteks: _bangunKonteks(),
        lanjutkan: lanjutkan,
      );
      state = state.salin(
        sesiId: hasil.sesiId,
        pesan: [
          ...state.pesan,
          PesanAi(
            peran: PeranPesanAi.asisten,
            isi: hasil.balasan,
            dibuatPada: DateTime.now(),
            selesai: hasil.selesai,
            aksi: hasil.aksi,
            butuhOperator: hasil.butuhOperator,
          ),
        ],
        memuat: false,
      );
      _simpan();
    } on KesalahanAiTidakTersedia catch (e) {
      _galat(e.pesan, tidakTersedia: true, butuhOperator: true);
    } on Kesalahan catch (e) {
      _galat(e.pesan, butuhOperator: true);
    } catch (_) {
      _galat('Maaf, terjadi kesalahan. Silakan coba lagi.', butuhOperator: true);
    }
  }

  void _galat(
    String pesan, {
    bool tidakTersedia = false,
    bool butuhOperator = false,
  }) {
    state = state.salin(
      memuat: false,
      tidakTersedia: tidakTersedia,
      pesan: [
        ...state.pesan,
        PesanAi(
          peran: PeranPesanAi.asisten,
          isi: pesan,
          dibuatPada: DateTime.now(),
          terjadiGalat: true,
          pesanGalat: pesan,
          butuhOperator: butuhOperator,
        ),
      ],
    );
  }

  void mulaiSesiBaru() {
    state = const KondisiAiChat();
    _hapusSimpanan();
  }

  Future<void> _pulihkan() async {
    try {
      final mentah = await PenyimpananAman.instance.baca(StorageKeys.sesiAiId);
      if (mentah == null || mentah.isEmpty) return;
      final data = jsonDecode(mentah) as Map<String, dynamic>;
      final sesiId = data['sesi_id'] as String?;
      final daftarRaw = data['pesan'];
      final pesan = daftarRaw is List
          ? daftarRaw
              .whereType<Map>()
              .map((e) => PesanAi.dariJson(Map<String, dynamic>.from(e)))
              .toList()
          : <PesanAi>[];
      if (!mounted) return;
      if (pesan.isNotEmpty || (sesiId != null && sesiId.isNotEmpty)) {
        state = state.salin(sesiId: sesiId, pesan: pesan);
      }
    } catch (_) {}
  }

  Future<void> _simpan() async {
    try {
      final bersih = state.pesan.where((p) => !p.terjadiGalat).toList();
      final dipangkas = bersih.length > _maksSimpan
          ? bersih.sublist(bersih.length - _maksSimpan)
          : bersih;
      final data = jsonEncode({
        if (state.sesiId != null) 'sesi_id': state.sesiId,
        'pesan': dipangkas.map((p) => p.toJson()).toList(),
      });
      await PenyimpananAman.instance.tulis(StorageKeys.sesiAiId, data);
    } catch (_) {}
  }

  Future<void> _hapusSimpanan() async {
    try {
      await PenyimpananAman.instance.hapus(StorageKeys.sesiAiId);
    } catch (_) {}
  }
}

final penyediaAiChat =
    StateNotifierProvider<PengaturAiChat, KondisiAiChat>((ref) {
  final pengatur =
      PengaturAiChat(ref.watch(penyediaRepositoriAiChat), ref);
  ref.listen<KondisiOtentikasi>(penyediaOtentikasi, (sebelum, sesudah) {
    if (sesudah.status != StatusOtentikasi.masuk) {
      pengatur.mulaiSesiBaru();
    }
  });
  return pengatur;
});
