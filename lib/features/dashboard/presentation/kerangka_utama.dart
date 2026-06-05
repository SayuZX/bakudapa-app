import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/localization/teks.dart';
import '../../../core/theme/warna.dart';
import '../../../shared/providers/penyedia_pemberitahuan.dart';

class KerangkaUtama extends ConsumerWidget {
  const KerangkaUtama({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _pilih(int indeks) {
    navigationShell.goBranch(
      indeks,
      initialLocation: indeks == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(teksProvider);
    final belumDibaca = ref.watch(penyediaJumlahBelumDibaca);
    final diBeranda = navigationShell.currentIndex == 0;

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
        body: navigationShell,
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Warna.garis, width: 0.6)),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
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
      backgroundColor: Warna.merahUtama,
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
