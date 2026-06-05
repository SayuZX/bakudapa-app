import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/kesalahan.dart';
import '../../../../core/extensions/konteks.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';
import '../../../../core/utils/validasi_berkas.dart';

class PengunggahBerkas extends StatefulWidget {
  const PengunggahBerkas({
    super.key,
    required this.label,
    required this.berkas,
    required this.saatBerubah,
    this.wajib = true,
  });

  final String label;
  final File? berkas;
  final ValueChanged<File?> saatBerubah;
  final bool wajib;

  @override
  State<PengunggahBerkas> createState() => _PengunggahBerkasState();
}

class _PengunggahBerkasState extends State<PengunggahBerkas> {
  bool _sibuk = false;

  Future<void> _pilihGambar(ImageSource sumber) async {
    setState(() => _sibuk = true);
    try {
      final picker = ImagePicker();
      final hasil = await picker.pickImage(
        source: sumber,
        imageQuality: 80,
        maxWidth: 1600,
      );
      if (hasil == null) return;
      final berkas = File(hasil.path);
      await ValidasiBerkas.periksa(berkas);
      widget.saatBerubah(berkas);
    } on KesalahanUnggah catch (e) {
      if (!mounted) return;
      context.tampilkanPesan(e.pesan, galat: true);
    } catch (_) {
      if (!mounted) return;
      context.tampilkanPesan('Gagal memilih berkas.', galat: true);
    } finally {
      if (mounted) setState(() => _sibuk = false);
    }
  }

  Future<void> _pilihBerkas() async {
    setState(() => _sibuk = true);
    try {
      final hasil = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );
      if (hasil == null || hasil.files.isEmpty) return;
      final path = hasil.files.single.path;
      if (path == null) return;
      final berkas = File(path);
      await ValidasiBerkas.periksa(berkas);
      widget.saatBerubah(berkas);
    } on KesalahanUnggah catch (e) {
      if (!mounted) return;
      context.tampilkanPesan(e.pesan, galat: true);
    } catch (_) {
      if (!mounted) return;
      context.tampilkanPesan('Gagal memilih berkas.', galat: true);
    } finally {
      if (mounted) setState(() => _sibuk = false);
    }
  }

  void _bukaPilihan() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(HugeIcons.strokeRoundedCamera01),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(sheet);
                _pilihGambar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(HugeIcons.strokeRoundedImage01),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(sheet);
                _pilihGambar(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(HugeIcons.strokeRoundedFile01),
              title: const Text('Pilih Berkas (PDF/JPG/PNG)'),
              onTap: () {
                Navigator.pop(sheet);
                _pilihBerkas();
              },
            ),
            const SizedBox(height: Jarak.sm),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final berkas = widget.berkas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.label, style: context.teks.titleSmall),
            if (widget.wajib)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text('*', style: context.teks.titleSmall?.copyWith(color: Warna.bahaya)),
              ),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: _sibuk ? null : _bukaPilihan,
          borderRadius: BorderRadius.circular(Sudut.md),
          child: Container(
            padding: const EdgeInsets.all(Jarak.md),
            decoration: BoxDecoration(
              color: Warna.permukaan,
              border: Border.all(
                color: berkas == null ? Warna.garis : Warna.merahUtama,
                style: berkas == null ? BorderStyle.solid : BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(Sudut.md),
            ),
            child: Row(
              children: [
                Icon(
                  berkas == null
                      ? HugeIcons.strokeRoundedUpload01
                      : HugeIcons.strokeRoundedFileVerified,
                  color: berkas == null ? Warna.teksKedua : Warna.merahUtama,
                  size: 22,
                ),
                const SizedBox(width: Jarak.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        berkas == null ? 'Ketuk untuk mengunggah' : berkas.uri.pathSegments.last,
                        style: context.teks.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        berkas == null
                            ? 'JPG, PNG, atau PDF — maks. 5MB'
                            : ValidasiBerkas.formatByte(berkas.lengthSync()),
                        style: context.teks.bodySmall?.copyWith(color: Warna.teksKedua),
                      ),
                    ],
                  ),
                ),
                if (_sibuk)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (berkas != null)
                  IconButton(
                    icon: const Icon(HugeIcons.strokeRoundedCancel01),
                    onPressed: () => widget.saatBerubah(null),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
