import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/kesalahan.dart';
import '../../../../core/extensions/konteks.dart';
import '../../../../core/localization/teks.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../../core/utils/validasi_berkas.dart';
import '../../domain/definisi_formulir.dart';

class PengunggahBerkas extends ConsumerWidget {
  const PengunggahBerkas({
    super.key,
    required this.dokumen,
    required this.berkas,
    required this.saatUbah,
    this.galat,
  });

  final DefinisiDokumen dokumen;
  final File? berkas;
  final ValueChanged<File?> saatUbah;
  final String? galat;

  Future<void> _pilihSumber(BuildContext context, Teks t) async {
    final sumber = await showModalBottomSheet<_SumberBerkas>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Warna.permukaan,
      builder: (_) => _LembarSumber(teks: t),
    );
    if (sumber == null || !context.mounted) return;
    try {
      File? terpilih;
      switch (sumber) {
        case _SumberBerkas.kamera:
          final foto = await ImagePicker().pickImage(
            source: ImageSource.camera,
            imageQuality: 82,
            maxWidth: 2200,
          );
          if (foto != null) terpilih = File(foto.path);
        case _SumberBerkas.galeri:
          final foto = await ImagePicker().pickImage(
            source: ImageSource.gallery,
            imageQuality: 82,
            maxWidth: 2200,
          );
          if (foto != null) terpilih = File(foto.path);
        case _SumberBerkas.berkas:
          final hasil = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: _ekstensiIzin(),
          );
          final jalur = hasil?.files.single.path;
          if (jalur != null) terpilih = File(jalur);
      }
      if (terpilih == null) return;
      await ValidasiBerkas.periksa(
        terpilih,
        maksByte: dokumen.maksByte,
        mimeIzin: dokumen.mimeTypes,
      );
      saatUbah(terpilih);
    } on Kesalahan catch (e) {
      if (context.mounted) context.tampilkanGalat(e.pesan);
    } catch (_) {
      if (context.mounted) {
        context.tampilkanGalat(t.gagalPilihBerkas);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final label = t.katalog(dokumen.label);
    final terisi = berkas != null;
    final adaGalat = galat != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: terisi ? Warna.suksesLembut : Warna.permukaan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sudut.md),
            side: BorderSide(
              color: adaGalat
                  ? Warna.bahaya
                  : terisi
                      ? Warna.sukses
                      : Warna.garisTegas,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _pilihSumber(context, t),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Jarak.lg,
                vertical: Jarak.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: terisi ? Warna.sukses : Warna.netral100,
                      borderRadius: BorderRadius.circular(Sudut.sm),
                    ),
                    child: Icon(
                      terisi
                          ? HugeIcons.strokeRoundedTick02
                          : HugeIcons.strokeRoundedUpload04,
                      size: 19,
                      color: terisi ? Colors.white : Warna.teksKedua,
                    ),
                  ),
                  const SizedBox(width: Jarak.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dokumen.wajib ? '$label *' : label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.teks.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          terisi
                              ? _namaBerkas(berkas!)
                              : t.ketukUnggahFormat,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.teks.labelSmall?.copyWith(
                            color: terisi ? Warna.sukses : Warna.teksKetiga,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (terisi)
                    IconButton(
                      onPressed: () => saatUbah(null),
                      icon: const Icon(
                        HugeIcons.strokeRoundedDelete02,
                        size: 18,
                        color: Warna.bahaya,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (adaGalat)
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

  List<String> _ekstensiIzin() {
    if (dokumen.mimeTypes.isEmpty) return const ['pdf', 'jpg', 'jpeg', 'png'];
    final ext = <String>{};
    for (final mime in dokumen.mimeTypes) {
      switch (mime) {
        case 'application/pdf':
          ext.add('pdf');
        case 'image/jpeg':
        case 'image/jpg':
          ext..add('jpg')..add('jpeg');
        case 'image/png':
          ext.add('png');
      }
    }
    return ext.isEmpty ? const ['pdf', 'jpg', 'jpeg', 'png'] : ext.toList();
  }

  String _namaBerkas(File f) {
    final nama = f.uri.pathSegments.isNotEmpty ? f.uri.pathSegments.last : '';
    final ukuran = f.existsSync() ? ValidasiBerkas.formatByte(f.lengthSync()) : '';
    return ukuran.isEmpty ? nama : '$nama · $ukuran';
  }
}

enum _SumberBerkas { kamera, galeri, berkas }

class _LembarSumber extends StatelessWidget {
  const _LembarSumber({required this.teks});

  final Teks teks;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _OpsiSumber(
            ikon: HugeIcons.strokeRoundedCamera01,
            label: teks.ambilFotoKamera,
            saatKetuk: () => Navigator.of(context).pop(_SumberBerkas.kamera),
          ),
          _OpsiSumber(
            ikon: HugeIcons.strokeRoundedImage02,
            label: teks.pilihDariGaleri,
            saatKetuk: () => Navigator.of(context).pop(_SumberBerkas.galeri),
          ),
          _OpsiSumber(
            ikon: HugeIcons.strokeRoundedFolder02,
            label: teks.pilihBerkasPdf,
            saatKetuk: () => Navigator.of(context).pop(_SumberBerkas.berkas),
          ),
          const SizedBox(height: Jarak.sm),
        ],
      ),
    );
  }
}

class _OpsiSumber extends StatelessWidget {
  const _OpsiSumber({
    required this.ikon,
    required this.label,
    required this.saatKetuk,
  });

  final IconData ikon;
  final String label;
  final VoidCallback saatKetuk;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: saatKetuk,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Jarak.layarH,
          vertical: Jarak.md,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Warna.primerLembut,
                borderRadius: BorderRadius.circular(Sudut.sm),
              ),
              child: Icon(ikon, size: 19, color: Warna.primer),
            ),
            const SizedBox(width: Jarak.md),
            Text(
              label,
              style: context.teks.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
