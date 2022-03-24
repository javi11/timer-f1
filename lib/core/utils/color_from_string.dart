import 'package:flutter/material.dart';

String stringToHex(String str) {
  var hash = 0;
  for (var i = 0; i < str.length; i++) {
    hash = str.codeUnitAt(i) + ((hash << 5) - hash);
  }
  var colour = '#';
  for (var i = 0; i < 3; i++) {
    var value = (hash >> (i * 8)) & 0xFF;
    var valueToString = ('00' + value.toRadixString(16).toUpperCase());
    colour += valueToString.substring(valueToString.length - 2);
  }
  return colour;
}

Color fromHex(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

Color generateUniqColor(String str) {
  return fromHex(stringToHex(str));
}
