import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

Future<List<String>> getDownloadedMaps() async {
  final List<String> cacheNames = [];
  for (String cacheName in await TileStorageCachingManager.allCacheNames) {
    cacheNames.add(cacheName);
  }

  return cacheNames;
}
