import 'package:flutter/material.dart';
import 'package:today_i_lift/shared/widgets/rest_time_modal.dart';

class RestTimerService {
  Future<void> show(BuildContext context, int seconds) {
    return showRestTimerPopup(
      context,
      initialSeconds: seconds,
      onSkip: () {},
    );
  }
}
