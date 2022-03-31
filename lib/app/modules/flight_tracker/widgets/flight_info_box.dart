import 'package:flutter/material.dart';

class FlightInfoBox extends StatelessWidget {
  final String data;
  final String type;
  final Widget icon;

  const FlightInfoBox(
      {Key? key, required this.data, required this.type, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        horizontalTitleGap: 8,
        contentPadding: EdgeInsets.all(10),
        minLeadingWidth: 10,
        title: Text(
          data,
          style: TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          type,
          style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
              fontWeight: FontWeight.w400),
        ),
        leading: icon);
  }
}
