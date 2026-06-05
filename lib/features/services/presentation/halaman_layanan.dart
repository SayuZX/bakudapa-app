import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/extensions/konteks.dart';
import '../../../core/localization/teks.dart';
import '../../../core/router/nama_rute.dart';
import '../../../core/theme/dimensi.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/models/jenis_layanan.dart';
import '../../../shared/widgets/kartu.dart';

class HalamanLayanan extends ConsumerStatefulWidget {
  const HalamanLayanan({super.key});

  @override
  ConsumerState<HalamanLayanan> createState() => _HalamanLayananState();
}

class _HalamanLayananState extends ConsumerState<HalamanLayanan> {
  String _kueri = '';

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);
    final daftar = JenisLayanan.values.where((j) {
      if (_kueri.isEmpty) return true;
      final k = _kueri.toLowerCase();
      return j.nama.toLowerCase().contains(k) || j.deskripsi.toLowerCase().contains(k);
    }).toList();

    return Scaffold(
      backgroundColor: Warna.latar,
      appBar: AppBar(
        title: Text(t.layanan),
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Jarak.layarH, 0, Jarak.layarH, Jarak.md),
              child: TextField(
                onChanged: (v) => setState(() => _kueri = v),
                decoration: InputDecoration(
                  hintText: t.cariLayanan,
                  prefixIcon: const Icon(HugeIcons.strokeRoundedSearch01, size: 20),
                ),
              ),
            ),
            if (daftar.isEmpty)
              Padding(
                padding: const EdgeInsets.all(Jarak.xxl),
                child: Center(
                  child: Text(
                    t.tidakAdaLayanan,
                    style: context.teks.bodyMedium?.copyWith(color: Warna.teksKedua),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(Jarak.layarH, 0, Jarak.layarH, Jarak.xxl),
                  itemCount: daftar.length,
                  separatorBuilder: (_, _) => const SizedBox(height: Jarak.md),
                  itemBuilder: (_, i) {
                    final j = daftar[i];
                    return Kartu(
                      saatKetuk: () => context.push('${NamaRute.detailLayanan}/${j.kode}'),
                      anak: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Warna.netral100,
                              borderRadius: BorderRadius.circular(Sudut.md),
                            ),
                            child: Icon(j.ikon, color: Warna.teksUtama, size: 24),
                          ),
                          const SizedBox(width: Jarak.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        j.nama,
                                        style: context.teks.titleSmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (!j.bisaOnline) ...[
                                      const SizedBox(width: Jarak.sm),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Warna.peringatanLembut,
                                          borderRadius:
                                              BorderRadius.circular(Sudut.pil),
                                        ),
                                        child: Text(
                                          t.layananLoket,
                                          style: context.teks.labelSmall?.copyWith(
                                              color: Warna.peringatan,
                                              fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  j.deskripsi,
                                  style: context.teks.bodySmall?.copyWith(color: Warna.teksKedua),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Jarak.sm),
                          const Icon(HugeIcons.strokeRoundedArrowRight01,
                              color: Warna.teksKetiga, size: 18),
                        ],
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
