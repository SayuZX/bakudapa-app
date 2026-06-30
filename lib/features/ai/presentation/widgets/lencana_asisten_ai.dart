import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/warna.dart';

class LencanaAsistenAi extends StatelessWidget {
  const LencanaAsistenAi({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 2),
      child: Icon(
        HugeIcons.strokeRoundedSparkles,
        size: 20,
        color: Warna.primer,
      ),
    );
  }
}
