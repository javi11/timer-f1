import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppName extends StatelessWidget {
  final Widget logo = SvgPicture.asset(
    'assets/images/logo.svg',
    semanticsLabel: 'Logo',
    width: 30,
    height: 30,
  );

  AppName({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        logo,
        Container(
            padding: EdgeInsets.only(left: 10),
            child: Wrap(children: [
              Text('TIMER',
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.indigo,
                      fontWeight: FontWeight.w400)),
              SizedBox(
                width: 10,
              ),
              Text('F1',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.indigo,
                      fontWeight: FontWeight.w200))
            ])),
      ],
    );
  }
}
