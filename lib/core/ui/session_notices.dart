/// Notices the user dismissed for this app session only. Lives in memory, so
/// they come back after the app restarts (e.g. the Password Notes
/// unencrypted-data warning must not be dismissible for good).
final class SessionNotices {
  bool passwordWarningDismissed = false;
}
