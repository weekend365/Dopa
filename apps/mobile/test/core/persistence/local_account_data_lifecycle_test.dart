import 'package:dopa/core/persistence/local_account_data_lifecycle.dart';
import 'package:dopa_domain/dopa_domain.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'consent initialization creates one seed and account deletion clears it',
    () async {
      final database = DopaDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final lifecycle = LocalAccountDataLifecycle(
        repository: DriftFocusTreeRepository(
          database: database,
          treeIdFactory: () => 'tree-after-consent',
        ),
      );

      final progress = await lifecycle.initializeAfterLoginAndConsent(
        createdAtUtc: DateTime.utc(2026, 8, 27),
      );

      expect(progress, const TreeGrowthPolicy().progressFor(0));
      expect(
        await database.select(database.treeCompanions).get(),
        hasLength(1),
      );

      await lifecycle.deleteForLogoutOrAccountDeletion();

      expect(await database.select(database.treeCompanions).get(), isEmpty);
      expect(await database.select(database.treeGrowthCredits).get(), isEmpty);
      expect(await database.select(database.focusSessions).get(), isEmpty);
    },
  );
}
