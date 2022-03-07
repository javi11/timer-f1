import 'package:flutter_map/flutter_map.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final tileProvider = Provider<NonCachingNetworkTileProvider>(
    (ref) => NonCachingNetworkTileProvider());
