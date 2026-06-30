import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/localization/teks.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/providers/penyedia_pemberitahuan.dart';

class KerangkaUtama extends ConsumerStatefulWidget {
  const KerangkaUtama({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<KerangkaUtama> createState() => _KerangkaUtamaState();
}

class _KerangkaUtamaState extends ConsumerState<KerangkaUtama>
    with WidgetsBindingObserver {
  static const int _indeksNotifikasi = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    ref.read(penyediaJumlahBelumDibaca.notifier).segarkan();
    if (widget.navigationShell.currentIndex == _indeksNotifikasi) {
      ref.read(penyediaPemberitahuan.notifier).segarkan();
    }
  }

  void _pilih(int indeks) {
    widget.navigationShell.goBranch(
      indeks,
      initialLocation: indeks == widget.navigationShell.currentIndex,
    );
    if (indeks == _indeksNotifikasi) {
      ref.read(penyediaJumlahBelumDibaca.notifier).segarkan();
      ref.read(penyediaPemberitahuan.notifier).segarkan();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(teksProvider);
    final belumDibaca = ref.watch(penyediaJumlahBelumDibaca);
    final diBeranda = widget.navigationShell.currentIndex == 0;

    final tab = <_Tab>[
      _Tab(
        t.tabBeranda,
        HugeIcons.strokeRoundedHome01,
        HugeIcons.strokeRoundedHome11,
      ),
      _Tab(
        t.tabPermohonan,
        HugeIcons.strokeRoundedFile02,
        HugeIcons.strokeRoundedFile02,
      ),
      _Tab(
        t.tabAsisten,
        HugeIcons.strokeRoundedAiChat02,
        HugeIcons.strokeRoundedAiChat02,
      ),
      _Tab(
        t.tabNotifikasi,
        HugeIcons.strokeRoundedNotification01,
        HugeIcons.strokeRoundedNotification01,
        lencana: belumDibaca,
      ),
      _Tab(
        t.tabProfil,
        HugeIcons.strokeRoundedUser,
        HugeIcons.strokeRoundedUserCircle,
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (sudahPop, _) {
        if (sudahPop) return;
        if (!diBeranda) {
          _pilih(0);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Warna.garis, width: 0.6)),
          ),
          child: NavigationBar(
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: _pilih,
            destinations: [
              for (final d in tab)
                NavigationDestination(
                  icon: _IkonTab(ikon: d.ikon, lencana: d.lencana),
                  selectedIcon: _IkonTab(ikon: d.ikonAktif, lencana: d.lencana),
                  label: d.label,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IkonTab extends StatelessWidget {
  const _IkonTab({required this.ikon, this.lencana = 0});
  final IconData ikon;
  final int lencana;

  @override
  Widget build(BuildContext context) {
    if (lencana <= 0) return Icon(ikon);
    return Badge(
      label: Text(lencana > 9 ? '9+' : '$lencana'),
      backgroundColor: Warna.bahaya,
      child: Icon(ikon),
    );
  }
}

class _Tab {
  const _Tab(this.label, this.ikon, this.ikonAktif, {this.lencana = 0});
  final String label;
  final IconData ikon;
  final IconData ikonAktif;
  final int lencana;
}
