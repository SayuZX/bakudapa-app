import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/extensions/konteks.dart';
import '../../core/theme/warna.dart';

class KotakIsianSensitif extends StatefulWidget {
  const KotakIsianSensitif({
    super.key,
    required this.pengatur,
    required this.penyamar,
    this.label,
    this.petunjuk,
    this.bantuan,
    this.prefiks,
    this.tipeMasukan,
    this.aksiMasukan,
    this.panjangMaks,
    this.formatter,
    this.validator,
    this.saatKirim,
    this.ikonAwal,
    this.wajib = false,
    this.aktifkanLihatSementara = true,
  });

  final TextEditingController pengatur;
  final String Function(String nilai) penyamar;
  final String? label;
  final String? petunjuk;
  final String? bantuan;
  final String? prefiks;
  final TextInputType? tipeMasukan;
  final TextInputAction? aksiMasukan;
  final int? panjangMaks;
  final List<TextInputFormatter>? formatter;
  final String? Function(String?)? validator;
  final void Function(String)? saatKirim;
  final IconData? ikonAwal;
  final bool wajib;
  final bool aktifkanLihatSementara;

  @override
  State<KotakIsianSensitif> createState() => _KotakIsianSensitifState();
}

class _KotakIsianSensitifState extends State<KotakIsianSensitif> {
  final FocusNode _fokus = FocusNode();
  late final TextEditingController _tampil;
  bool _paksaTampilkan = false;

  @override
  void initState() {
    super.initState();
    _tampil = TextEditingController(text: _format(widget.pengatur.text));
    _fokus.addListener(_padaPerubahanFokus);
    widget.pengatur.addListener(_sinkronEksternal);
  }

  @override
  void dispose() {
    _fokus.removeListener(_padaPerubahanFokus);
    widget.pengatur.removeListener(_sinkronEksternal);
    _fokus.dispose();
    _tampil.dispose();
    super.dispose();
  }

  String _format(String nilai) {
    if (nilai.isEmpty) return '';
    return widget.penyamar(nilai);
  }

  void _padaPerubahanFokus() {
    if (!mounted) return;
    if (_fokus.hasFocus) {
      _tampil.value = TextEditingValue(
        text: widget.pengatur.text,
        selection: TextSelection.collapsed(
          offset: widget.pengatur.text.length,
        ),
      );
      if (_paksaTampilkan) {
        setState(() => _paksaTampilkan = false);
      }
    } else {
      _tampil.text =
          _paksaTampilkan ? widget.pengatur.text : _format(widget.pengatur.text);
    }
  }

  void _sinkronEksternal() {
    if (_fokus.hasFocus) return;
    final teksTampil =
        _paksaTampilkan ? widget.pengatur.text : _format(widget.pengatur.text);
    if (_tampil.text != teksTampil) {
      _tampil.text = teksTampil;
    }
  }

  void _padaBerubah(String nilai) {
    if (_fokus.hasFocus) {
      widget.pengatur.text = nilai;
    }
  }

  void _togglePaksaTampilkan() {
    setState(() => _paksaTampilkan = !_paksaTampilkan);
    if (!_fokus.hasFocus) {
      _tampil.text =
          _paksaTampilkan ? widget.pengatur.text : _format(widget.pengatur.text);
    }
  }

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
                style:
                    context.teks.titleSmall?.copyWith(color: Warna.teksUtama),
              ),
              if (widget.wajib)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '*',
                    style:
                        context.teks.titleSmall?.copyWith(color: Warna.bahaya),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: _tampil,
          focusNode: _fokus,
          keyboardType: widget.tipeMasukan,
          textInputAction: widget.aksiMasukan,
          maxLength: widget.panjangMaks,
          onChanged: _padaBerubah,
          onFieldSubmitted: widget.saatKirim,
          validator: (_) => widget.validator?.call(widget.pengatur.text),
          inputFormatters: widget.formatter,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            hintText: widget.petunjuk,
            helperText: widget.bantuan,
            counterText: '',
            prefixText: widget.prefiks,
            prefixIcon: widget.ikonAwal == null
                ? null
                : Icon(widget.ikonAwal, size: 20),
            suffixIcon: widget.aktifkanLihatSementara &&
                    widget.pengatur.text.isNotEmpty &&
                    !_fokus.hasFocus
                ? IconButton(
                    onPressed: _togglePaksaTampilkan,
                    icon: Icon(
                      _paksaTampilkan
                          ? HugeIcons.strokeRoundedViewOffSlash
                          : HugeIcons.strokeRoundedView,
                      size: 20,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
