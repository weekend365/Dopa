import 'companion_session.dart';

abstract interface class CompanionMediaRepository {
  /// Older revisions and all writes after result confirmation are ignored.
  Future<CompanionRun> savePlayback({
    required String runId,
    required int positionMs,
    required int revision,
    required int stepIndex,
    required CompanionGuidanceMode mode,
    bool completed = false,
  });
}
