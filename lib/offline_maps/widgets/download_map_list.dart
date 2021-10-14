import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../get_downloaded_maps.dart';

Widget downloadedMapsList(Widget Function(String downloadedMapName) trailing) {
  return FutureBuilder(
      future: getDownloadedMaps(),
      builder: (context, AsyncSnapshot<List<String>> downloadedMapsSnap) {
        if (downloadedMapsSnap.hasData) {
          return Expanded(
              child: ListView.builder(
            itemCount: downloadedMapsSnap.data!.length,
            itemBuilder: (context, index) {
              String downloadedMapName = downloadedMapsSnap.data![index];
              return ListTile(
                trailing: trailing(downloadedMapName),
                title: Text(downloadedMapName,
                    style: TextStyle(color: Colors.black54)),
              );
            },
          ));
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
