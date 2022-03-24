import 'package:objectbox/objectbox.dart';
import 'package:timer_f1/app/data/models/enums/timer_time_types.dart';
import 'package:timer_f1/app/data/models/servo.dart';

@Entity()
class Program {
  int id = 0;
  int time = 0;
  TimerTimeTypes timeMeasure = TimerTimeTypes.milliseconds;
  int rotation = 1;

  final servo = ToOne<Servo>();

  Program(
      {this.time = 0,
      this.timeMeasure = TimerTimeTypes.milliseconds,
      this.rotation = 1});

  Program.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    time = json['time'];
    timeMeasure = TimerTimeTypes.values[json['timeMeasure']];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['time'] = time;
    data['timeMeasure'] = timeMeasure.toString();
    return data;
  }
}
