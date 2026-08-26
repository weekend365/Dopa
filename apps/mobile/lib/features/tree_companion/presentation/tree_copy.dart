import 'package:dopa_domain/dopa_domain.dart';

extension TreeGrowthStageCopy on TreeGrowthStage {
  String get koreanLabel => switch (this) {
    TreeGrowthStage.seed => '씨앗',
    TreeGrowthStage.sprout => '새싹',
    TreeGrowthStage.sapling => '묘목',
    TreeGrowthStage.smallTree => '작은 나무',
    TreeGrowthStage.youngZelkova => '어린 느티나무',
    TreeGrowthStage.spreadingBranches => '가지를 펴는 나무',
    TreeGrowthStage.broadCanopy => '넓은 수관',
    TreeGrowthStage.mature => '성목',
  };
}

String treeStatusLabel(TreeProgress progress) =>
    '함께 자란 ${progress.totalGrowthDays}일, ${progress.stage.koreanLabel}';

String treeStatusTitle(TreeProgress progress) =>
    '함께 자란 ${progress.totalGrowthDays}일 · ${progress.stage.koreanLabel}';
