import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timerf1c/offline_maps/download_map_region.dart';
import 'package:timerf1c/offline_maps/widgets/download_map_list.dart';
import 'get_downloaded_maps.dart';

class OfflineMapsPage extends StatefulWidget {
  OfflineMapsPage({Key? key}) : super(key: key);
  @override
  _OfflineMapsPageState createState() => _OfflineMapsPageState();
}

class _OfflineMapsPageState extends State<OfflineMapsPage> {
  void _onDeleteNewRegion(String regionName,
      Future<void> Function(String downloadedMapName) onDeleteRegion) {
    AwesomeDialog(
        context: context,
        keyboardAware: true,
        dialogType: DialogType.QUESTION,
        animType: AnimType.BOTTOMSLIDE,
        headerAnimationLoop: false,
        title: 'Delete ' + regionName,
        desc: 'Are you sure you want to remove this region from the cache?.',
        btnCancelOnPress: () {},
        btnOkOnPress: () async {
          await onDeleteRegion(regionName);
          setState(() {});
        }).show();
  }

  // Update list on push region
  void _onPushRegion() {
    setState(() {});
  }

  void _onAddNewRegion() {
    TextEditingController controller = new TextEditingController(text: '');
    AwesomeDialog(
        context: context,
        keyboardAware: true,
        dialogType: DialogType.QUESTION,
        animType: AnimType.BOTTOMSLIDE,
        headerAnimationLoop: false,
        title: 'Specify the region name',
        desc:
            'Specify which is the region name that you will download to be identified later.',
        btnCancelOnPress: () {},
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: <Widget>[
              Text(
                'Specify the region name',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(
                height: 10,
              ),
              Material(
                elevation: 0,
                color: Colors.blueGrey.withAlpha(40),
                child: TextFormField(
                  controller: controller,
                  autofocus: true,
                  minLines: 1,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.text_fields),
                  ),
                ),
              )
            ])),
        btnOkOnPress: () async {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: DownloadMapRegionPage(
                    onPushRegion: _onPushRegion,
                    regionName: controller.text,
                  )));
        }).show();
  }

  Future<void> _onDeleteRegion(String downloadedMapName) async {
    await TileStorageCachingManager.cleanCacheName(downloadedMapName);
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
                  onTap: _onAddNewRegion,
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
              downloadedMapsList((downloadedMapName) => InkWell(
                  onTap: () =>
                      _onDeleteNewRegion(downloadedMapName, _onDeleteRegion),
                  child: Icon(
                    Icons.delete_forever,
                    size: 30,
                  )))
            ],
          ),
        ));
  }
}
