import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timerf1c/home/widgets/clipped_parts.dart';
import 'package:timerf1c/home/widgets/drawer.dart';
import 'package:timerf1c/home/widgets/history.dart';
import 'package:timerf1c/providers/history_provider.dart';
import 'package:timerf1c/tracking/tracking_page.dart';
import 'package:timerf1c/widgets/app_title.dart';

class OfflineMapsPage extends StatefulWidget {
  OfflineMapsPage({Key key}) : super(key: key);
  @override
  _OfflineMapsPageState createState() => _OfflineMapsPageState();
}

class _OfflineMapsPageState extends State<OfflineMapsPage> {
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
                  onTap: () => null,
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
            ],
          ),
        ));
  }
}
