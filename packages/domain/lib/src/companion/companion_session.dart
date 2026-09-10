import '../shared/local_date.dart';

/// Bundled guide content. A text sample is not a produced audio/video session.
final class CompanionContent {
  const CompanionContent({
    required this.id,
    required this.version,
    required this.title,
    required this.preparation,
    required this.steps,
  });

  final String id;
  final int version;
  final String title;
  final String preparation;
  final List<String> steps;
}

const deskCompanionContent = CompanionContent(
  id: 'desk_space',
  version: 1,
  title: '책상에 시작할 자리 만들기',
  preparation: '책상 앞에 편하게 서거나 앉아주세요. 물건을 잠깐 모아둘 자리만 있으면 돼요.',
  steps: [
    '책상 위 컵 하나를 옆으로 옮겨볼까요?\n컵이 없다면 지금 눈에 들어오는 작은 물건 하나도 좋아요.',
    '손 닿는 곳의 종이만 한쪽에 모아봐요.\n지금 분류하거나 버릴 것을 정하지 않아도 괜찮아요.',
    '두 손을 펼칠 만큼의 자리를 비워볼까요?\n그 자리의 물건만 잠깐 옆으로 옮겨요.',
    '이제 하려던 일에 쓸 물건 하나를 그 자리에 놓아봐요.\n책 한 권이나 노트 하나면 충분해요.',
  ],
);

enum CompanionOutcome { asPlanned, started, difficult }

enum CompanionGuidanceMode { textSample, humanMedia, textFallback }

/// Device-local run state. Playback itself is transient and restores paused.
final class CompanionRun {
  CompanionRun({
    required this.id,
    required this.contentId,
    required this.contentVersion,
    required this.startedAtUtc,
    required this.startedLocalDate,
    required this.stepCount,
    this.stepIndex = 0,
    this.guideCompleted = false,
    this.awaitingOutcome = false,
    this.positionMs = 0,
    this.playbackRevision = 0,
    this.guidanceMode = CompanionGuidanceMode.textSample,
  }) {
    if (positionMs < 0 ||
        playbackRevision < 0 ||
        id.isEmpty ||
        contentId.isEmpty ||
        contentVersion < 1 ||
        !startedAtUtc.isUtc ||
        stepCount < 1 ||
        stepIndex < 0 ||
        stepIndex >= stepCount ||
        (guideCompleted && (!awaitingOutcome || stepIndex != stepCount - 1))) {
      throw ArgumentError('Invalid companion run.');
    }
  }

  final String id;
  final String contentId;
  final int contentVersion;
  final DateTime startedAtUtc;
  final LocalDate startedLocalDate;
  final int stepCount;
  final int stepIndex;
  final bool guideCompleted;
  final bool awaitingOutcome;
  final int positionMs;
  final int playbackRevision;
  final CompanionGuidanceMode guidanceMode;

  CompanionRun advanceGuide() {
    if (awaitingOutcome) return this;
    final last = stepIndex == stepCount - 1;
    return _copy(
      stepIndex: last ? stepIndex : stepIndex + 1,
      guideCompleted: last,
      awaitingOutcome: last,
    );
  }

  CompanionRun requestOutcome() => _copy(awaitingOutcome: true);

  CompanionRun withPlayback({
    required int positionMs,
    required int revision,
    required int stepIndex,
    required CompanionGuidanceMode mode,
    bool completed = false,
  }) => CompanionRun(
    id: id,
    contentId: contentId,
    contentVersion: contentVersion,
    startedAtUtc: startedAtUtc,
    startedLocalDate: startedLocalDate,
    stepCount: stepCount,
    stepIndex: stepIndex,
    positionMs: positionMs,
    playbackRevision: revision,
    guidanceMode: mode,
    guideCompleted: completed,
    awaitingOutcome: completed,
  );

  CompanionRun _copy({
    int? stepIndex,
    bool? guideCompleted,
    bool? awaitingOutcome,
  }) => CompanionRun(
    id: id,
    contentId: contentId,
    contentVersion: contentVersion,
    startedAtUtc: startedAtUtc,
    startedLocalDate: startedLocalDate,
    stepCount: stepCount,
    positionMs: positionMs,
    playbackRevision: playbackRevision,
    guidanceMode: guidanceMode,
    stepIndex: stepIndex ?? this.stepIndex,
    guideCompleted: guideCompleted ?? this.guideCompleted,
    awaitingOutcome: awaitingOutcome ?? this.awaitingOutcome,
  );
}

/// Explicit self-report, separate from guide progression and focus minutes.
final class CompanionOutcomeRecord {
  const CompanionOutcomeRecord({
    required this.run,
    required this.outcome,
    required this.confirmedAtUtc,
    required this.confirmedLocalDate,
  });

  final CompanionRun run;
  final CompanionOutcome outcome;
  final DateTime confirmedAtUtc;
  final LocalDate confirmedLocalDate;
}
