import 'package:timmer/models/timmer_data.dart';

class FlightHistory {
  List<TimmerData> history = [];
  int durationInMs = 0;
  int startTimestamp = 0;
  int endTimestamp = 0;
  String planeId = 'uknown';
  double maxPressure = 0;
  double maxHeight = 0;
  double maxTemperature = 0;

  void addData(TimmerData timmerData) {
    this.planeId = timmerData.id;
    this.history.add(timmerData);
  }

  void start() {
    this.startTimestamp = DateTime.now().millisecondsSinceEpoch;
  }

  void end() {
    this.endTimestamp = DateTime.now().millisecondsSinceEpoch;
    this.durationInMs = this.endTimestamp - this.startTimestamp;
    this.history.forEach((element) {
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
}
