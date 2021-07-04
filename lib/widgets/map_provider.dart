import 'package:flutter_map/flutter_map.dart';

TileLayerWidget mapProvider = TileLayerWidget(
    options: TileLayerOptions(
        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        subdomains: ['a', 'b', 'c']));
