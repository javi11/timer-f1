import 'package:flutter/material.dart';

class BluetoothScaffold extends StatelessWidget {
  final Widget child;
  final void Function() onGoBack;

  const BluetoothScaffold(
      {Key? key, required this.child, required this.onGoBack})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: child,
        ),
        SizedBox(
            height: 80,
            child: AppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.blue[100],
                  ),
                  onPressed: onGoBack,
                ),
                centerTitle: true,
                title: Text(
                  'Connecting...',
                  style: TextStyle(color: Colors.blue[100]),
                ),
                elevation: 0)),
      ],
    ));
  }
}
