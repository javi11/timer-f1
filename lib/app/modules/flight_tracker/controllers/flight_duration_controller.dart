import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FlightDurationNotifier extends StateNotifier<TimerModel> {
  FlightDurationNotifier() : super(_initialState);

  static final _initialState = TimerModel(
    _durationString(0),
    false,
  );

  int _duration = 0;
  Timer? _tickerSubscription;

  static String _durationString(int duration) {
    final minutes = ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final seconds = (duration % 60).floor().toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void start() {
    _tickerSubscription?.cancel();

    _tickerSubscription = Timer.periodic(Duration(seconds: 1), (_) {
      _duration++;
      state = TimerModel(_durationString(_duration), true);
    });

    state = TimerModel(_durationString(_duration), true);
  }

  void reset() {
    _tickerSubscription?.cancel();
    _duration = 0;
    state = _initialState;
  }

  @override
  void dispose() {
    _tickerSubscription?.cancel();
    _duration = 0;
    super.dispose();
  }
}

class TimerModel {
  const TimerModel(this.duration, this.isRunning);
  final String duration;
  final bool isRunning;
}

final flightDurationProvider =
    StateNotifierProvider<FlightDurationNotifier, TimerModel>(
  (ref) => FlightDurationNotifier(),
);
