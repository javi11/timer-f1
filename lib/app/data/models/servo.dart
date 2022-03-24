import 'package:objectbox/objectbox.dart';
import 'package:timer_f1/app/data/models/program.dart';
import 'package:timer_f1/app/data/models/timer_configuration.dart';

@Entity()
class Servo {
  int id = 0;
  late String name;

  @Backlink('servo')
  final program = ToMany<Program>();

  final timerConfiguration = ToOne<TimerConfiguration>();

  Servo({required this.name});

  Servo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
