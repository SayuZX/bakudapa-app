import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/extensions/konteks.dart';
import '../../../../core/theme/dimensi.dart';
import '../../../../core/theme/warna.dart';

class ChipSaranAi extends StatelessWidget {
  const ChipSaranAi({super.key, required this.label, required this.saatKetuk});

  final String label;
  final VoidCallback saatKetuk;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const StadiumBorder(side: BorderSide(color: Warna.garis)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          saatKetuk();
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Jarak.lg,
              vertical: Jarak.sm + 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: context.teks.bodyMedium?.copyWith(
                      color: Warna.teksUtama,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: Jarak.sm),
                const Icon(
                  HugeIcons.strokeRoundedArrowUpRight01,
                  size: 15,
                  color: Warna.teksKetiga,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
