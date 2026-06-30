import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/model_ai_chat.dart';
import '../../core/config/storage_keys.dart';
import '../../core/errors/kesalahan.dart';
import '../../core/localization/teks.dart';
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

  String? _pertanyaanTerakhir;
  bool _lanjutkanTerakhir = false;
  CancelToken? _batal;

  Map<String, dynamic> _bangunKonteks() {
    final auth = _ref.read(penyediaOtentikasi);
    final bahasa = _ref.read(penyediaBahasa);
    final ringkasan = _ref.read(penyediaRingkasanStatus);
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
    _pertanyaanTerakhir = isi;
    _lanjutkanTerakhir = false;
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
      tidakTersedia: false,
    );
    await _tanya(isi);
  }

  Future<void> lanjutkan() async {
    if (state.memuat) return;
    _lanjutkanTerakhir = true;
    state = state.salin(memuat: true, tidakTersedia: false);
    await _tanya('', lanjutkan: true);
  }

  Future<void> cobaLagi() async {
    if (state.memuat) return;
    final tanpaGalat = state.pesan.where((p) => !p.terjadiGalat).toList();
    if (_lanjutkanTerakhir) {
      state = state.salin(
        pesan: tanpaGalat,
        memuat: true,
        tidakTersedia: false,
      );
      await _tanya('', lanjutkan: true);
      return;
    }
    final pertanyaan = _pertanyaanTerakhir;
    if (pertanyaan == null || pertanyaan.isEmpty) return;
    state = state.salin(pesan: tanpaGalat, memuat: true, tidakTersedia: false);
    await _tanya(pertanyaan);
  }

  Future<void> _tanya(String isi, {bool lanjutkan = false}) async {
    final batal = CancelToken();
    _batal = batal;
    try {
      final hasil = await _repo.tanya(
        pesan: isi,
        sesiId: state.sesiId,
        konteks: _bangunKonteks(),
        lanjutkan: lanjutkan,
        batal: batal,
      );
      if (batal.isCancelled) return;
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
            saran: hasil.saran,
            butuhOperator: hasil.butuhOperator,
          ),
        ],
        memuat: false,
      );
      _simpan();
    } on KesalahanBatasFrekuensi catch (e) {
      if (batal.isCancelled) return;
      _galat(_pesanGalat(e), butuhOperator: false);
    } on KesalahanBatasFrekuensiDenganRetry catch (e) {
      if (batal.isCancelled) return;
      _galat(
        _pesanGalat(e),
        butuhOperator: false,
        detikCobaUlang: e.detikUlang,
      );
    } on KesalahanAiTidakTersedia catch (e) {
      if (batal.isCancelled) return;
      _galat(_pesanGalat(e), tidakTersedia: true, butuhOperator: true);
    } on Kesalahan catch (e) {
      if (batal.isCancelled) return;
      _galat(_pesanGalat(e), butuhOperator: true);
    } catch (_) {
      if (batal.isCancelled) return;
      _galat(_pesanGalat(null), butuhOperator: true);
    } finally {
      if (identical(_batal, batal)) _batal = null;
    }
  }

  void batalkan() {
    if (!state.memuat) return;
    _batal?.cancel();
    state = state.salin(memuat: false);
  }

  Future<void> regenerasi() async {
    if (state.memuat) return;
    final pertanyaan = _pertanyaanTerakhir;
    if (pertanyaan == null || pertanyaan.isEmpty) return;
    final pesan = [...state.pesan];
    if (pesan.isNotEmpty && pesan.last.peran == PeranPesanAi.asisten) {
      pesan.removeLast();
    }
    state = state.salin(pesan: pesan, memuat: true, tidakTersedia: false);
    await _tanya(
      _lanjutkanTerakhir ? '' : pertanyaan,
      lanjutkan: _lanjutkanTerakhir,
    );
  }

  String _pesanGalat(Kesalahan? e) {
    final teks = _ref.read(teksProvider);
    return pesanRamah(e, fallback: teks.galatAiUmum, teks: teks);
  }

  void _galat(
    String pesan, {
    bool tidakTersedia = false,
    bool butuhOperator = false,
    int? detikCobaUlang,
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
          detikCobaUlang: detikCobaUlang,
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

final penyediaAiChat = StateNotifierProvider<PengaturAiChat, KondisiAiChat>((
  ref,
) {
  final pengatur = PengaturAiChat(ref.watch(penyediaRepositoriAiChat), ref);
  ref.listen<KondisiOtentikasi>(penyediaOtentikasi, (sebelum, sesudah) {
    if (sesudah.status != StatusOtentikasi.masuk) {
      pengatur.mulaiSesiBaru();
    }
  });
  return pengatur;
});
