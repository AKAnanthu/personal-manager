import 'package:flutter/foundation.dart';
import 'package:personal_life_manager/core/drive/drive_auth.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/storage/secure_store.dart';
import 'package:personal_life_manager/core/sync/sync_engine.dart';

/// Signing in with Google, signing out and leaving. Each user signs in
/// with their own Gmail; their records are kept in that account's Drive.
class AccountSession {
  AccountSession({
    required this._auth,
    required this._engine,
    required this._wipePhone,
    required this._secure,
  });

  final DriveAuth _auth;
  final SyncEngine _engine;

  /// Removes everything on this phone and returns to sign-in (DataEraser).
  final Future<void> Function() _wipePhone;
  final SecureStore _secure;

  ValueListenable<String?> get account => _auth.account;

  /// Asks the user to pick their Google account. Ok(null) when they backed
  /// out. Records already on this phone (from before sign-in existed) are
  /// queued for upload.
  Future<Result<String?>> signIn() async {
    final r = await _auth.connect();
    if (r case Ok(value: final String _)) {
      // The app password of earlier versions is no longer used.
      await _secure.deleteAll();
      await _engine.seedAll();
      await _engine.start();
    }
    return r;
  }

  /// Gets this account's records from Drive (and sends this phone's).
  Future<Result<SyncReport>> firstSync() => syncNow();

  /// "Sync now". When Google wants Drive allowed again (testing-mode
  /// sign-ins expire after 7 days, or it was never allowed), its screen is
  /// shown once and the sync retried.
  Future<Result<SyncReport>> syncNow() async {
    var r = await _engine.syncNow();
    if (r case Err(failure: DriveFailure(:final problem))
        when problem == DriveProblem.authExpired ||
            problem == DriveProblem.notAllowed) {
      try {
        (await _auth.client(prompt: true)).close();
        r = await _engine.syncNow();
      } on Exception {
        // Still not allowed: report the original problem.
      }
    }
    return r;
  }

  /// Changes not yet in Drive, after trying once more to save them.
  Future<int> unsavedChanges() async {
    await _engine.save();
    return _engine.status.value.pending;
  }

  /// Removes this phone's copy; everything in Drive stays for next time.
  Future<void> signOut() async {
    await _engine.stop();
    // Also disconnects the Google account (DataEraser.forgetDrive).
    await _wipePhone();
    await _engine.reset();
  }

  /// Deletes the records in Drive's hidden app folder, then this phone's.
  Future<Result<void>> deleteEverything() async {
    // Stopped first, so nothing is uploaded again meanwhile.
    await _engine.stop();
    final r = await _engine.deleteDriveData();
    if (r is Err<void>) {
      await _engine.start();
      return r;
    }
    await signOut();
    return const Ok(null);
  }
}
