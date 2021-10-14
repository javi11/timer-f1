import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

StorageCachingTileProvider tileProvider = StorageCachingTileProvider();
TileLayerWidget mapProvider = TileLayerWidget(
    options: TileLayerOptions(
        tileProvider: tileProvider,
        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        subdomains: ['a', 'b', 'c']));
