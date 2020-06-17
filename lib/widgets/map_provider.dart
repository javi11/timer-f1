import 'package:flutter_map/flutter_map.dart';

TileLayerOptions mapProvider = TileLayerOptions(
    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
    subdomains: ['a', 'b', 'c']);
