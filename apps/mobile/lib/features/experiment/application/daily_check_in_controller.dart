import 'dart:async';

import 'package:dopa/core/persistence/dopa_database_providers.dart';
import 'package:dopa/features/focus/application/focus_session_controller.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyCheckInController extends StateNotifier<DailyCheckIn?> {
  DailyCheckInController(this._ref) : super(null) {
    unawaited(_loadToday());
  }

  final Ref _ref;

  Future<void> _loadToday() async {
    try {
      final today = LocalDate.fromLocal(_ref.read(localNowProvider)());
      final checkIn = await _ref
          .read(focusTreeRepositoryProvider)
          .readCheckIn(today);
      if (mounted) {
        state = checkIn;
      }
    } on Object {
      // Check-in is optional. Today can render without a stored answer.
    }
  }

  Future<void> record(IntentionAlignment alignment) async {
    final today = LocalDate.fromLocal(_ref.read(localNowProvider)());
    final checkIn = DailyCheckIn(
      localDate: today,
      intentionAlignment: alignment,
    );
    await _ref
        .read(focusTreeRepositoryProvider)
        .writeTransaction((transaction) => transaction.saveCheckIn(checkIn));
    if (mounted) {
      state = checkIn;
    }
  }
}

final dailyCheckInControllerProvider =
    StateNotifierProvider<DailyCheckInController, DailyCheckIn?>((ref) {
      return DailyCheckInController(ref);
    });

final todaysCheckInProvider = Provider<DailyCheckIn?>(
  (ref) => ref.watch(dailyCheckInControllerProvider),
);
