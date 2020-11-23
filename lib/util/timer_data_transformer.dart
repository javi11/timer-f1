import 'dart:async';

class TimerDataTransformer<S, T> implements StreamTransformer<S, T> {
  StreamController _controller = StreamController<T>();
  String _acc = '';

  @override
  Stream<T> bind(Stream<S> stream) {
    stream.listen((value) {
      String data = value as String;

      if (data.isNotEmpty) {
        _acc += data;
        // Split the data in lines
        if (data.contains('\n')) {
          var dataLines = _acc.split('\n');
          var gpsLine = dataLines[0].replaceAll('\n', '').split(',');
          // A gps line must have 15 elements splited by comma
          if (gpsLine.length == 15) {
            _controller.add(gpsLine);
            _acc = dataLines[1];
          } else {
            _acc = '';
          }
        }
      }
    });
    return _controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    return StreamTransformer.castFrom(this);
  }
}
