import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/extensions/konteks.dart';
import '../../core/theme/warna.dart';

class KotakIsian extends StatefulWidget {
  const KotakIsian({
    super.key,
    this.label,
    this.petunjuk,
    this.bantuan,
    this.pengatur,
    this.nilaiAwal,
    this.tipeMasukan,
    this.aksiMasukan,
    this.tersembunyi = false,
    this.panjangMaks,
    this.barisMaks = 1,
    this.barisMin,
    this.aktif = true,
    this.bacaSaja = false,
    this.fokusOtomatis = false,
    this.saatBerubah,
    this.saatKirim,
    this.validator,
    this.formatter,
    this.ikonAwal,
    this.ikonAkhir,
    this.wajib = false,
    this.saatKetuk,
    this.prefiks,
  });

  final String? label;
  final String? petunjuk;
  final String? bantuan;
  final TextEditingController? pengatur;
  final String? nilaiAwal;
  final TextInputType? tipeMasukan;
  final TextInputAction? aksiMasukan;
  final bool tersembunyi;
  final int? panjangMaks;
  final int? barisMaks;
  final int? barisMin;
  final bool aktif;
  final bool bacaSaja;
  final bool fokusOtomatis;
  final void Function(String)? saatBerubah;
  final void Function(String)? saatKirim;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? formatter;
  final IconData? ikonAwal;
  final Widget? ikonAkhir;
  final bool wajib;
  final VoidCallback? saatKetuk;
  final String? prefiks;

  @override
  State<KotakIsian> createState() => _KotakIsianState();
}

class _KotakIsianState extends State<KotakIsian> {
  late bool _sembunyi = widget.tersembunyi;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: context.teks.titleSmall?.copyWith(color: Warna.teksUtama),
              ),
              if (widget.wajib)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '*',
                    style: context.teks.titleSmall?.copyWith(color: Warna.bahaya),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.pengatur,
          initialValue: widget.nilaiAwal,
          keyboardType: widget.tipeMasukan,
          textInputAction: widget.aksiMasukan,
          obscureText: _sembunyi,
          maxLength: widget.panjangMaks,
          maxLines: widget.tersembunyi ? 1 : widget.barisMaks,
          minLines: widget.barisMin,
          enabled: widget.aktif,
          readOnly: widget.bacaSaja,
          autofocus: widget.fokusOtomatis,
          onChanged: widget.saatBerubah,
          onFieldSubmitted: widget.saatKirim,
          validator: widget.validator,
          inputFormatters: widget.formatter,
          onTap: widget.saatKetuk,
          autocorrect: false,
          enableSuggestions: !widget.tersembunyi,
          decoration: InputDecoration(
            hintText: widget.petunjuk,
            helperText: widget.bantuan,
            counterText: '',
            prefixText: widget.prefiks,
            prefixStyle: widget.prefiks == null
                ? null
                : TextStyle(
                    color: Warna.teksUtama,
                    fontWeight: FontWeight.w700,
                    fontSize:
                        Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16,
                  ),
            prefixIcon: widget.ikonAwal == null ? null : Icon(widget.ikonAwal, size: 20),
            suffixIcon: widget.tersembunyi
                ? IconButton(
                    icon: Icon(
                      _sembunyi
                          ? HugeIcons.strokeRoundedView
                          : HugeIcons.strokeRoundedViewOffSlash,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _sembunyi = !_sembunyi),
                  )
                : widget.ikonAkhir,
          ),
        ),
      ],
    );
  }
}
