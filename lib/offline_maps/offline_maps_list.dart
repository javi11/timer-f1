import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timerf1c/offline_maps/download_map_region.dart';

class OfflineMapsPage extends StatefulWidget {
  OfflineMapsPage({Key? key}) : super(key: key);
  @override
  _OfflineMapsPageState createState() => _OfflineMapsPageState();
}

class _OfflineMapsPageState extends State<OfflineMapsPage> {
  Future<List<String>> _getDownloadedMaps() async {
    final List<String> cacheNames = [];
    for (String cacheName in await TileStorageCachingManager.allCacheNames) {
      cacheNames.add(cacheName);
    }

    return cacheNames;
  }

  Widget downloadedMapsList() {
    return FutureBuilder(
        future: _getDownloadedMaps(),
        builder: (context, AsyncSnapshot<List<String>> downloadedMapsSnap) {
          if (downloadedMapsSnap.hasData) {
            return ListView.builder(
              itemCount: downloadedMapsSnap.data!.length,
              itemBuilder: (context, index) {
                String downloadedMapName = downloadedMapsSnap.data![index];
                return ListTile(
                  title: Text(downloadedMapName,
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                );
              },
            );
          } else if (downloadedMapsSnap.hasError) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Error: ${downloadedMapsSnap.error}'),
            );
          }

          return SizedBox(
            child: CircularProgressIndicator(),
            width: 60,
            height: 60,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // Do not allow rotate the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue[400],
          centerTitle: true,
          title: Text('Offline maps'),
          automaticallyImplyLeading: true,
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Material(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: DownloadMapRegionPage())),
                  child: ListTile(
                    contentPadding: EdgeInsets.only(
                        top: 10, bottom: 10, right: 20, left: 20),
                    leading: Icon(Icons.file_download, color: Colors.blue),
                    title: Text('SELECT MAP REGION'),
                  ),
                ),
              ),
              Divider(
                color: Colors.black26,
                height: 5,
              ),
              ListTile(
                title: Text('Downloaded maps',
                    style: TextStyle(fontSize: 15, color: Colors.black54)),
              ),
              Expanded(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: downloadedMapsList()))
            ],
          ),
        ));
  }
}
