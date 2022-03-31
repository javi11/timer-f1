import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:timer_f1/global_widgets/buttons/accept_button.dart';

class EmptyHistory extends StatelessWidget {
  final Function onStartFlight;
  final Widget logo = SvgPicture.asset(
    'assets/images/logo.svg',
    semanticsLabel: 'Logo',
    width: 100,
    height: 100,
  );
  EmptyHistory({Key? key, required this.onStartFlight}) : super(key: key);

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
          child: AcceptButton(
              text: 'Start a flight',
              minimumSize: Size(
                MediaQuery.of(context).size.width - 150,
                60.0,
              ),
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
