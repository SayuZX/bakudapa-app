import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/system/layanan_status_sistem.dart';
import '../../core/system/model_status_maintenance.dart';

final layananStatusSistemProvider =
    Provider<LayananStatusSistem>((ref) => LayananStatusSistem.instance);

final aliranStatusMaintenanceProvider =
    StreamProvider<StatusMaintenance>((ref) {
  final layanan = ref.watch(layananStatusSistemProvider);
  return layanan.aliran;
});

final statusMaintenanceProvider = Provider<StatusMaintenance>((ref) {
  final aliran = ref.watch(aliranStatusMaintenanceProvider);
  return aliran.maybeWhen(
    data: (s) => s,
    orElse: () =>
        ref.read(layananStatusSistemProvider).terakhir,
  );
});
