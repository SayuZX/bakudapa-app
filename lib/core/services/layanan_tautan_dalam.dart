import 'dart:async';

import 'package:app_links/app_links.dart';

class LayananTautanDalam {
  LayananTautanDalam._();
  static final LayananTautanDalam instance = LayananTautanDalam._();

  static const String _hostUniversal = 'bakudapa.malutprov.go.id';

  static String? tokenResetDari(Uri tautan) {
    final skemaKustom =
        tautan.scheme == 'bakudapa' && tautan.host == 'reset-password';
    final tautanUniversal = tautan.scheme == 'https' &&
        tautan.host == _hostUniversal &&
        tautan.path.startsWith('/reset-password');
    if (!skemaKustom && !tautanUniversal) return null;
    final token = tautan.queryParameters['token'] ?? '';
    return token.isEmpty ? null : token;
  }

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _langganan;
  bool _mulai = false;

  Future<void> mulai(void Function(Uri tautan) saatTautan) async {
    if (_mulai) return;
    _mulai = true;
    try {
      final awal = await _appLinks.getInitialLink();
      if (awal != null) saatTautan(awal);
    } catch (_) {}
    _langganan = _appLinks.uriLinkStream.listen(
      saatTautan,
      onError: (_) {},
    );
  }

  void hentikan() {
    _langganan?.cancel();
    _langganan = null;
    _mulai = false;
  }
}
