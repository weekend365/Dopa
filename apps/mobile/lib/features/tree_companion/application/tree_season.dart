import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TreeSeason { spring, summer, autumn, winter }

typedef TreeSeasonNow = DateTime Function();

final treeSeasonNowProvider = Provider<TreeSeasonNow>((ref) => DateTime.now);

final treeSeasonProvider = Provider<TreeSeason>(
  (ref) => treeSeasonForMonth(ref.watch(treeSeasonNowProvider)().month),
);

TreeSeason treeSeasonForMonth(int month) => switch (month) {
  >= 3 && <= 5 => TreeSeason.spring,
  >= 6 && <= 8 => TreeSeason.summer,
  >= 9 && <= 11 => TreeSeason.autumn,
  12 || 1 || 2 => TreeSeason.winter,
  _ => throw ArgumentError.value(month, 'month', 'Must be from 1 to 12.'),
};
