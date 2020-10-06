import 'dart:async';

class TimmerDataTransformer<S, T> implements StreamTransformer<S, T> {
  final List<String> alive = ["HUM-900-PRO", "linx", "logies", "hts"];
  StreamController _controller = StreamController<T>();
  String _acc = '';

  @override
  Stream<T> bind(Stream<S> stream) {
    stream.listen((value) {
      String data = value as String;
      bool _test(String value) => data.contains(value);

      if (data.isNotEmpty && !alive.any(_test)) {
        _acc += data;
        // A valid line of data has 13 columns and more than 62 chars
        if (_acc.split(',').length == 13 && _acc.length >= 62) {
          _controller.add(_acc);
          _acc = '';
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
