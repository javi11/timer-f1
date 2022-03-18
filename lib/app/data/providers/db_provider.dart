import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:objectbox/objectbox.dart';

final dbProvider = Provider<Store>((ref) {
  throw UnimplementedError('Database not initialized.');
});
