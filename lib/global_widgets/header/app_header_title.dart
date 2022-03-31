import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppHeaderTitle extends StatelessWidget {
  final Widget appLogo = SvgPicture.asset(
    'assets/images/logo.svg',
    semanticsLabel: 'Logo',
    width: 30,
    height: 30,
  );

  final String? subtitle;
  final String title;
  final Widget? logo;

  AppHeaderTitle({Key? key, required this.title, this.subtitle, this.logo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        logo != null ? logo! : appLogo,
        Container(
            padding: EdgeInsets.only(left: 10),
            child: Wrap(children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.indigo,
                      fontWeight: FontWeight.w400)),
              SizedBox(
                width: 10,
              ),
              subtitle != null
                  ? Text(subtitle!,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.indigo,
                          fontWeight: FontWeight.w200))
                  : SizedBox(
                      width: 0,
                    )
            ])),
      ],
    );
  }
}
