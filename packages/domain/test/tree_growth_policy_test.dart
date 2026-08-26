import 'package:dopa_domain/dopa_domain.dart';
import 'package:test/test.dart';

void main() {
  const policy = TreeGrowthPolicy();

  group('TreeGrowthPolicy', () {
    test('derives every stage at and around its boundary', () {
      final cases = <(int, TreeGrowthStage, int?)>[
        (0, TreeGrowthStage.seed, 1),
        (1, TreeGrowthStage.sprout, 3),
        (2, TreeGrowthStage.sprout, 3),
        (3, TreeGrowthStage.sapling, 7),
        (6, TreeGrowthStage.sapling, 7),
        (7, TreeGrowthStage.smallTree, 14),
        (13, TreeGrowthStage.smallTree, 14),
        (14, TreeGrowthStage.youngZelkova, 30),
        (29, TreeGrowthStage.youngZelkova, 30),
        (30, TreeGrowthStage.spreadingBranches, 60),
        (59, TreeGrowthStage.spreadingBranches, 60),
        (60, TreeGrowthStage.broadCanopy, 90),
        (89, TreeGrowthStage.broadCanopy, 90),
        (90, TreeGrowthStage.mature, null),
        (120, TreeGrowthStage.mature, null),
      ];

      for (final (days, expectedStage, expectedNext) in cases) {
        final progress = policy.progressFor(days);
        expect(progress.stage, expectedStage, reason: '$days days');
        expect(progress.nextThreshold, expectedNext, reason: '$days days');
      }
    });

    test('counts one new post-mature ring for each additional 30 days', () {
      expect(policy.progressFor(90).postMatureRingCount, 0);
      expect(policy.progressFor(119).postMatureRingCount, 0);
      expect(policy.progressFor(120).postMatureRingCount, 1);
      expect(policy.progressFor(149).postMatureRingCount, 1);
      expect(policy.progressFor(150).postMatureRingCount, 2);
      expect(policy.progressFor(365).postMatureRingCount, 9);
    });

    test('identifies reveal and post-mature ring animation days', () {
      for (final day in TreeGrowthPolicy.revealMilestones) {
        expect(policy.isRevealMilestone(day), isTrue, reason: '$day days');
      }
      expect(policy.isRevealMilestone(2), isFalse);
      expect(policy.isRevealMilestone(120), isFalse);
      expect(policy.isPostMatureRingMilestone(90), isFalse);
      expect(policy.isPostMatureRingMilestone(119), isFalse);
      expect(policy.isPostMatureRingMilestone(120), isTrue);
      expect(policy.isPostMatureRingMilestone(150), isTrue);
    });

    test('rejects negative totals', () {
      expect(() => policy.stageFor(-1), throwsArgumentError);
      expect(() => policy.progressFor(-1), throwsArgumentError);
      expect(() => policy.isRevealMilestone(-1), throwsArgumentError);
      expect(() => policy.isPostMatureRingMilestone(-1), throwsArgumentError);
    });

    test('rejects unsupported rule versions at runtime', () {
      const unsupported = TreeGrowthPolicy(ruleVersion: 2);

      expect(() => unsupported.progressFor(0), throwsUnsupportedError);
    });
  });
}
