import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timerf1c/offline_maps/widgets/download_popup.dart';
import 'package:timerf1c/offline_maps/widgets/download_progress.dart';
import 'package:timerf1c/providers/map_provider.dart';

class DownloadMapRegionPage extends StatefulWidget {
  final String regionName;
  final void Function() onPushRegion;
  DownloadMapRegionPage(
      {Key? key, required this.regionName, required this.onPushRegion})
      : super(key: key);
  @override
  _DownloadMapRegionPageState createState() => _DownloadMapRegionPageState();
}

class _DownloadMapRegionPageState extends State<DownloadMapRegionPage> {
  MapController? mapController;
  late StreamController<double> _centerCurrentLocationStreamController;
  late CenterOnLocationUpdate _centerOnLocationUpdate;
  RectangleRegion? _selectedBoundsSqrRegion;
  late StreamSubscription<MapEvent> _mapEventListener;
  late StorageCachingTileProvider _tileProvider;
  StreamController<DownloadProgress>? _downloadStreamController;

  _drawDownloadArea() {
    double south = mapController!.bounds!.south > 0
        ? mapController!.bounds!.south
        : mapController!.bounds!.south;
    double north = mapController!.bounds!.north > 0
        ? mapController!.bounds!.north
        : mapController!.bounds!.north;
    double west = mapController!.bounds!.west > 0
        ? mapController!.bounds!.west
        : mapController!.bounds!.west;
    double east = mapController!.bounds!.east > 0
        ? mapController!.bounds!.east
        : mapController!.bounds!.east;

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
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      var directory = await getApplicationSupportDirectory();
      _tileProvider = StorageCachingTileProvider(
          parentDirectory: directory, storeName: widget.regionName);
    });

    _centerOnLocationUpdate = CenterOnLocationUpdate.first;
    _centerCurrentLocationStreamController = StreamController<double>();
    mapController = MapController();

    _mapEventListener = mapController!.mapEventStream.listen((event) {
      if (event is MapEventMove) {
        _drawDownloadArea();
      }
    });
  }

  _onDownloadFinish(context) {
    var nav = Navigator.of(context);
    nav.pop();
    nav.pop();
    widget.onPushRegion();
  }

  void _onStartDownload() {
    _downloadStreamController = new StreamController();
    final downloableRegionStream = _tileProvider.downloadRegion(
        _selectedBoundsSqrRegion!.toDownloadable(
            8,
            17,
            TileLayerOptions(
              tileProvider: _tileProvider,
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            )),
        preDownloadChecksCallback:
            (_connectivityResult, _number, _chargingStatus) async => true);
    _downloadStreamController!.addStream(downloableRegionStream);
  }

  void _onCancelDownload(context) {
    _downloadStreamController!.close();
    _onDownloadFinish(context);
  }

  _downloadRegionForeground() async {
    _onStartDownload();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
            title: Text('Downloading Area...'),
            content: StreamBuilder<DownloadProgress>(
              initialData: DownloadProgress.empty(),
              stream: _downloadStreamController!.stream.asBroadcastStream(),
              builder: (ctx, snapshot) {
                if (snapshot.hasError) {
                  return Text('error: ${snapshot.error.toString()}');
                }
                final progressPercentage =
                    snapshot.data?.percentageProgress ?? 0;
                return DownloadPopUp(
                    percentage: progressPercentage,
                    onCancel: _onCancelDownload,
                    onDownloadFinish: _onDownloadFinish);
              },
            ));
      },
    );
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
        await StorageCachingTileProvider.checkRegion(downloadableRegion);
    if (approximateTileCount >
        StorageCachingTileProvider.kMaxPreloadTileAreaCount) {
      _showErrorSnack('Selected area to large, please select an smaller area.');
      return;
    }
    _downloadRegionForeground();
  }

  @override
  void dispose() {
    super.dispose();
    _mapEventListener.cancel();
    _centerCurrentLocationStreamController.close();
    _downloadStreamController!.close();
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
      bottomSheet: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: 70,
          child: TextButton.icon(
              style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(
                      Size.fromWidth(MediaQuery.of(context).size.width))),
              onPressed: _onDownloadRegion,
              icon: Icon(Icons.download_for_offline),
              label: Text('Download Region'))),
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
