import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_life_manager/core/storage/file_type.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';
import 'package:personal_life_manager/features/documents/domain/documents_repository.dart';
import 'package:personal_life_manager/features/documents/presentation/documents_bloc.dart';
import 'package:personal_life_manager/features/documents/presentation/documents_page.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';
import 'package:personal_life_manager/l10n/locales.dart';

class _Repo extends Mock implements DocumentsRepository;

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.light,
  localizationsDelegates: const [
    ...AppLocalizations.localizationsDelegates,
    GlobalMaterialLocalizations.delegate,
  ],
  supportedLocales: appSupportedLocales,
  locale: const Locale('en', 'IN'),
  home: child,
);

AppDocument _doc(
  String id,
  String title, {
  DocumentCategory category = DocumentCategory.personal,
  SupportedFileType type = SupportedFileType.pdf,
  int size = 1258291,
  DateTime? expiry,
  bool favourite = false,
}) => AppDocument(
  id: id,
  title: title,
  description: '',
  category: category,
  fileKey: 'k',
  originalName: '$title.pdf',
  fileType: type,
  sizeBytes: size,
  isFavourite: favourite,
  expiryDate: expiry,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  final now = DateTime(2026, 11, 3, 18);
  setUpAll(() => registerFallbackValue(const DocumentFilter()));

  Future<_Repo> pump(
    WidgetTester tester, {
    required List<AppDocument> docs,
    List<AppDocument> expiring = const [],
  }) async {
    final repo = _Repo();
    when(() => repo.watch(any())).thenAnswer((_) => Stream.value(docs));
    when(() => repo.watchExpiringSoon(any()))
        .thenAnswer((_) => Stream.value(expiring));
    await tester.pumpWidget(
      _app(
        BlocProvider(
          create: (_) =>
              DocumentsBloc(repo, clock: () => now)
                ..add(const DocumentsStarted()),
          child: DocumentsPage(now: () => now),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return repo;
  }

  testWidgets('list rows, expiry banner and filter chips', (tester) async {
    final insurance = _doc(
      'i',
      'Vehicle insurance',
      category: DocumentCategory.propertyVehicle,
      expiry: DateTime(2026, 11, 12),
    );
    final repo = await pump(
      tester,
      docs: [
        _doc('p', 'Passport', expiry: DateTime(2031, 8, 14), favourite: true),
        _doc(
          'b',
          'Blood test report',
          category: DocumentCategory.medical,
          type: SupportedFileType.jpeg,
          size: 880640,
        ),
        insurance,
      ],
      expiring: [insurance],
    );

    expect(find.text('Vehicle insurance expires 12 Nov'), findsOneWidget);
    expect(find.text('Property and vehicle · 9 days left'), findsOneWidget);
    expect(find.text('Personal · 1.2 MB · Exp. Aug 2031'), findsOneWidget);
    expect(find.text('Medical · 860 KB'), findsOneWidget);
    expect(find.text('JPG'), findsOneWidget);
    expect(find.text('On this device only'), findsNWidgets(3));
    expect(find.text('RECENT'), findsOneWidget);
    expect(find.bySemanticsLabel('Favourites'), findsWidgets);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Medical'));
    await tester.pumpAndSettle();
    verify(
      () =>
          repo.watch(const DocumentFilter(category: DocumentCategory.medical)),
    ).called(1);
  });

  testWidgets('empty state', (tester) async {
    await pump(tester, docs: const []);
    expect(find.text('No documents yet'), findsOneWidget);
    expect(find.text('Add document'), findsOneWidget);
  });
}
