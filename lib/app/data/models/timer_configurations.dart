import 'package:objectbox/objectbox.dart';
import 'package:timer_f1/app/data/models/pepe_timer_configuration.dart';

@Entity()
class TimerConfigurations {
  int id = 0;

  @Backlink('TimerConfigurations')
  final pepeTimerConfigurations = ToMany<PepeTimerConfiguration>();

  TimerConfigurations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    return data;
  }
}
