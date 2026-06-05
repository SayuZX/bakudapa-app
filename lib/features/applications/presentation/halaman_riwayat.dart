import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/errors/kesalahan.dart';
import '../../../core/localization/teks.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../core/utils/format.dart';
import '../../../shared/providers/penyedia_permohonan.dart';
import '../../../shared/widgets/kondisi_galat.dart';
import '../../../shared/widgets/kondisi_kosong.dart';
import '../../../shared/widgets/lencana_status.dart';
import '../../../shared/widgets/pemuat_kerlip.dart';
import 'widgets/baris_permohonan.dart';

class HalamanRiwayat extends ConsumerStatefulWidget {
  const HalamanRiwayat({super.key});

  @override
  ConsumerState<HalamanRiwayat> createState() => _HalamanRiwayatState();
}

class _HalamanRiwayatState extends ConsumerState<HalamanRiwayat> {
  final _pengaturGulir = ScrollController();

  @override
  void initState() {
    super.initState();
    _pengaturGulir.addListener(_saatGulir);
  }

  @override
  void dispose() {
    _pengaturGulir.removeListener(_saatGulir);
    _pengaturGulir.dispose();
    super.dispose();
  }

  void _saatGulir() {
    if (_pengaturGulir.position.pixels >=
        _pengaturGulir.position.maxScrollExtent - 200) {
      ref.read(penyediaPengaturRiwayat.notifier).muatBerikut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final keadaan = ref.watch(penyediaPengaturRiwayat);
    final pengatur = ref.read(penyediaPengaturRiwayat.notifier);
    final t = ref.watch(teksProvider);

    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(title: Text(t.riwayat)),
      body: SafeArea(
        top: false,
        child: keadaan.when(
          loading: () => const DaftarKerangka(),
          error: (e, _) => Center(
            child: KondisiGalat(
              pesan: pesanRamah(e, fallback: t.terjadiKesalahan),
              saatCobaLagi: pengatur.segarkan,
            ),
          ),
          data: (halaman) {
            if (halaman.daftar.isEmpty) {
              return Center(
                child: KondisiKosong(
                  ikon: HugeIcons.strokeRoundedInbox,
                  judul: t.belumAdaPermohonan,
                  pesan: t.riwayatPermohonanAnda,
                ),
              );
            }
            return RefreshIndicator(
              color: Warna.merahUtama,
              onRefresh: pengatur.segarkan,
              child: ListView.separated(
                controller: _pengaturGulir,
                padding: const EdgeInsets.fromLTRB(Jarak.layarH, Jarak.md, Jarak.layarH, Jarak.xxl),
                itemCount: halaman.daftar.length + (halaman.adaHalamanBerikut ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: Jarak.md),
                itemBuilder: (_, i) {
                  if (i >= halaman.daftar.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: Jarak.lg),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  final p = halaman.daftar[i];
                  return BarisPermohonan(
                    permohonan: p,
                    saatKetuk: () =>
                        context.push('${NamaRute.detailPermohonan}/${p.id}'),
                    subJudul: '${p.jenis.nama} • ${Format.tanggalPendek(p.diajukanPada)}',
                    lencana: LencanaStatus(status: p.status, kompak: true),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
