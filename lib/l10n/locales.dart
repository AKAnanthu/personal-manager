import 'dart:ui';

/// Strings are English-only in V1 (`app_en.arb` serves every `en_*`), but
/// regional variants are listed so dates and numbers follow the device's
/// region ("12 Nov" in India/UK, "Nov 12" in the US). A device in another
/// English region falls back to the first entry; INR users are the default.
const List<Locale> appSupportedLocales = [
  Locale('en', 'IN'),
  Locale('en', 'GB'),
  Locale('en', 'US'),
  Locale('en', 'AU'),
  Locale('en', 'CA'),
  Locale('en'),
];
