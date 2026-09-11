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

const readingCompanionContent = CompanionContent(
  id: 'open_book',
  version: 1,
  title: '책 한 쪽 펼치기',
  preparation: '읽고 싶었던 책 한 권을 가까이 두어요. 많이 읽을 계획은 세우지 않아도 돼요.',
  steps: [
    '책을 손 닿는 곳에 놓아볼까요?\n편하게 앉을 자리만 있으면 돼요.',
    '책갈피가 있는 곳이나 눈길이 가는 쪽을 펼쳐봐요.\n처음부터 읽지 않아도 괜찮아요.',
    '첫 문장 하나만 천천히 읽어봐요.\n뜻이 바로 와닿지 않아도 넘어가도 좋아요.',
    '조금 더 읽고 싶다면 다음 문장으로 이어가요.\n여기서 멈춘다면 읽던 곳을 표시해두어요.',
  ],
);

const firstMoveCompanionContent = CompanionContent(
  id: 'first_move',
  version: 1,
  title: '미룬 일 첫 동작 하기',
  preparation: '마음에 걸리는 일 하나를 떠올려봐요. 끝내기보다 손댈 수 있는 작은 부분을 찾아요.',
  steps: [
    '지금 손댈 일 하나만 골라봐요.\n메일 답장, 설거지, 공부처럼 평범한 일도 좋아요.',
    '시작에 필요한 것 하나를 준비해요.\n문서를 열거나, 그릇 하나를 싱크대에 놓는 정도면 돼요.',
    '가장 작은 동작 하나를 해볼까요?\n첫 단어를 쓰거나, 그릇 하나만 씻어봐요.',
    '이어갈 수 있다면 다음 동작 하나를 골라요.\n지금은 멈춰야 한다면 다시 시작할 자리에 그대로 두어요.',
  ],
);

const companionContents = [
  deskCompanionContent,
  readingCompanionContent,
  firstMoveCompanionContent,
];

/// Keep the original desk version, including legacy media fallback, resumable.
CompanionContent? companionContentFor(String id, int version) {
  for (final content in companionContents) {
    if (content.id == id &&
        (content.version == version ||
            (id == deskCompanionContent.id && version == 2))) {
      return content;
    }
  }
  return null;
}

String companionContentTitle(String id, int version) =>
    id == deskCompanionContent.id
    ? '책상 한 칸 비우기'
    : companionContentFor(id, version)?.title ?? '생활 안내';

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
