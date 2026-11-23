import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/core/drive/drive_auth.dart';
import 'package:personal_life_manager/core/drive/drive_models.dart';
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/security/app_lock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _SignIn extends Mock implements GoogleSignIn;

class _Account extends Mock implements GoogleSignInAccount;

class _Authz extends Mock implements GoogleSignInAuthorizationClient;

void main() {
  late _SignIn signIn;
  late _Authz authz;
  late AppLock lock;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    signIn = _SignIn();
    authz = _Authz();
    lock = AppLock(initialStatus: LockStatus.unlocked);
    addTearDown(lock.dispose);
    when(() => signIn.initialize(serverClientId: any(named: 'serverClientId')))
        .thenAnswer((_) async {});
    when(() => signIn.authorizationClient).thenReturn(authz);
  });

  GoogleDriveAuth make() => GoogleDriveAuth(
    serverClientId: 'web-id',
    lock: lock,
    prefs: SharedPreferencesAsync(),
    signIn: signIn,
  );

  test(
    'connect asks only for app files and app data, remembers the account',
    () async {
      final account = _Account();
      final accountAuthz = _Authz();
      when(() => account.email).thenReturn('me@example.com');
      when(() => account.authorizationClient).thenReturn(accountAuthz);
      when(() => signIn.authenticate(scopeHint: any(named: 'scopeHint')))
          .thenAnswer((_) async => account);
      when(() => accountAuthz.authorizeScopes(any())).thenAnswer(
        (_) async => const GoogleSignInClientAuthorization(accessToken: 't'),
      );

      when(() => authz.authorizationForScopes(any())).thenAnswer(
        (_) async => const GoogleSignInClientAuthorization(accessToken: 't'),
      );

      final auth = make();
      expect(await auth.connect(), isA<Ok<String?>>());
      expect(auth.account.value, 'me@example.com');
      verify(
        () => accountAuthz.authorizeScopes([
          'https://www.googleapis.com/auth/drive.file',
          'https://www.googleapis.com/auth/drive.appdata',
        ]),
      ).called(1);
      verify(() => signIn.initialize(serverClientId: 'web-id')).called(1);

      // Survives a restart without any network or UI.
      final later = make();
      await later.load();
      expect(later.account.value, 'me@example.com');
    },
  );

  test('Drive unticked on the consent screen: not signed in', () async {
    final account = _Account();
    final accountAuthz = _Authz();
    when(() => account.email).thenReturn('me@example.com');
    when(() => account.authorizationClient).thenReturn(accountAuthz);
    when(() => signIn.authenticate(scopeHint: any(named: 'scopeHint')))
        .thenAnswer((_) async => account);
    when(() => accountAuthz.authorizeScopes(any())).thenAnswer(
      (_) async => const GoogleSignInClientAuthorization(accessToken: 't'),
    );
    when(() => authz.authorizationForScopes(any()))
        .thenAnswer((_) async => null);
    when(signIn.signOut).thenAnswer((_) async {});

    final auth = make();
    final r = await auth.connect();
    expect(
      ((r as Err).failure as DriveFailure).problem,
      DriveProblem.notAllowed,
    );
    expect(auth.account.value, isNull);
    verify(signIn.signOut).called(1);
  });

  test('backing out is not an error; misconfiguration is', () async {
    when(() => signIn.authenticate(scopeHint: any(named: 'scopeHint')))
        .thenThrow(
          const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
        );
    final auth = make();
    expect((await auth.connect() as Ok<String?>).value, isNull);
    expect(auth.account.value, isNull);

    when(() => signIn.authenticate(scopeHint: any(named: 'scopeHint')))
        .thenThrow(
          const GoogleSignInException(
            code: GoogleSignInExceptionCode.clientConfigurationError,
          ),
        );
    final r = await auth.connect();
    expect(((r as Err).failure as DriveFailure).problem, DriveProblem.unknown);
  });

  test('client: not connected / needs a prompt / prompted', () async {
    final auth = make();
    await expectLater(
      auth.client(),
      throwsA(
        isA<DriveException>().having(
          (e) => e.problem,
          'problem',
          DriveProblem.notConnected,
        ),
      ),
    );

    await SharedPreferencesAsync().setString('drive.account', 'me@x.com');
    await auth.load();
    when(() => authz.authorizationForScopes(any()))
        .thenAnswer((_) async => null);
    await expectLater(
      auth.client(),
      throwsA(
        isA<DriveException>().having(
          (e) => e.problem,
          'problem',
          DriveProblem.authExpired,
        ),
      ),
    );

    when(() => authz.authorizeScopes(any())).thenAnswer(
      (_) async => const GoogleSignInClientAuthorization(accessToken: 't2'),
    );
    final client = await auth.client(prompt: true);
    client.close();
    verify(() => authz.authorizeScopes(any())).called(1);

    // A rejected token is cleared so the next client gets a fresh one.
    when(
      () =>
          authz.clearAuthorizationToken(accessToken: any(named: 'accessToken')),
    ).thenAnswer((_) async {});
    await auth.tokenRejected();
    verify(() => authz.clearAuthorizationToken(accessToken: 't2')).called(1);
  });

  test('disconnect forgets the account even when offline', () async {
    await SharedPreferencesAsync().setString('drive.account', 'me@x.com');
    when(signIn.disconnect).thenThrow(Exception('offline'));
    final auth = make();
    await auth.load();
    await auth.disconnect();
    expect(auth.account.value, isNull);
    expect(await SharedPreferencesAsync().getString('drive.account'), isNull);
  });
}
