import 'package:dopa/core/persistence/dopa_database_providers.dart';
import 'package:dopa/features/focus/application/focus_session_controller.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyCheckInController extends StateNotifier<DailyCheckIn?> {
  DailyCheckInController(this._ref) : super(null) {
    initialized = _loadToday();
  }

  final Ref _ref;
  late final Future<void> initialized;
  int _epoch = 0;

  Future<void> _loadToday() async {
    final epoch = _epoch;
    try {
      final today = LocalDate.fromLocal(_ref.read(localNowProvider)());
      final checkIn = await _ref
          .read(focusTreeRepositoryProvider)
          .readCheckIn(today);
      if (mounted && epoch == _epoch) {
        state = checkIn;
      }
    } on Object {
      // Check-in is optional. Today can render without a stored answer.
    }
  }

  Future<void> record(IntentionAlignment alignment) async {
    await initialized;
    if (!mounted || state != null) {
      return;
    }
    final epoch = ++_epoch;
    final today = LocalDate.fromLocal(_ref.read(localNowProvider)());
    final checkIn = DailyCheckIn(
      localDate: today,
      intentionAlignment: alignment,
    );
    final persisted = await _ref
        .read(focusTreeRepositoryProvider)
        .writeTransaction((transaction) => transaction.saveCheckIn(checkIn));
    if (mounted && epoch == _epoch) {
      state = persisted;
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
