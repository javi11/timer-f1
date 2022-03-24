import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EmptyList extends StatelessWidget {
  final Function onStartFlight;
  final Widget logo = SvgPicture.asset(
    'assets/images/logo.svg',
    semanticsLabel: 'Logo',
    width: 100,
    height: 100,
  );
  EmptyList({Key? key, required this.onStartFlight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Wrap(children: <Widget>[
      Center(
          child: Text(
        'No Flights Done Yet',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black54),
      )),
      SizedBox(
        height: 70,
      ),
      Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 100,
          child: Text(
              'Start tracking your first flight and filling your history.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black38)),
        ),
      ),
      SizedBox(
        height: 70,
      ),
      Center(
          child: TextButton(
              child: Text(
                'Start a flight',
                style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 18,
                    fontWeight: FontWeight.w400),
              ),
              style: TextButton.styleFrom(
                  minimumSize: Size(
                    MediaQuery.of(context).size.width - 150,
                    60.0,
                  ),
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      side: BorderSide(color: Colors.indigo, width: 1.5)),
                  elevation: 0),
              onPressed: () => onStartFlight())),
      SizedBox(
        height: 80,
      ),
      Center(
          child: Image.asset(
        'assets/images/empty_home.png',
        width: 200,
      ))
    ]));
  }
}
