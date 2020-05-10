import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:timmer/models/timmer_data.dart';

class MapInfo extends StatelessWidget {
  final TimmerData timmerData;

  MapInfo({Key key, @required this.timmerData}) : super(key: key);

  Widget build(BuildContext context) {
    Widget _buildBox(String text, IconData icon, String data,
        {Color bgColor = const Color(0x33C8C8C8)}) {
      return Container(
        height: 120,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon),
              Text(text),
              Text(data),
            ]),
        decoration: new BoxDecoration(
          color: bgColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      );
    }

    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 300,
        constraints: BoxConstraints(),
        padding: EdgeInsets.all(10),
        child: ResponsiveGridList(
          desiredItemWidth: 120,
          minSpacing: 10,
          children: [
            timmerData.voltageAlert == true
                ? _buildBox('Voltage', Icons.battery_alert,
                    timmerData.voltage.toStringAsFixed(2) + ' V',
                    bgColor: const Color(0x8Cba122b))
                : _buildBox('Voltage', Icons.battery_full,
                    timmerData.voltage.toStringAsFixed(2) + ' V'),
            _buildBox('Temperature', Icons.ac_unit,
                timmerData.temperature.toStringAsFixed(2) + ' º'),
            _buildBox('Pressure', Icons.av_timer,
                timmerData.pressure.toStringAsFixed(2) + ' PA'),
            _buildBox(
                'Height',
                Icons.line_weight,
                timmerData.height > 1000
                    ? timmerData.height.toString() + ' Km'
                    : timmerData.height.toString() + ' m'),
          ],
        ));
  }
}
