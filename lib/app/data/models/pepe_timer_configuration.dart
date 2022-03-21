import 'package:objectbox/objectbox.dart';
import 'package:timer_f1/app/data/models/servo.dart';

@Entity()
class PepeTimerConfiguration {
  int id = 0;
  bool ledOn = false;
  late String name;

  @Backlink('TimerConfigurations')
  final servos = ToMany<Servo>();

  PepeTimerConfiguration({required this.name, this.ledOn = false});

  PepeTimerConfiguration.fromJson(Map<String, dynamic> json) {
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
