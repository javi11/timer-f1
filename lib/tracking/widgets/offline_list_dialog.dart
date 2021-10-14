import 'package:flutter/material.dart';
import 'package:timerf1c/offline_maps/widgets/download_map_list.dart';

Widget buildOfflineListDialogDialog(context, onTap) {
  return WillPopScope(
      onWillPop: () {
        Navigator.popUntil(context, (route) {
          return route.isFirst;
        });

        return Future.value(false);
      },
      child: SimpleDialog(
        title: Text("You seems offline, please use one of the saved regions."),
        contentPadding: EdgeInsets.all(25),
        children: [
          SizedBox(
            height: 20,
          ),
          Container(
              child: downloadedMapsList((downloadedMapName) => InkWell(
                  onTap: onTap(downloadedMapName),
                  child: Icon(
                    Icons.offline_pin,
                    size: 30,
                  )))),
          FlatButton(
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: () {
              Navigator.popUntil(context, (route) {
                return route.isFirst;
              });
            },
            child: Text(
              "I don't need a map.",
              style: TextStyle(fontSize: 20.0),
            ),
          )
        ],
      ));
}
