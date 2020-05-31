import 'package:timmer/models/flight_data.dart';

class FlightHistory {
  List<FlightData> _data = [];
  int durationInMs = 0;
  int startTimestamp = 0;
  int endTimestamp = 0;
  String planeId = 'uknown';
  double maxPressure = 0;
  double maxHeight = 0;
  double maxTemperature = 0;

  void addData(FlightData timmerData) {
    this.planeId = timmerData.id;
    this._data.add(timmerData);
  }

  void start() {
    this.startTimestamp = DateTime.now().millisecondsSinceEpoch;
  }

  void end() {
    this.endTimestamp = DateTime.now().millisecondsSinceEpoch;
    this.durationInMs = this.endTimestamp - this.startTimestamp;
    this._data.forEach((element) {
      if (element.height > this.maxHeight) {
        this.maxHeight = element.height;
      }
      if (element.pressure > this.maxPressure) {
        this.maxPressure = element.pressure;
      }
      if (element.temperature > this.maxTemperature) {
        this.maxTemperature = element.temperature;
      }
    });
  }

  Map toMap() {
    Map map = {
      'durationInMs': durationInMs,
      'startTimestamp': startTimestamp,
      'endTimestamp': endTimestamp,
      'planeId': planeId,
      'maxPressure': maxPressure,
      'maxHeight': maxHeight,
      'maxTemperature': maxTemperature,
    };
    return map;
  }

  FlightHistory();

  FlightHistory.fromMap(Map map) {
    durationInMs = map['durationInMs'];
    startTimestamp = map['startTimestamp'];
    endTimestamp = map['endTimestamp'];
    planeId = map['planeId'];
    maxPressure = map['maxPressure'];
    maxHeight = map['maxHeight'];
    maxTemperature = map['maxTemperature'];
  }
}
