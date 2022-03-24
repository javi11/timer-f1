import 'package:objectbox/objectbox.dart';
import 'package:timer_f1/app/data/models/servo.dart';

@Entity()
class TimerConfiguration {
  int id = 0;
  bool ledOn = false;
  late String name;

  @Backlink('timerConfiguration')
  final servos = ToMany<Servo>();

  TimerConfiguration({required this.name, this.ledOn = false});

  TimerConfiguration.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ledOn = json['ledOn'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['ledOn'] = ledOn;
    data['name'] = name;
    return data;
  }
}
