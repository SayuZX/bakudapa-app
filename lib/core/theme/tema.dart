import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dimensi.dart';
import 'tipografi.dart';
import 'warna.dart';

class Tema {
  const Tema._();

  static ThemeData terang() {
    final ColorScheme skema = ColorScheme.fromSeed(
      seedColor: Warna.primer,
      brightness: Brightness.light,
      primary: Warna.primer,
      onPrimary: Warna.putih,
      primaryContainer: Warna.primerLembut,
      onPrimaryContainer: Warna.primerGelap,
      surface: Warna.permukaan,
      onSurface: Warna.teksUtama,
      surfaceContainerHighest: Warna.netral100,
      outline: Warna.garis,
      outlineVariant: Warna.garisTegas,
      error: Warna.bahaya,
      onError: Colors.white,
    );

    final TextTheme teksTema = Tipografi.bangun();

    return ThemeData(
      useMaterial3: true,
      colorScheme: skema,
      scaffoldBackgroundColor: Warna.latar,
      canvasColor: Warna.latar,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      textTheme: teksTema,
      primaryTextTheme: teksTema,
      appBarTheme: AppBarTheme(
        backgroundColor: Warna.permukaan,
        foregroundColor: Warna.teksUtama,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleSpacing: Jarak.layarH,
        titleTextStyle: teksTema.titleLarge,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: Warna.permukaan,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sudut.lg),
          side: const BorderSide(color: Warna.garis),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Warna.pemisah, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Warna.permukaan,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: teksTema.bodyMedium?.copyWith(color: Warna.teksKetiga),
        labelStyle: teksTema.titleSmall?.copyWith(color: Warna.teksKedua),
        floatingLabelStyle: teksTema.titleSmall?.copyWith(color: Warna.primer),
        prefixIconColor: Warna.teksKedua,
        suffixIconColor: Warna.teksKedua,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sudut.md),
          borderSide: const BorderSide(color: Warna.garis),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sudut.md),
          borderSide: const BorderSide(color: Warna.garis),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sudut.md),
          borderSide: const BorderSide(color: Warna.primer, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sudut.md),
          borderSide: const BorderSide(color: Warna.bahaya),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sudut.md),
          borderSide: const BorderSide(color: Warna.bahaya, width: 1.4),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sudut.md),
          borderSide: const BorderSide(color: Warna.garis),
        ),
        errorStyle: teksTema.bodySmall?.copyWith(color: Warna.bahaya),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Warna.primer,
          foregroundColor: Warna.putih,
          disabledBackgroundColor: Warna.netral200,
          disabledForegroundColor: Warna.teksNonaktif,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sudut.md)),
          textStyle: teksTema.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Warna.teksUtama,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: Warna.garisTegas),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sudut.md)),
          textStyle: teksTema.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Warna.primer,
          textStyle: teksTema.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sudut.sm)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: Warna.teksUtama,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sudut.sm)),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Warna.primer;
          return Warna.permukaan;
        }),
        checkColor: WidgetStateProperty.all(Warna.putih),
        side: const BorderSide(color: Warna.garisTegas, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Warna.putih;
          return Warna.permukaan;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Warna.primer;
          return Warna.netral300;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Warna.netral100,
        selectedColor: Warna.primerLembut,
        labelStyle: teksTema.labelMedium,
        secondaryLabelStyle: teksTema.labelMedium?.copyWith(color: Warna.primerGelap),
        side: const BorderSide(color: Colors.transparent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sudut.pil)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Warna.permukaan,
        indicatorColor: Warna.primerLembut,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return teksTema.labelSmall?.copyWith(color: Warna.primer, fontWeight: FontWeight.w700);
          }
          return teksTema.labelSmall?.copyWith(color: Warna.teksKetiga);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Warna.primer, size: 24);
          }
          return const IconThemeData(color: Warna.teksKetiga, size: 24);
        }),
        height: 68,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Warna.netral900,
        contentTextStyle: teksTema.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sudut.md)),
        actionTextColor: Warna.primerLembut,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Warna.permukaan,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sudut.xl)),
        titleTextStyle: teksTema.titleLarge,
        contentTextStyle: teksTema.bodyMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Warna.permukaan,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Sudut.xl)),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: Warna.netral900,
          borderRadius: BorderRadius.circular(Sudut.sm),
        ),
        textStyle: teksTema.bodySmall?.copyWith(color: Colors.white),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Warna.primer,
        circularTrackColor: Warna.netral200,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
