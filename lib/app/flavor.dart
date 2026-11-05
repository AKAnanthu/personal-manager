/// Build flavor, supplied via `--dart-define-from-file=config/<flavor>.json`.
enum AppFlavor {
  dev,
  prod;

  static AppFlavor get current =>
      const String.fromEnvironment('FLAVOR') == 'prod' ? prod : dev;

  bool get isDev => this == dev;
}
