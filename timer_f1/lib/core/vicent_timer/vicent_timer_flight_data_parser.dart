import 'dart:async';
import 'package:timer_f1/app/data/models/flight_data_model.dart';

class VicentTimerFlightDataParser
    implements StreamTransformer<String, FlightData> {
  late StreamController<FlightData> _controller;
  StreamSubscription<String>? _subscription;
  final bool? cancelOnError;
  late Stream<String> _stream;
  String _acc = '';

  VicentTimerFlightDataParser({bool sync = true, this.cancelOnError}) {
    _controller = StreamController<FlightData>(
        onListen: _onListen,
        onCancel: _onCancel,
        onPause: () {
          _subscription?.pause();
        },
        onResume: () {
          _subscription?.resume();
        },
        sync: sync);
  }

  void _onListen() {
    _subscription = _stream.listen(onData,
        onError: _controller.addError,
        onDone: _controller.close,
        cancelOnError: cancelOnError);
  }

  void _onCancel() {
    _subscription?.cancel();
    _subscription = null;
  }

  void onData(String dataLines) {
    print('Timer GPS Data: $dataLines [${dataLines.length} bytes]');
    var gpsLine = dataLines.split(',');
    // Replace invalid character on plane name.
    gpsLine[0] = gpsLine[0].replaceFirst('>', '');
    // A gps line must have 15 elements split by comma.
    if (gpsLine.length == 15) {
      _controller.add(FlightData.parse(gpsLine));
    }
  }

  @override
  Stream<FlightData> bind(Stream<String> stream) {
    _stream = stream;
    return _controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    return StreamTransformer.castFrom(this);
  }
}
