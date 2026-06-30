import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/warna.dart';

class IsianGarisBawah extends StatefulWidget {
  const IsianGarisBawah({
    super.key,
    required this.petunjuk,
    this.pengatur,
    this.tipeMasukan,
    this.aksiMasukan,
    this.tersembunyi = false,
    this.validator,
    this.saatKirim,
    this.formatter,
    this.prefiks,
    this.aksi,
    this.tampilkanToggleSandi = false,
  });

  final String petunjuk;
  final TextEditingController? pengatur;
  final TextInputType? tipeMasukan;
  final TextInputAction? aksiMasukan;
  final bool tersembunyi;
  final String? Function(String?)? validator;
  final void Function(String)? saatKirim;
  final List<TextInputFormatter>? formatter;
  final String? prefiks;
  final Widget? aksi;
  final bool tampilkanToggleSandi;

  @override
  State<IsianGarisBawah> createState() => _IsianGarisBawahState();
}

class _IsianGarisBawahState extends State<IsianGarisBawah> {
  late bool _sembunyi = widget.tersembunyi;

  @override
  Widget build(BuildContext context) {
    final Widget? sufiks = widget.tampilkanToggleSandi
        ? IconButton(
            icon: Icon(
              _sembunyi ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Warna.teksKetiga,
              size: 20,
            ),
            onPressed: () => setState(() => _sembunyi = !_sembunyi),
          )
        : widget.aksi;

    return TextFormField(
      controller: widget.pengatur,
      keyboardType: widget.tipeMasukan,
      textInputAction: widget.aksiMasukan,
      obscureText: _sembunyi,
      validator: widget.validator,
      onFieldSubmitted: widget.saatKirim,
      inputFormatters: widget.formatter,
      autocorrect: false,
      enableSuggestions: !widget.tersembunyi,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Warna.teksUtama,
        letterSpacing: 0.2,
      ),
      decoration: InputDecoration(
        hintText: widget.petunjuk,
        hintStyle: const TextStyle(
          color: Warna.teksKetiga,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        prefixText: widget.prefiks,
        prefixStyle: const TextStyle(
          color: Warna.teksKetiga,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        suffixIcon: sufiks,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        filled: false,
        isDense: false,
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Warna.garis, width: 1.2),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Warna.garis, width: 1.2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Warna.primer, width: 1.6),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Warna.bahaya, width: 1.2),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Warna.bahaya, width: 1.6),
        ),
        errorStyle: const TextStyle(
          color: Warna.bahaya,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
