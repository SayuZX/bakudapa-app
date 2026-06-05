import 'dart:io';

import 'package:bakudapa_mobile/core/enums/langkah_registrasi.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/biometric/layanan_biometrik.dart';
import '../../../core/biometric/model_hasil_biometrik.dart';
import '../../../core/errors/kesalahan.dart';
import '../../../core/liveness/model_tantangan_liveness.dart';
import '../../../core/storage/berkas_sementara.dart';
import '../../../shared/providers/penyedia_repositori.dart';
import '../data/model/data_registrasi.dart';
import '../data/repositori_registrasi.dart';

export 'package:bakudapa_mobile/core/enums/langkah_registrasi.dart';

enum HasilAmbilTantanganSuara { sukses, kosong, jaringan, galat }

class KondisiRegistrasi {
  const KondisiRegistrasi({
    required this.sesi,
    required this.langkah,
    this.memuat = false,
    this.pesanGalat,
    this.percobaanFotoWajah = 0,
  });

  static const int maksPercobaanFotoWajah = 5;
  static const int ambangPercobaanGagal = 3;

  final SesiRegistrasi sesi;
  final LangkahRegistrasi langkah;
  final bool memuat;
  final String? pesanGalat;
  final int percobaanFotoWajah;

  bool get terblokirFotoWajah =>
      percobaanFotoWajah >= maksPercobaanFotoWajah;
  bool get perluPanduanTambahan =>
      percobaanFotoWajah >= ambangPercobaanGagal &&
      percobaanFotoWajah < maksPercobaanFotoWajah;

  KondisiRegistrasi salin({
    SesiRegistrasi? sesi,
    LangkahRegistrasi? langkah,
    bool? memuat,
    String? pesanGalat,
    int? percobaanFotoWajah,
    bool bersihkanGalat = false,
  }) {
    return KondisiRegistrasi(
      sesi: sesi ?? this.sesi,
      langkah: langkah ?? this.langkah,
      memuat: memuat ?? this.memuat,
      pesanGalat: bersihkanGalat ? null : (pesanGalat ?? this.pesanGalat),
      percobaanFotoWajah: percobaanFotoWajah ?? this.percobaanFotoWajah,
    );
  }
}

class PengaturRegistrasi extends StateNotifier<KondisiRegistrasi> {
  PengaturRegistrasi(this._ref)
      : super(KondisiRegistrasi(
          sesi: SesiRegistrasi(mulaiPada: DateTime.now()),
          langkah: LangkahRegistrasi.identitas,
        ));

  final Ref _ref;

  RepositoriRegistrasi get _repo => _ref.read(penyediaRepositoriRegistrasi);

  Future<bool> _pastikanSesi() async {
    if (state.sesi.token != null && state.sesi.token!.isNotEmpty) return true;
    try {
      final token = await _repo.mulaiSesi();
      state = state.salin(sesi: state.sesi.salin(token: token));
      return true;
    } on Kesalahan catch (e) {
      state = state.salin(pesanGalat: e.pesan);
      return false;
    } catch (_) {
      state = state.salin(pesanGalat: 'Gagal memulai sesi registrasi.');
      return false;
    }
  }

  void perbaruiIdentitas(IdentitasRegistrasi identitas) {
    state = state.salin(sesi: state.sesi.salin(identitas: identitas));
  }

  Future<bool> kirimIdentitas() async {
    if (state.memuat) return false;
    state = state.salin(memuat: true, bersihkanGalat: true);
    try {
      if (!await _pastikanSesi()) {
        state = state.salin(memuat: false);
        return false;
      }
      await _repo.kirimIdentitas(
        token: state.sesi.token!,
        identitas: state.sesi.identitas,
      );
      state = state.salin(memuat: false);
      return true;
    } on Kesalahan catch (e) {
      state = state.salin(memuat: false, pesanGalat: e.pesan);
      return false;
    } catch (_) {
      state = state.salin(memuat: false, pesanGalat: 'Gagal mengirim identitas.');
      return false;
    }
  }

