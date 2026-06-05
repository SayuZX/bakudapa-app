import 'dart:io';

class HasilDetektorVpn {
  const HasilDetektorVpn({required this.aktif, this.antarmuka, this.galat});
  final bool aktif;
  final String? antarmuka;
  final String? galat;
}

class DetektorVpn {
  DetektorVpn._();
  static final DetektorVpn instance = DetektorVpn._();

  static const Set<String> _polaAntarmukaVpn = {
    'tun',
    'tap',
    'ppp',
    'ipsec',
    'utun',
    'pptp',
    'l2tp',
    'wg',
  };

  Future<HasilDetektorVpn> periksa() async {
    try {
      final antarmuka = await NetworkInterface.list(
        includeLoopback: false,
        includeLinkLocal: false,
        type: InternetAddressType.any,
      );

      for (final a in antarmuka) {
        final nama = a.name.toLowerCase();
        for (final pola in _polaAntarmukaVpn) {
          if (nama.startsWith(pola)) {
            return HasilDetektorVpn(aktif: true, antarmuka: a.name);
          }
        }
      }
      return const HasilDetektorVpn(aktif: false);
    } catch (e) {
      return HasilDetektorVpn(aktif: false, galat: e.toString());
    }
  }
}
