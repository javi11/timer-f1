import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:timerf1c/offline_maps/widgets/download_progress.dart';
import 'package:timerf1c/providers/map_provider.dart';

class DownloadMapRegionPage extends StatefulWidget {
  DownloadMapRegionPage({Key? key}) : super(key: key);
  @override
  _DownloadMapRegionPageState createState() => _DownloadMapRegionPageState();
}

double squareNorthThreshold = 0.001;
double squareSouthThreshold = 0.0025;

class _DownloadMapRegionPageState extends State<DownloadMapRegionPage> {
  MapController? mapController;
  late StreamController<double> _centerCurrentLocationStreamController;
  late CenterOnLocationUpdate _centerOnLocationUpdate;
  RectangleRegion? _selectedBoundsSqrRegion;
  late StreamSubscription<MapEvent> _mapEventListener;
  late StorageCachingTileProvider _tileProvider;
  late StreamController<DownloadProgress> _downloadStreamController;

  _drawDownloadArea() {
    double south = mapController!.bounds!.south > 0
        ? mapController!.bounds!.south + squareSouthThreshold
        : mapController!.bounds!.south - squareSouthThreshold;
    double north = mapController!.bounds!.north > 0
        ? mapController!.bounds!.north - squareNorthThreshold
        : mapController!.bounds!.north + squareNorthThreshold;
    double west = mapController!.bounds!.west > 0
        ? mapController!.bounds!.west + squareNorthThreshold
        : mapController!.bounds!.west - squareNorthThreshold;
    double east = mapController!.bounds!.east > 0
        ? mapController!.bounds!.east - squareNorthThreshold
        : mapController!.bounds!.east + squareNorthThreshold;

    final sw = LatLng(south, west);
    final ne = LatLng(north, east);
    setState(() {
      _selectedBoundsSqrRegion = RectangleRegion(LatLngBounds(sw, ne));
    });
  }

  void _showErrorSnack(String errorMessage) async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Selection error',
      desc: errorMessage,
      btnOkText: 'Ok',
      btnOkOnPress: () {},
    ).show();
  }

  void initState() {
    super.initState();

    _tileProvider = StorageCachingTileProvider();
    _centerOnLocationUpdate = CenterOnLocationUpdate.first;
    _centerCurrentLocationStreamController = StreamController<double>();
    mapController = MapController();

    _mapEventListener = mapController!.mapEventStream.listen((event) {
      if (event is MapEventMove) {
        _drawDownloadArea();
      }
    });
  }

  _downloadRegionForeground() {
    _downloadStreamController = new StreamController();
    final downloableRegionStream =
        _tileProvider.downloadRegion(_selectedBoundsSqrRegion!.toDownloadable(
            8,
            17,
            TileLayerOptions(
              tileProvider: _tileProvider,
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            )));

    AwesomeDialog(
      btnCancelOnPress: () {
        if (!_downloadStreamController.isClosed) {
          _downloadStreamController.close();
        }
      },
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.NO_HEADER,
      body: StreamBuilder<DownloadProgress>(
        initialData: DownloadProgress.placeholder(),
        stream: _downloadStreamController.stream.asBroadcastStream(),
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            return Text('error: ${snapshot.error.toString()}');
          }
          final tileIndex = snapshot.data?.completedTiles ?? 0;
          final tilesAmount = snapshot.data?.totalTiles ?? 0;
          final tilesErrored = snapshot.data?.erroredTiles ?? [];
          final progressPercentage = snapshot.data?.percentageProgress ?? 0;
          return getLoadProgresWidget(
              ctx, tileIndex, tilesAmount, tilesErrored, progressPercentage);
        },
      ),
      title: 'Downloading Area...',
    )..show();
    _downloadStreamController.addStream(downloableRegionStream);
  }

  Future<void> _onDownloadRegion() async {
    final downloadableRegion = _selectedBoundsSqrRegion!.toDownloadable(
        8,
        17,
        TileLayerOptions(
          tileProvider: _tileProvider,
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ));
    final approximateTileCount =
        StorageCachingTileProvider.checkRegion(downloadableRegion);
    if (approximateTileCount >
        StorageCachingTileProvider.kMaxPreloadTileAreaCount) {
      _showErrorSnack('Selected area to large, please select an smaller area.');
      return;
    }
    final isAllowBackgroundDownload =
        await StorageCachingTileProvider.requestIgnoreBatteryOptimizations(
            context);
    if (!isAllowBackgroundDownload) {
      _downloadRegionForeground();
    } else {
      _tileProvider.downloadRegionBackground(downloadableRegion);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _mapEventListener.cancel();
    _centerCurrentLocationStreamController.close();
    _downloadStreamController.close();
  }

  @override
  Widget build(BuildContext context) {
    // Do not allow rotate the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    LocationMarkerPlugin locationMarkerPlugin = LocationMarkerPlugin(
      centerCurrentLocationStream:
          _centerCurrentLocationStreamController.stream,
      centerOnLocationUpdate: _centerOnLocationUpdate,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        centerTitle: true,
        title: Text('Download map region'),
        automaticallyImplyLeading: true,
      ),
      bottomSheet: TextButton.icon(
          onPressed: _onDownloadRegion,
          icon: Icon(Icons.download_for_offline),
          label: Text('Download Region')),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 140,
          child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                zoom: 15.0,
                interactiveFlags: InteractiveFlag.all,
              ),
              children: [
                mapProvider,
                LocationMarkerLayerWidget(
                  plugin: locationMarkerPlugin,
                  options: LocationMarkerLayerOptions(
                      showAccuracyCircle: true, showHeadingSector: true),
                ),
              ],
              layers: [
                _selectedBoundsSqrRegion == null
                    ? PolygonLayerOptions()
                    : _selectedBoundsSqrRegion!.toDrawable(
                        Colors.green.withAlpha(128),
                        Colors.green,
                      ),
              ])),
    );
  }
}