  Future<bool> simpanFotoDokumen(String jalur) async {
    if (state.memuat) return false;
    state = state.salin(memuat: true, bersihkanGalat: true);
    try {
      if (!await _pastikanSesi()) {
        state = state.salin(memuat: false);
        return false;
      }
      await _repo.unggahFotoDokumen(token: state.sesi.token!, berkas: File(jalur));
      final sebelumnya = state.sesi.jalurFotoDokumen;
      if (sebelumnya != null && sebelumnya != jalur) {
        await BerkasSementara.instance.hapus(sebelumnya);
      }
      state = state.salin(
        memuat: false,
        sesi: state.sesi.salin(jalurFotoDokumen: jalur),
      );
      return true;
    } on Kesalahan catch (e) {
      state = state.salin(memuat: false, pesanGalat: e.pesan);
      return false;
    } catch (_) {
      state = state.salin(memuat: false, pesanGalat: 'Gagal mengunggah foto dokumen.');
      return false;
    }
  }

  Future<bool> simpanFotoWajah(String jalur) async {
    if (state.memuat) return false;
    state = state.salin(memuat: true, bersihkanGalat: true);
    try {
      if (!await _pastikanSesi()) {
        state = state.salin(memuat: false);
        return false;
      }
      await _repo.unggahFotoWajah(token: state.sesi.token!, berkas: File(jalur));
      final sebelumnya = state.sesi.jalurFotoWajah;
      if (sebelumnya != null && sebelumnya != jalur) {
        await BerkasSementara.instance.hapus(sebelumnya);
      }
      state = state.salin(
        memuat: false,
        sesi: state.sesi.salin(jalurFotoWajah: jalur),
      );
      return true;
    } on Kesalahan catch (e) {
      state = state.salin(memuat: false, pesanGalat: e.pesan);
      return false;
    } catch (_) {
      state = state.salin(memuat: false, pesanGalat: 'Gagal mengunggah foto wajah.');
      return false;
    }
  }

  Future<bool> simpanLiveness({
    required String jalurVideo,
    required List<TantanganLiveness> tantangan,
    List<TangkapTantangan> tangkapan = const [],
  }) async {
    if (state.memuat) return false;
    state = state.salin(memuat: true, bersihkanGalat: true);
    try {
      if (!await _pastikanSesi()) {
        state = state.salin(memuat: false);
        return false;
      }
      await _repo.unggahVideoLiveness(
        token: state.sesi.token!,
        berkas: File(jalurVideo),
        kodeTantangan: tantangan.map((t) => t.kode).toList(),
        tangkapan: tangkapan,
      );
      final sebelumnya = state.sesi.jalurVideoLiveness;
      if (sebelumnya != null && sebelumnya != jalurVideo) {
        await BerkasSementara.instance.hapus(sebelumnya);
      }
      for (final t in state.sesi.tangkapanTantangan) {
        if (!tangkapan.any((x) => x.jalurFoto == t.jalurFoto)) {
          await BerkasSementara.instance.hapus(t.jalurFoto);
        }
      }
      state = state.salin(
        memuat: false,
        sesi: state.sesi.salin(
          jalurVideoLiveness: jalurVideo,
          tantanganLiveness: tantangan,
          tangkapanTantangan: tangkapan,
        ),
      );
      return true;
    } on Kesalahan catch (e) {
      state = state.salin(memuat: false, pesanGalat: e.pesan);
      return false;
    } catch (_) {
      state = state.salin(memuat: false, pesanGalat: 'Gagal mengunggah video liveness.');
      return false;
    }
  }

  Future<HasilAmbilTantanganSuara> ambilTantanganSuara() async {
    try {
      final t = await _repo.tantanganSuara();
      if (t.kalimat.isEmpty) {
        return HasilAmbilTantanganSuara.kosong;
      }
      state = state.salin(
        sesi: state.sesi.salin(kalimatSuara: t.kalimat, kodeSuara: t.kode),
      );
      return HasilAmbilTantanganSuara.sukses;
    } on KesalahanSumberKosong {
      return HasilAmbilTantanganSuara.kosong;
    } on KesalahanJaringan {
      return HasilAmbilTantanganSuara.jaringan;
    } on KesalahanBatasWaktu {
      return HasilAmbilTantanganSuara.jaringan;
    } on Kesalahan {
      return HasilAmbilTantanganSuara.galat;
    } catch (_) {
      return HasilAmbilTantanganSuara.galat;
    }
  }

  void perbaruiSidikJari(HasilBiometrikSidikJari hasil) {
    state = state.salin(sesi: state.sesi.salin(hasilSidikJari: hasil));
  }

