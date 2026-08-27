import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FocusSetupState {
  const FocusSetupState({
    this.durationMinutes = 10,
    this.protectionMode = ProtectionMode.timerOnly,
    this.intention = '읽던 문서 한 단락 마치기',
  });

  final int durationMinutes;
  final ProtectionMode protectionMode;
  final String intention;

  FocusSetupState copyWith({
    int? durationMinutes,
    ProtectionMode? protectionMode,
    String? intention,
  }) => FocusSetupState(
    durationMinutes: durationMinutes ?? this.durationMinutes,
    protectionMode: protectionMode ?? this.protectionMode,
    intention: intention ?? this.intention,
  );
}

class FocusSetupController extends StateNotifier<FocusSetupState> {
  FocusSetupController() : super(const FocusSetupState());

  void restoreFromSession(FocusSession session) {
    state = FocusSetupState(
      durationMinutes: session.preset.minutes,
      protectionMode: session.protectionMode,
      intention: session.intention,
    );
  }

  void selectDuration(int minutes) {
    if (const [5, 10, 25, 50].contains(minutes)) {
      state = state.copyWith(durationMinutes: minutes);
    }
  }

  void selectProtectionMode(ProtectionMode mode) {
    state = state.copyWith(protectionMode: mode);
  }

  void updateIntention(String value) {
    final trimmed = value.trim();
    if (trimmed.length > FocusSession.maxIntentionLength) {
      state = state.copyWith(
        intention: trimmed.substring(0, FocusSession.maxIntentionLength),
      );
      return;
    }
    state = state.copyWith(intention: trimmed);
  }
}

final focusSetupControllerProvider =
    StateNotifierProvider<FocusSetupController, FocusSetupState>(
      (ref) => FocusSetupController(),
    );
