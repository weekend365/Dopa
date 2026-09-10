import 'package:dopa_domain/dopa_domain.dart';

String companionOutcomeLabel(CompanionOutcome outcome) => switch (outcome) {
  CompanionOutcome.asPlanned => '하려던 만큼 했어요',
  CompanionOutcome.started => '조금 시작했어요',
  CompanionOutcome.difficult => '오늘은 어려웠어요',
};

String companionClosingCopy(CompanionOutcome outcome) => switch (outcome) {
  CompanionOutcome.asPlanned => '해낸 만큼 기록으로 남겼어요.\n이제 폰을 내려놓고 이어가도 좋아요.',
  CompanionOutcome.started => '작게 시작한 것도 기록으로 남겼어요.\n오늘은 여기까지 해도 괜찮아요.',
  CompanionOutcome.difficult => '오늘의 상태를 기록으로 남겼어요.\n오늘은 여기까지 해도 괜찮아요.',
};
