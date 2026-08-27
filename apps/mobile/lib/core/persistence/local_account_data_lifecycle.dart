import 'package:dopa_domain/dopa_domain.dart';
import 'package:dopa_local_storage/dopa_local_storage.dart';

/// Explicit boundary between account/consent flows and device-local data.
///
/// [AuthController] calls [initializeAfterLoginAndConsent] only after login
/// and consent succeed. Logout and account deletion must call
/// [deleteForLogoutOrAccountDeletion] before disposing the account scope.
final class LocalAccountDataLifecycle {
  const LocalAccountDataLifecycle({
    required DriftFocusTreeRepository repository,
  }) : _repository = repository;

  final DriftFocusTreeRepository _repository;

  Future<TreeProgress> initializeAfterLoginAndConsent({
    required DateTime createdAtUtc,
  }) async {
    await EnsureTreeCompanion(repository: _repository)(
      createdAtUtc: createdAtUtc,
    );
    return _repository.readTreeProgress();
  }

  Future<void> deleteForLogoutOrAccountDeletion() =>
      _repository.deleteAllLocalData();
}
