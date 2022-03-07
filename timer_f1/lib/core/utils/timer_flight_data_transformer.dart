import 'dart:async';
import 'package:timer_f1/app/data/models/flight_data_model.dart';

class TimerFlightDataTransformer<S>
    implements StreamTransformer<S, FlightData> {
  final StreamController _controller = StreamController<FlightData>();
  String _acc = '';

  @override
  Stream<FlightData> bind(Stream<S> stream) {
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
            _controller.add(FlightData.parse(gpsLine));
            _acc = dataLines[1];
          } else {
            _acc = '';
          }
        }
      }
    });
    return _controller.stream as Stream<FlightData>;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    return StreamTransformer.castFrom(this);
  }
}
