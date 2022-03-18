import 'package:flutter/material.dart';

Widget getDayAvatar(int day) {
  switch (day) {
    case 1:
      return CircleAvatar(
        backgroundColor: Colors.blue[400],
        child: Text(
          'Mon',
          style: TextStyle(color: Colors.white),
        ),
      );
    case 2:
      return CircleAvatar(
        backgroundColor: Colors.red[400],
        child: Text(
          'Tu',
          style: TextStyle(color: Colors.white),
        ),
      );
    case 3:
      return CircleAvatar(
        backgroundColor: Colors.yellow[400],
        child: Text(
          'Wed',
          style: TextStyle(color: Colors.white),
        ),
      );
    case 4:
      return CircleAvatar(
        backgroundColor: Colors.green[400],
        child: Text(
          'Th',
          style: TextStyle(color: Colors.white),
        ),
      );
    case 5:
      return CircleAvatar(
        backgroundColor: Colors.orange[400],
        child: Text(
          'Fri',
          style: TextStyle(color: Colors.white),
        ),
      );
    case 6:
      return CircleAvatar(
        backgroundColor: Colors.teal[400],
        child: Text(
          'Sat',
          style: TextStyle(color: Colors.white),
        ),
      );
    case 7:
      return CircleAvatar(
        backgroundColor: Colors.pink[400],
        child: Text(
          'Sun',
          style: TextStyle(color: Colors.white),
        ),
      );
    default:
      return CircleAvatar(backgroundColor: Colors.lime[400]);
  }
}
