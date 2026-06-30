import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';

class BilahInputAi extends StatefulWidget {
  const BilahInputAi({
    super.key,
    required this.pengatur,
    required this.memuat,
    required this.saatKirim,
    required this.saatBatal,
    required this.placeholder,
    required this.disclaimer,
    required this.labelHenti,
  });

  final TextEditingController pengatur;
  final bool memuat;
  final VoidCallback saatKirim;
  final VoidCallback saatBatal;
  final String placeholder;
  final String disclaimer;
  final String labelHenti;

  @override
  State<BilahInputAi> createState() => _BilahInputAiState();
}

class _BilahInputAiState extends State<BilahInputAi> {
  final _fokus = FocusNode();

  @override
  void initState() {
    super.initState();
    _fokus.addListener(_perbarui);
  }

  void _perbarui() => setState(() {});

  @override
  void dispose() {
    _fokus.removeListener(_perbarui);
    _fokus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Warna.latar,
      padding: const EdgeInsets.fromLTRB(
        Jarak.layarH,
        Jarak.sm,
        Jarak.layarH,
        Jarak.xs,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.fromLTRB(
                Jarak.xl,
                Jarak.xs,
                Jarak.xs,
                Jarak.xs,
              ),
              decoration: BoxDecoration(
                color: Warna.permukaan,
                borderRadius: BorderRadius.circular(Sudut.pil),
                border: Border.all(
                  color: _fokus.hasFocus ? Warna.primer : Warna.garis,
                  width: _fokus.hasFocus ? 1.4 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.pengatur,
                      focusNode: _fokus,
                      enabled: !widget.memuat,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => widget.saatKirim(),
                      style: context.teks.bodyMedium?.copyWith(
                        color: Warna.teksUtama,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: widget.placeholder,
                        hintStyle: context.teks.bodyMedium?.copyWith(
                          color: Warna.teksKetiga,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: Jarak.md,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Jarak.sm),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: widget.pengatur,
                    builder: (context, nilai, _) {
                      final dapatKirim =
                          !widget.memuat && nilai.text.trim().isNotEmpty;
                      return _TombolKirim(
                        aktif: dapatKirim,
                        memuat: widget.memuat,
                        saatKirim: widget.saatKirim,
                        saatBatal: widget.saatBatal,
                        labelHenti: widget.labelHenti,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: Jarak.sm),
            Text(
              widget.disclaimer,
              textAlign: TextAlign.center,
              style: context.teks.labelSmall?.copyWith(color: Warna.teksKetiga),
            ),
          ],
        ),
      ),
    );
  }
}

class _TombolKirim extends StatelessWidget {
  const _TombolKirim({
    required this.aktif,
    required this.memuat,
    required this.saatKirim,
    required this.saatBatal,
    required this.labelHenti,
  });

  final bool aktif;
  final bool memuat;
  final VoidCallback saatKirim;
  final VoidCallback saatBatal;
  final String labelHenti;

  @override
  Widget build(BuildContext context) {
    final terisi = memuat || aktif;
    return Semantics(
      button: true,
      label: memuat ? labelHenti : null,
      child: Material(
        color: terisi ? Warna.primer : Warna.netral200,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: memuat
              ? saatBatal
              : aktif
              ? saatKirim
              : null,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              memuat
                  ? HugeIcons.strokeRoundedStop
                  : HugeIcons.strokeRoundedSent,
              color: terisi ? Warna.putih : Warna.teksNonaktif,
              size: memuat ? 18 : 20,
            ),
          ),
        ),
      ),
    );
  }
}
