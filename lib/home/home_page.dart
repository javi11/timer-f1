import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timmer/home/widgets/clipped_parts.dart';
import 'package:timmer/home/widgets/drawer.dart';
import 'package:timmer/home/widgets/history.dart';
import 'package:timmer/providers/history_provider.dart';
import 'package:timmer/tracking/tracking_page.dart';
import 'package:timmer/widgets/app_title.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<InOutAnimationState> _fabAnimationController =
      GlobalKey<InOutAnimationState>();
  int currentPage = 0;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        final UserScrollNotification userScroll = notification;
        switch (userScroll.direction) {
          case ScrollDirection.forward:
            if (userScroll.metrics.maxScrollExtent !=
                userScroll.metrics.minScrollExtent) {
              _fabAnimationController.currentState.animateIn();
            }
            break;
          case ScrollDirection.reverse:
            if (userScroll.metrics.maxScrollExtent !=
                userScroll.metrics.minScrollExtent) {
              _fabAnimationController.currentState.animateOut();
            }
            // Load more on go to the end of the list
            if (userScroll.metrics.pixels ==
                userScroll.metrics.maxScrollExtent) {
              setState(() {
                currentPage += 1;
              });
              Provider.of<HistoryProvider>(context, listen: false)
                  .loadHistoryItems(currentPage);
            }
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }

  void _onStartFlight() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.downToUp, child: TrackingPage()));
  }

  @override
  void dispose() {
    super.dispose();
    _fabAnimationController.currentState.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Do not allow rotate the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
        drawer: buildDrawer(context),
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue[400],
          elevation: 0,
          centerTitle: true,
          title: appTitle(),
        ),
        body: ClippedPartsWidget(
          top: Container(
            width: MediaQuery.of(context).size.width,
            height: 150,
            color: Colors.blue[400],
          ),
          bottom: Stack(children: <Widget>[
            Container(
              height: 190,
              color: Colors.blue[100],
            ),
            Container(
                child: History(
                    onStartFlight: _onStartFlight,
                    handleScrollNotification: _handleScrollNotification))
          ]),
          splitFunction: (Size size, double x) {
            // normalizing x to make it exactly one wave
            final normalizedX = x / size.width * 3 * pi;
            final waveHeight = size.height / 40;
            final y = size.height / 14 - sin(cos(normalizedX)) * waveHeight;

            return y;
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: InOutAnimation(
            inDefinition: SlideInUpAnimation(
                preferences: AnimationPreferences(
                    duration: Duration(milliseconds: 500))),
            outDefinition: SlideOutDownAnimation(
                preferences: AnimationPreferences(
                    duration: Duration(milliseconds: 500))),
            key: _fabAnimationController,
            child: Consumer<HistoryProvider>(
                builder: (context, historyProvider, child) {
              return Visibility(
                visible: historyProvider.isLoading == false &&
                    historyProvider.total > 0,
                child: FloatingActionButton.extended(
                    backgroundColor: Colors.green,
                    icon: Icon(Icons.flight_takeoff),
                    onPressed: _onStartFlight,
                    label: AutoSizeText(
                      'Start a flight',
                      maxFontSize: 30,
                      style: TextStyle(fontSize: 20),
                    )),
              );
            })));
  }
}
