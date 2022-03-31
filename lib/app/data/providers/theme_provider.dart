import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/data/models/app_theme_state.dart';

// Theme
final appThemeStateNotifier = ChangeNotifierProvider((ref) => AppThemeState());
