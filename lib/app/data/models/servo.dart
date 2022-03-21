import 'package:objectbox/objectbox.dart';
import 'package:timer_f1/app/data/models/program.dart';

@Entity()
class Servo {
  int id = 0;
  late String name;

  @Backlink('TimerConfigurations')
  final program = ToMany<Program>();

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
