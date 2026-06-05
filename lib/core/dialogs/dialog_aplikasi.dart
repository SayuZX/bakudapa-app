import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme/dimensi.dart';
import '../theme/warna.dart';

enum NadaDialog { netral, sukses, peringatan, bahaya, info }

class AksiDialog {
  const AksiDialog({
    required this.label,
    this.onTekan,
    this.utama = false,
    this.destruktif = false,
  });

  final String label;
  final VoidCallback? onTekan;
  final bool utama;
  final bool destruktif;
}

class DialogAplikasi {
  DialogAplikasi._();

  static final GlobalKey<NavigatorState> kunciNavigatorRoot =
      GlobalKey<NavigatorState>(debugLabel: 'dialog-root');

  static BuildContext? get _context => kunciNavigatorRoot.currentContext;

  static IconData _ikonNada(NadaDialog n) {
    switch (n) {
      case NadaDialog.sukses:
        return HugeIcons.strokeRoundedCheckmarkCircle02;
      case NadaDialog.peringatan:
        return HugeIcons.strokeRoundedAlert02;
      case NadaDialog.bahaya:
        return HugeIcons.strokeRoundedSecurityLock;
      case NadaDialog.info:
        return HugeIcons.strokeRoundedInformationCircle;
      case NadaDialog.netral:
        return HugeIcons.strokeRoundedHelpCircle;
    }
  }

  static Color _warnaNada(NadaDialog n) {
    switch (n) {
      case NadaDialog.sukses:
        return Warna.sukses;
      case NadaDialog.peringatan:
        return Warna.peringatan;
      case NadaDialog.bahaya:
        return Warna.bahaya;
      case NadaDialog.info:
        return Warna.info;
      case NadaDialog.netral:
        return Warna.teksKedua;
    }
  }

  static Future<T?> tampilkanAlert<T>({
    BuildContext? context,
    required String judul,
    required String pesan,
    NadaDialog nada = NadaDialog.netral,
    List<AksiDialog> aksi = const [],
    bool dapatDitutup = true,
  }) async {
    final ctx = context ?? _context;
    if (ctx == null) return null;
    return showDialog<T>(
      context: ctx,
      barrierDismissible: dapatDitutup,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (d) => _BingkaiDialog<T>(
        judul: judul,
        pesan: pesan,
        nada: nada,
        aksi: aksi.isEmpty
            ? [
                AksiDialog(
                  label: 'OK',
                  utama: true,
                  onTekan: () => Navigator.of(d).pop<T>(),
                )
              ]
            : aksi,
        dapatDitutup: dapatDitutup,
      ),
    );
  }

  static Future<bool> tampilkanKonfirmasi({
    BuildContext? context,
    required String judul,
    required String pesan,
    String labelBatal = 'Batal',
    String labelKonfirmasi = 'Lanjutkan',
    bool destruktif = false,
    NadaDialog nada = NadaDialog.netral,
  }) async {
    final ctx = context ?? _context;
    if (ctx == null) return false;
    final hasil = await showDialog<bool>(
      context: ctx,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (d) => _BingkaiDialog<bool>(
        judul: judul,
        pesan: pesan,
        nada: nada,
        aksi: [
          AksiDialog(
            label: labelBatal,
            onTekan: () => Navigator.of(d).pop(false),
          ),
          AksiDialog(
            label: labelKonfirmasi,
            utama: true,
            destruktif: destruktif,
            onTekan: () => Navigator.of(d).pop(true),
          ),
        ],
        dapatDitutup: true,
      ),
    );
    return hasil ?? false;
  }

  static Future<T?> tampilkanPemblokir<T>({
    BuildContext? context,
    required String judul,
    required String pesan,
    required IconData ikon,
    List<AksiDialog> aksi = const [],
  }) async {
    final ctx = context ?? _context;
    if (ctx == null) return null;
    return showDialog<T>(
      context: ctx,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      useRootNavigator: true,
      builder: (d) => PopScope(
        canPop: false,
        child: _LayarPemblokir<T>(
          judul: judul,
          pesan: pesan,
          ikon: ikon,
          aksi: aksi,
        ),
      ),
    );
  }

