import 'package:flutter/material.dart';

class HistoryDetailInfoBox extends StatelessWidget {
  final String text;
  late final String value;
  late final String unit;

  HistoryDetailInfoBox({Key? key, required this.text, required data}) {
    var dataSplited = data.split(' ');
    value = dataSplited[0];
    unit = dataSplited[1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 2),
        height: 80,
        width: 65,
        child: Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.grey.shade700, fontWeight: FontWeight.w300),
                ),
                Text(
                  value,
                  style: TextStyle(
                      fontSize: 23,
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  unit,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.grey.shade700, fontWeight: FontWeight.w300),
                ),
              ]),
        ));
  }
}
