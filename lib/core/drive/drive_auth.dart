import 'dart:async';
import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:personal_life_manager/core/drive/drive_models.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The user's own Google account: how they sign in to the app, and where
/// their data is kept (Drive).
abstract interface class DriveAuth {
  /// The connected account's e-mail, or null when not connected.
  ValueListenable<String?> get account;

  /// Restores the remembered connection (no network, no UI).
  Future<void> load();

  /// Asks the user to pick an account and allow Drive access. Ok(null)
  /// when they backed out.
  Future<Result<String?>> connect();

  /// Revokes access and forgets the account. Local data is untouched.
  Future<void> disconnect();

  /// An HTTP client authorised for Drive. With [prompt] the user may be
  /// asked to allow access again. Throws [DriveException].
  Future<http.Client> client({bool prompt = false});

  /// The last token was rejected; the next [client] fetches a fresh one.
  Future<void> tokenRejected();
}

/// Google Sign-In with narrow scopes: `drive.file` (only files the app
/// created) and `drive.appdata` (its hidden app folder, used for sync).
/// The app never sees the rest of the user's Drive.
final class GoogleDriveAuth implements DriveAuth {
  GoogleDriveAuth({
    required this._serverClientId,
    required this._lock,
    SharedPreferencesAsync? prefs,
    GoogleSignIn? signIn,
  }) : _prefs = prefs ?? SharedPreferencesAsync(),
       _signIn = signIn ?? GoogleSignIn.instance;

  static const List<String> scopes = [
    drive.DriveApi.driveFileScope,
    drive.DriveApi.driveAppdataScope,
  ];
  static const _accountKey = 'drive.account';

  /// Web client ID from the Google Cloud project; Android needs it to
  /// sign in. Empty → taken from platform configuration, if any.
  final String _serverClientId;
  final AppLock _lock;
  final SharedPreferencesAsync _prefs;
  final GoogleSignIn _signIn;
  final _account = ValueNotifier<String?>(null);
  Future<void>? _init;
  String? _lastToken;

  @override
  ValueListenable<String?> get account => _account;

  Future<void> _ready() => _init ??= _signIn.initialize(
    serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
  );

  @override
  Future<void> load() async {
    _account.value = await _prefs.getString(_accountKey);
  }

  @override
  Future<Result<String?>> connect() => _lock.runExternal(() async {
    try {
      await _ready();
      final user = await _signIn.authenticate(scopeHint: scopes);
      await user.authorizationClient.authorizeScopes(scopes);
      // Google's consent screen lets the user untick Drive; without it
      // nothing can be saved, so that isn't a completed sign-in.
      if (await _signIn.authorizationClient.authorizationForScopes(scopes) ==
          null) {
        await _signIn.signOut();
        return const Err<String?>(DriveFailure(DriveProblem.notAllowed));
      }
      await _prefs.setString(_accountKey, user.email);
      _account.value = user.email;
      return Ok<String?>(user.email);
    } on GoogleSignInException catch (e) {
      return switch (e.code) {
        GoogleSignInExceptionCode.canceled ||
        GoogleSignInExceptionCode.interrupted ||
        GoogleSignInExceptionCode.uiUnavailable => const Ok<String?>(null),
        // Not shown to the user; helps when setting up the Cloud project.
        _ => Err<String?>(DriveFailure(DriveProblem.unknown, e.code.name)),
      };
    } on SocketException {
      return const Err<String?>(DriveFailure(DriveProblem.offline));
    } on Exception catch (e) {
      return Err<String?>(
        DriveFailure(DriveProblem.unknown, e.runtimeType.toString()),
      );
    }
  });

  @override
  Future<void> disconnect() async {
    try {
      await _ready();
      await _signIn.disconnect();
    } on Exception {
      // Offline or already revoked: forgetting locally is what matters.
    }
    await _prefs.remove(_accountKey);
    _lastToken = null;
    _account.value = null;
  }

  @override
  Future<http.Client> client({bool prompt = false}) async {
    if (_account.value == null) {
      throw const DriveException(DriveProblem.notConnected);
    }
    try {
      await _ready();
      final authz =
          await _signIn.authorizationClient.authorizationForScopes(scopes) ??
          (prompt
              ? await _lock.runExternal(
                  () => _signIn.authorizationClient.authorizeScopes(scopes),
                )
              : null);
      if (authz == null) throw const DriveException(DriveProblem.authExpired);
      _lastToken = authz.accessToken;
      return authz.authClient(scopes: scopes);
    } on GoogleSignInException catch (e) {
      throw DriveException(
        e.code == GoogleSignInExceptionCode.canceled
            ? DriveProblem.cancelled
            : DriveProblem.authExpired,
      );
    }
  }

  @override
  Future<void> tokenRejected() async {
    final t = _lastToken;
    _lastToken = null;
    if (t == null) return;
    try {
      await _signIn.authorizationClient.clearAuthorizationToken(accessToken: t);
    } on Exception {
      // Best effort.
    }
  }
}
