import 'package:flutter/material.dart';

import '../../core/theme/dimensi.dart';

class TombolGaris extends StatelessWidget {
  const TombolGaris({
    super.key,
    required this.label,
    required this.saatTekan,
    this.ikon,
    this.melebar = true,
  });

  final String label;
  final VoidCallback? saatTekan;
  final Widget? ikon;
  final bool melebar;

  @override
  Widget build(BuildContext context) {
    final isi = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (ikon != null) ...[
          ikon!,
          const SizedBox(width: Jarak.sm),
        ],
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
    final tombol = OutlinedButton(onPressed: saatTekan, child: isi);
    return melebar ? SizedBox(width: double.infinity, child: tombol) : tombol;
  }
}
