import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final storageProvider = Provider<GetStorage>((ref) {
  throw Exception('Storage not initialized');
});
