import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

Widget getLoadProgresWidget(
    BuildContext context,
    int tileIndex,
    int tileAmount,
    List<String> tilesErrored,
    double progress,
    void Function() onDownloadFinish,
    AnimationController? _downloadController) {
  if (tileAmount == 0) {
    tileAmount = 1;
  }
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Lottie.asset("assets/animations/downloading.json",
          animate: false,
          controller: _downloadController, onLoaded: (composition) {
        _downloadController!
          ..duration = composition.duration
          ..stop();
      }),
      TextButton(
        child: progress == 100.0 ? Text('OK') : Text('Cancel'),
        onPressed: () {
          var nav = Navigator.of(context);
          nav.pop();
          nav.pop();
          onDownloadFinish();
        },
      ),
      Visibility(
        visible: tilesErrored.length != 0,
        child: Expanded(
          child: Column(
            children: [
              SizedBox(height: 10),
              Text(
                'Errored Tiles: ${tilesErrored.length}',
                style: Theme.of(context).textTheme.subtitle2!.merge(TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    )),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Expanded(
                child: Container(
                  width: double.maxFinite,
                  child: ListView.builder(
                    reverse: true,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      String test = '';
                      try {
                        test = tilesErrored.reversed.toList()[index];
                      } catch (e) {} finally {
                        // ignore: control_flow_in_finally
                        return Column(
                          children: [
                            Text(
                              test
                                  .replaceAll('https://', '')
                                  .replaceAll('http://', '')
                                  .split('/')[0],
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .merge(TextStyle(color: Colors.red)),
                              textAlign: TextAlign.start,
                            ),
                            Text(
                              test
                                  .replaceAll(
                                      test
                                          .replaceAll('https://', '')
                                          .replaceAll('http://', '')
                                          .split('/')[0],
                                      '')
                                  .replaceAll('https:///', '')
                                  .replaceAll('http:///', ''),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2!
                                  .merge(TextStyle(color: Colors.red)),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
