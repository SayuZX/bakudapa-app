class WaktuServer {
  WaktuServer._();

  static Duration _offset = Duration.zero;

  static void perbarui(DateTime serverUtc) {
    _offset = serverUtc.difference(DateTime.now().toUtc());
  }

  static DateTime kini() => DateTime.now().toUtc().add(_offset);
}
