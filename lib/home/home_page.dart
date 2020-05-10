import 'package:flutter/material.dart';
import 'package:timmer/home/widgets/history.dart';
import 'package:timmer/tracking/tracking_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex;
  @override
  void initState() {
    super.initState();
    currentIndex = 0;
  }

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[200],
        title: Text('Timmer'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.green,
          icon: Icon(Icons.place),
          onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TrackingPage()),
              ),
          label: Text(
            'Start a flight',
            style: TextStyle(fontSize: 20),
          )),
    );
  }
}
