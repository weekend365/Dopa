import 'dart:async';

import 'package:dopa/core/persistence/local_account_data_lifecycle.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The sole device-local database used by focus sessions and tree growth.
///
/// It is lazy: screens that do not use persistence do not open the database.
final dopaDatabaseProvider = Provider<DopaDatabase>((ref) {
  final database = DopaDatabase(driftDatabase(name: 'dopa_device_local'));
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

final focusTreeRepositoryProvider = Provider<DriftFocusTreeRepository>(
  (ref) => DriftFocusTreeRepository(database: ref.watch(dopaDatabaseProvider)),
);

/// Consumed by the existing login/consent and account-deletion orchestration.
/// Keeping this lifecycle explicit prevents tree data from escaping the
/// device-local account scope.
final localAccountDataLifecycleProvider = Provider<LocalAccountDataLifecycle>(
  (ref) => LocalAccountDataLifecycle(
    repository: ref.watch(focusTreeRepositoryProvider),
  ),
);
