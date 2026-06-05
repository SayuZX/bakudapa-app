class HalamanData<T> {
  const HalamanData({
    required this.daftar,
    required this.halaman,
    required this.totalHalaman,
    required this.totalItem,
  });

  final List<T> daftar;
  final int halaman;
  final int totalHalaman;
  final int totalItem;

  bool get adaHalamanBerikut => halaman < totalHalaman;

  HalamanData<T> gabung(HalamanData<T> berikut) {
    return HalamanData(
      daftar: [...daftar, ...berikut.daftar],
      halaman: berikut.halaman,
      totalHalaman: berikut.totalHalaman,
      totalItem: berikut.totalItem,
    );
  }

  static HalamanData<T> kosong<T>() => HalamanData<T>(
        daftar: const [],
        halaman: 1,
        totalHalaman: 1,
        totalItem: 0,
      );
}
