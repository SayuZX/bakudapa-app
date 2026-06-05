import 'package:flutter/material.dart';

class MesinRestart extends StatefulWidget {
  const MesinRestart({super.key, required this.anak});

  final Widget anak;

  static final GlobalKey<MesinRestartState> kunci =
      GlobalKey<MesinRestartState>();

  static void mulaiUlang() {
    kunci.currentState?.mulaiUlang();
  }

  @override
  State<MesinRestart> createState() => MesinRestartState();
}

class MesinRestartState extends State<MesinRestart> {
  Key _kunciIsi = UniqueKey();

  void mulaiUlang() {
    setState(() => _kunciIsi = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _kunciIsi, child: widget.anak);
  }
}
