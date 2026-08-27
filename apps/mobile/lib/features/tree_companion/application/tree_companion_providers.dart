import 'dart:async';

import 'package:dopa/core/persistence/dopa_database_providers.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final treeProgressControllerProvider =
    StateNotifierProvider<TreeProgressController, TreeProgress>((ref) {
      return TreeProgressController(
        repository: ref.watch(focusTreeRepositoryProvider),
      );
    });

/// Synchronous presentation boundary. It renders the seed immediately and is
/// refreshed from the local ledger as soon as Drift opens.
final treeProgressProvider = Provider<TreeProgress>(
  (ref) => ref.watch(treeProgressControllerProvider),
);

final experimentAttemptDaysControllerProvider =
    StateNotifierProvider<ExperimentAttemptDaysController, int>((ref) {
      return ExperimentAttemptDaysController(
        repository: ref.watch(focusTreeRepositoryProvider),
      );
    });
final experimentAttemptDaysProvider = Provider<int>(
  (ref) => ref.watch(experimentAttemptDaysControllerProvider),
);
final experimentLengthDaysProvider = Provider<int>(
  (ref) => SevenDayExperiment.lengthDays,
);
final weeklyGrowthDaysControllerProvider =
    StateNotifierProvider<WeeklyGrowthDaysController, int>((ref) {
      return WeeklyGrowthDaysController(
        repository: ref.watch(focusTreeRepositoryProvider),
      );
    });
final weeklyGrowthDaysProvider = Provider<int>(
  (ref) => ref.watch(weeklyGrowthDaysControllerProvider),
);

class TreeProgressController extends StateNotifier<TreeProgress> {
  TreeProgressController({required DriftFocusTreeRepository repository})
    : _repository = repository,
      super(const TreeGrowthPolicy().progressFor(0)) {
    unawaited(_initialise());
  }

  final DriftFocusTreeRepository _repository;

  Future<void> _initialise() async {
    try {
      final progress = await _repository.readTreeProgress();
      if (mounted) {
        state = progress;
      }
    } on Object {
      // Keep the seed fallback visible. Persistence failures are handled by the
      // app's operational diagnostics without sending tree data.
    }
  }

  Future<void> refresh() async {
    final progress = await _repository.readTreeProgress();
    if (mounted) {
      state = progress;
    }
  }

  void applyCompletion(CompleteFocusSessionResult result) {
    final progress = result.progress;
    if (progress != null && mounted) {
      state = progress;
    }
  }
}

class ExperimentAttemptDaysController extends StateNotifier<int> {
  ExperimentAttemptDaysController({
    required DriftFocusTreeRepository repository,
  }) : _repository = repository,
       super(0) {
    unawaited(_initialise());
  }

  final DriftFocusTreeRepository _repository;

  Future<void> _initialise() async {
    try {
      await EnsureSevenDayExperiment(repository: _repository)
          .fromExistingTree();
      await refresh();
    } on Object {
      // Keep zero until an explicit refresh after a session attempt.
    }
  }

  Future<void> refresh() async {
    final count = await _repository.countExperimentAttemptDays();
    if (mounted) {
      state = count;
    }
  }
}

class WeeklyGrowthDaysController extends StateNotifier<int> {
  WeeklyGrowthDaysController({required DriftFocusTreeRepository repository})
    : _repository = repository,
      super(0) {
    unawaited(_initialise());
  }

  final DriftFocusTreeRepository _repository;

  Future<void> _initialise() async {
    try {
      await refresh();
    } on Object {
      // The report can safely render zero until a later explicit refresh.
    }
  }

  Future<void> refresh() async {
    final now = DateTime.now();
    final today = LocalDate.fromLocal(now);
    final start = today.addDays(-(now.weekday - DateTime.monday));
    final count = await _repository.countGrowthDaysInRange(
      startInclusive: start,
      endExclusive: start.addDays(7),
    );
    if (mounted) {
      state = count;
    }
  }
}

enum TreeCompletionKind {
  milestone,
  growthPulse,
  postMatureRing,
  alreadyCredited,
}

class TreeCompletionViewData {
  const TreeCompletionViewData({required this.kind, required this.progress});

  final TreeCompletionKind kind;
  final TreeProgress progress;

  factory TreeCompletionViewData.forRoute(String routeValue) {
    const policy = TreeGrowthPolicy();
    return switch (routeValue) {
      'pulse' || 'growthPulse' => TreeCompletionViewData(
        kind: TreeCompletionKind.growthPulse,
        progress: policy.progressFor(8),
      ),
      'duplicate' || 'alreadyCredited' => TreeCompletionViewData(
        kind: TreeCompletionKind.alreadyCredited,
        progress: policy.progressFor(8),
      ),
      'ring' || 'postMatureRing' => TreeCompletionViewData(
        kind: TreeCompletionKind.postMatureRing,
        progress: policy.progressFor(120),
      ),
      _ => TreeCompletionViewData(
        kind: TreeCompletionKind.milestone,
        progress: policy.progressFor(1),
      ),
    };
  }

  /// Converts the transactional domain result into one of the visual states.
  /// Ineligible sessions return `null` because they must not show tree growth.
  static TreeCompletionViewData? fromCompletionResult(
    CompleteFocusSessionResult result,
  ) {
    final progress = result.progress;
    if (result.awardStatus == GrowthAwardStatus.ineligibleSession ||
        progress == null) {
      return null;
    }
    if (result.awardStatus != GrowthAwardStatus.awarded) {
      return TreeCompletionViewData(
        kind: TreeCompletionKind.alreadyCredited,
        progress: progress,
      );
    }

    const policy = TreeGrowthPolicy();
    if (policy.isPostMatureRingMilestone(progress.totalGrowthDays)) {
      return TreeCompletionViewData(
        kind: TreeCompletionKind.postMatureRing,
        progress: progress,
      );
    }
    return TreeCompletionViewData(
      kind: policy.isRevealMilestone(progress.totalGrowthDays)
          ? TreeCompletionKind.milestone
          : TreeCompletionKind.growthPulse,
      progress: progress,
    );
  }
}