  Future<bool> kirimSidikJari(HasilBiometrikSidikJari hasil) async {
    if (state.memuat) return false;
    state = state.salin(memuat: true, bersihkanGalat: true);
    try {
      if (!await _pastikanSesi()) {
        state = state.salin(memuat: false);
        return false;
      }
      await _repo.kirimVerifikasiSidikJari(
        token: state.sesi.token!,
        idSesi: state.sesi.token!,
        hasil: hasil,
        metadataPerangkat: LayananBiometrik.instance.metadataPerangkat(),
      );
      state = state.salin(
        memuat: false,
        sesi: state.sesi.salin(hasilSidikJari: hasil),
      );
      return true;
    } on Kesalahan catch (e) {
      state = state.salin(memuat: false, pesanGalat: e.pesan);
      return false;
    } catch (_) {
      state = state.salin(
        memuat: false,
        pesanGalat: 'Gagal mengirim status verifikasi sidik jari.',
      );
      return false;
    }
  }

  Future<bool> simpanSuara(String jalurAudio) async {
    if (state.memuat) return false;
    state = state.salin(memuat: true, bersihkanGalat: true);
    try {
      if (!await _pastikanSesi()) {
        state = state.salin(memuat: false);
        return false;
      }
      await _repo.unggahSuara(
        token: state.sesi.token!,
        berkas: File(jalurAudio),
        kalimat: state.sesi.kalimatSuara ?? '',
      );
      final sebelumnya = state.sesi.jalurAudioSuara;
      if (sebelumnya != null && sebelumnya != jalurAudio) {
        await BerkasSementara.instance.hapus(sebelumnya);
      }
      state = state.salin(
        memuat: false,
        sesi: state.sesi.salin(jalurAudioSuara: jalurAudio),
      );
      return true;
    } on Kesalahan catch (e) {
      state = state.salin(memuat: false, pesanGalat: e.pesan);
      return false;
    } catch (_) {
      state = state.salin(memuat: false, pesanGalat: 'Gagal mengunggah suara.');
      return false;
    }
  }

  void perbaruiPersetujuan(PersetujuanKebijakan p) {
    state = state.salin(sesi: state.sesi.salin(persetujuan: p));
  }

  Future<bool> finalkan() async {
    if (state.memuat) return false;
    if (!state.sesi.persetujuan.semua) {
      state = state.salin(
        pesanGalat: 'Semua persetujuan wajib dicentang sebelum mengirim registrasi.',
      );
      return false;
    }
    state = state.salin(memuat: true, bersihkanGalat: true);
    try {
      if (!await _pastikanSesi()) {
        if (mounted) state = state.salin(memuat: false);
        return false;
      }
      await _repo.kirimPersetujuan(
        token: state.sesi.token!,
        persetujuan: state.sesi.persetujuan,
      );
      await _repo.submitFinal(token: state.sesi.token!);
      if (mounted) state = state.salin(memuat: false);
      return true;
    } on Kesalahan catch (e) {
      if (mounted) state = state.salin(memuat: false, pesanGalat: e.pesan);
      return false;
    } catch (_) {
      if (mounted) {
        state = state.salin(
          memuat: false,
          pesanGalat: 'Gagal menyelesaikan registrasi.',
        );
      }
      return false;
    }
  }

  void ubahLangkah(LangkahRegistrasi l) {
    state = state.salin(langkah: l, bersihkanGalat: true);
  }

  void catatGagalFotoWajah() {
    state = state.salin(
      percobaanFotoWajah: state.percobaanFotoWajah + 1,
    );
  }

  void resetPercobaanFotoWajah() {
    state = state.salin(percobaanFotoWajah: 0);
  }

  Future<void> resetPenuh() async {
    final s = state.sesi;
    await BerkasSementara.instance.hapus(s.jalurFotoDokumen);
    await BerkasSementara.instance.hapus(s.jalurFotoWajah);
    await BerkasSementara.instance.hapus(s.jalurVideoLiveness);
    await BerkasSementara.instance.hapus(s.jalurAudioSuara);
    for (final t in s.tangkapanTantangan) {
      await BerkasSementara.instance.hapus(t.jalurFoto);
    }
    state = KondisiRegistrasi(
      sesi: SesiRegistrasi(mulaiPada: DateTime.now()),
      langkah: LangkahRegistrasi.identitas,
    );
  }
}

final penyediaRegistrasi =
    StateNotifierProvider.autoDispose<PengaturRegistrasi, KondisiRegistrasi>(
        (ref) {
  return PengaturRegistrasi(ref);
});
