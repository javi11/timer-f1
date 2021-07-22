import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget getLoadProgresWidget(BuildContext context, int tileIndex, int tileAmount,
    List<String> tilesErrored, double progress) {
  if (tileAmount == 0) {
    tileAmount = 1;
  }
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      SizedBox(
        width: 50,
        height: 50,
        child: Stack(
          children: <Widget>[
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                backgroundColor: Colors.grey,
                value: progress / 100,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                progress == 100.0
                    ? '100%'
                    : (progress.toStringAsFixed(1) + '%'),
                style: Theme.of(context).textTheme.subtitle1,
              ),
            )
          ],
        ),
      ),
      SizedBox(
        height: 8,
      ),
      Text(
        progress == 100.0
            ? 'Download Finished'
            : '${tilesErrored.length == 0 ? '' : ((tileIndex - tilesErrored.length).toString() + '/')}$tileIndex/$tileAmount\nPlease Wait',
        style: Theme.of(context).textTheme.subtitle2,
        textAlign: TextAlign.center,
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