  static void tampilkanToast(
    BuildContext context,
    String pesan, {
    NadaDialog nada = NadaDialog.netral,
    Duration durasi = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        duration: durasi,
        content: _IsiToast(pesan: pesan, nada: nada),
      ),
    );
  }
}

class _BingkaiDialog<T> extends StatelessWidget {
  const _BingkaiDialog({
    required this.judul,
    required this.pesan,
    required this.nada,
    required this.aksi,
    required this.dapatDitutup,
  });

  final String judul;
  final String pesan;
  final NadaDialog nada;
  final List<AksiDialog> aksi;
  final bool dapatDitutup;

  @override
  Widget build(BuildContext context) {
    final warna = DialogAplikasi._warnaNada(nada);
    return Dialog(
      backgroundColor: Warna.permukaan,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: warna.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    DialogAplikasi._ikonNada(nada),
                    color: warna,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: Jarak.lg),
              Text(
                judul,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                pesan,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Warna.teksKedua,
                      height: 1.55,
                    ),
              ),
              const SizedBox(height: Jarak.xl),
              _BarisAksi(aksi: aksi),
            ],
          ),
        ),
      ),
    );
  }
}

class _LayarPemblokir<T> extends StatelessWidget {
  const _LayarPemblokir({
    required this.judul,
    required this.pesan,
    required this.ikon,
    required this.aksi,
  });

  final String judul;
  final String pesan;
  final IconData ikon;
  final List<AksiDialog> aksi;

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Warna.permukaan,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: Warna.bahayaLembut,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(ikon, color: Warna.bahaya, size: 44),
              ),
              const SizedBox(height: Jarak.xxl),
              Text(
                judul,
                textAlign: TextAlign.center,
                style: teks.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: Jarak.md),
              Text(
                pesan,
                textAlign: TextAlign.center,
                style: teks.bodyMedium?.copyWith(
                  color: Warna.teksKedua,
                  height: 1.55,
                ),
              ),
              const Spacer(flex: 3),
              for (var i = 0; i < aksi.length; i++) ...[
                if (i > 0) const SizedBox(height: Jarak.md),
                _TombolAksiPenuh(aksi: aksi[i]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BarisAksi extends StatelessWidget {
  const _BarisAksi({required this.aksi});
  final List<AksiDialog> aksi;

  @override
  Widget build(BuildContext context) {
    if (aksi.isEmpty) return const SizedBox.shrink();
    if (aksi.length == 1) {
      return _TombolAksiPenuh(aksi: aksi.first);
    }
    return Row(
      children: [
        for (var i = 0; i < aksi.length; i++) ...[
          if (i > 0) const SizedBox(width: Jarak.sm),
          Expanded(child: _TombolAksiPenuh(aksi: aksi[i])),
        ],
      ],
    );
  }
}

class _TombolAksiPenuh extends StatelessWidget {
  const _TombolAksiPenuh({required this.aksi});
  final AksiDialog aksi;

  @override
  Widget build(BuildContext context) {
    if (aksi.utama) {
      return SizedBox(
        height: 48,
        child: FilledButton(
          onPressed: aksi.onTekan,
          style: FilledButton.styleFrom(
            backgroundColor:
                aksi.destruktif ? Warna.bahaya : Warna.merahUtama,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: Text(aksi.label),
        ),
      );
    }
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: aksi.onTekan,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Warna.garisTegas, width: 1.2),
          foregroundColor: Warna.teksUtama,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(aksi.label),
      ),
    );
  }
}

class _IsiToast extends StatelessWidget {
  const _IsiToast({required this.pesan, required this.nada});
  final String pesan;
  final NadaDialog nada;

  @override
  Widget build(BuildContext context) {
    final warna = DialogAplikasi._warnaNada(nada);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Warna.permukaan,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Warna.garis),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: warna.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(DialogAplikasi._ikonNada(nada), color: warna, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  pesan,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void tutupKeyboard() {
  SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
}
