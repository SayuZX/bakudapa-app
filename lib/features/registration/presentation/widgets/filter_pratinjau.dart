import 'package:flutter/material.dart';

enum FilterPratinjau {
  normal,
  negatif,
  grayscaleKontras,
  sepia,
  cyanDingin,
  termalMerah,
}

extension FilterPratinjauX on FilterPratinjau {
  String get nama {
    switch (this) {
      case FilterPratinjau.normal:
        return 'normal';
      case FilterPratinjau.negatif:
        return 'negatif';
      case FilterPratinjau.grayscaleKontras:
        return 'edge_grayscale';
      case FilterPratinjau.sepia:
        return 'sepia';
      case FilterPratinjau.cyanDingin:
        return 'night_vision';
      case FilterPratinjau.termalMerah:
        return 'thermal';
    }
  }

  static FilterPratinjau untukIndeks(int i) {
    const urutan = [
      FilterPratinjau.negatif,
      FilterPratinjau.grayscaleKontras,
      FilterPratinjau.cyanDingin,
      FilterPratinjau.termalMerah,
      FilterPratinjau.sepia,
    ];
    if (i < 0) return FilterPratinjau.normal;
    return urutan[i % urutan.length];
  }

  ColorFilter? get filter {
    switch (this) {
      case FilterPratinjau.normal:
        return null;
      case FilterPratinjau.negatif:
        return const ColorFilter.matrix([
          -1, 0, 0, 0, 255,
          0, -1, 0, 0, 255,
          0, 0, -1, 0, 255,
          0, 0, 0, 1, 0,
        ]);
      case FilterPratinjau.grayscaleKontras:
        return const ColorFilter.matrix([
          1.6, 1.6, 1.6, 0, -200,
          1.6, 1.6, 1.6, 0, -200,
          1.6, 1.6, 1.6, 0, -200,
          0, 0, 0, 1, 0,
        ]);
      case FilterPratinjau.sepia:
        return const ColorFilter.matrix([
          0.393, 0.769, 0.189, 0, 0,
          0.349, 0.686, 0.168, 0, 0,
          0.272, 0.534, 0.131, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case FilterPratinjau.cyanDingin:
        return const ColorFilter.matrix([
          0, 0, 0, 0, 0,
          0.8, 1.2, 0.4, 0, -20,
          0.6, 0.9, 1.4, 0, 10,
          0, 0, 0, 1, 0,
        ]);
      case FilterPratinjau.termalMerah:
        return const ColorFilter.matrix([
          1.8, 0.4, 0.2, 0, -40,
          0.3, 1.0, 0.4, 0, -30,
          0.2, 0.3, 1.2, 0, -60,
          0, 0, 0, 1, 0,
        ]);
    }
  }
}

class FilterKameraOverlay extends StatelessWidget {
  const FilterKameraOverlay({
    super.key,
    required this.aktif,
    required this.indeks,
    required this.child,
  });

  final bool aktif;
  final int indeks;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!aktif) return child;
    final filter = FilterPratinjauX.untukIndeks(indeks).filter;
    if (filter == null) return child;
    return ColorFiltered(colorFilter: filter, child: child);
  }
}
