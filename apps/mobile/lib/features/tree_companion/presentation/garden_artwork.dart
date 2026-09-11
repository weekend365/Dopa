import 'package:dopa_domain/dopa_domain.dart';
import 'package:flutter/material.dart';

/// Visual mapping deliberately leaves legacy tree IDs and growth records intact.
class GardenProgress {
  const GardenProgress(this.growth);
  final TreeProgress growth;
  int get stage => growth.stage.index;
  String get label => const [
    '씨앗을 품은 정원',
    '새싹이 고개를 내민 정원',
    '작은 잎이 자라는 정원',
    '초록이 늘어나는 정원',
    '가지가 뻗는 정원',
    '잎이 풍성한 정원',
    '꽃봉오리가 맺힌 정원',
    '작은 꽃이 피어난 정원',
  ][stage];
}

class GardenArtwork extends StatelessWidget {
  const GardenArtwork({this.progress, this.assetOverride, super.key});
  final TreeProgress? progress;
  final String? assetOverride;
  @override
  Widget build(BuildContext context) {
    final garden = GardenProgress(
      progress ?? const TreeGrowthPolicy().progressFor(0),
    );
    final theme = Theme.of(context).brightness == Brightness.dark
        ? 'dark'
        : 'light';
    return Semantics(
      image: true,
      label: garden.label,
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            assetOverride ?? 'assets/garden/${theme}_${garden.stage}.webp',
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stack) => ColoredBox(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Center(
                child: Icon(
                  Icons.spa_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
