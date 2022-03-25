import 'dart:ui';
import 'package:flutter/material.dart';

class HistoryDetailGlassBox extends StatelessWidget {
  final String text;
  late final String value;
  late final String unit;

  HistoryDetailGlassBox({Key? key, required this.text, required data}) {
    var dataSplited = data.split(' ');
    value = dataSplited[0];
    unit = dataSplited[1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 110,
        width: 100,
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Card(
            color: Colors.grey.shade500.withOpacity(0.5),
            elevation: 0,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          text,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w300),
                        ),
                        Text(
                          value,
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          unit,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w300),
                        ),
                      ]),
                ))));
  }
}
