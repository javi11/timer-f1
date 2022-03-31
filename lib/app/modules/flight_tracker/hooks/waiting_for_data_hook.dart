import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timer_f1/app/modules/flight_tracker/controllers/flight_data_controller.dart';
import 'package:timer_f1/app/modules/flight_tracker/widgets/waiting_for_timer_data.dart';

void useWaitingForData({required WidgetRef ref}) {
  final isMounted = useIsMounted();

  return use(NoDataPopupHook(ref, isMounted));
}

class NoDataPopupHook extends Hook<void> {
  final bool Function() isMounted;
  final WidgetRef ref;
  const NoDataPopupHook(this.ref, this.isMounted);

  @override
  HookState<void, NoDataPopupHook> createState() {
    return _NoDataPopupHookState();
  }
}

class _NoDataPopupHookState extends HookState<void, NoDataPopupHook> {
  ProviderSubscription<bool>? listener;
  bool isNoDataDialogDisplayed = false;

  @override
  void dispose() {
    listener?.close();
    super.dispose();
  }

  @override
  build(BuildContext context) {
    final flightHasStarted = hook.ref
        .watch(flightProvider.select((value) => value.startTimestamp != null));
    if (flightHasStarted == false && isNoDataDialogDisplayed == false) {
      setState(() {
        isNoDataDialogDisplayed = true;
      });
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        await showDialog(
            context: context,
            builder: (ctx) => WaitingForData(hasFlightStarted: false),
            barrierDismissible: false);
      });
    } else if (flightHasStarted == true && isNoDataDialogDisplayed == true) {
      if (hook.isMounted()) {
        setState(() {
          isNoDataDialogDisplayed = false;
        });
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.of(context, rootNavigator: true).pop();
        });
      }
    }
  }
}
