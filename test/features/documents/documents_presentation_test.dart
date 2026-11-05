import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:personal_life_manager/core/error/failure.dart';
import 'package:personal_life_manager/core/error/result.dart';
import 'package:personal_life_manager/core/notifications/notification_permissions.dart';
import 'package:personal_life_manager/core/storage/file_access.dart';
import 'package:personal_life_manager/core/storage/file_type.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';
import 'package:personal_life_manager/features/documents/domain/documents_repository.dart';
import 'package:personal_life_manager/features/documents/presentation/document_form_cubit.dart';
import 'package:personal_life_manager/features/documents/presentation/document_view_cubit.dart';
import 'package:personal_life_manager/features/documents/presentation/documents_bloc.dart';
import 'package:personal_life_manager/features/documents/presentation/linked_documents.dart';

class _Repo extends Mock implements DocumentsRepository;

class _Pickers extends Mock implements FilePickers;

class _Perms extends Mock implements NotificationPermissions;

final _passport = AppDocument(
  id: 'd1',
  title: 'Passport',
  description: '',
  category: DocumentCategory.personal,
  fileKey: 'k',
  originalName: 'passport.pdf',
  fileType: SupportedFileType.pdf,
  sizeBytes: 1200,
  isFavourite: false,
  expiryDate: DateTime(2031, 8, 14),
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  late _Repo repo;
  late _Pickers pickers;
  late _Perms perms;
  late Directory dir;

  setUpAll(() {
    registerFallbackValue(const DocumentFilter());
    registerFallbackValue(
      const DocumentDraft(title: '', category: DocumentCategory.others),
    );
    registerFallbackValue(File(''));
  });

  setUp(() {
    repo = _Repo();
    pickers = _Pickers();
    perms = _Perms();
    dir = Directory.systemTemp.createTempSync('doc_form');
    when(perms.ensurePermission).thenAnswer((_) async => true);
    when(
      () => repo.add(
        any(),
        source: any(named: 'source'),
        originalName: any(named: 'originalName'),
      ),
    ).thenAnswer((_) async => const Ok('new'));
    when(
      () => repo.update(
        any(),
        replacement: any(named: 'replacement'),
        replacementName: any(named: 'replacementName'),
      ),
    ).thenAnswer((_) async => const Ok(null));
  });
  tearDown(() => dir.deleteSync(recursive: true));

  PickedFile picked(String name, List<int> header) {
    final f = File(p.join(dir.path, name))..writeAsBytesSync([...header, 1]);
    return PickedFile(f, name);
  }

  final pdf = [0x25, 0x50, 0x44, 0x46];

  DocumentFormCubit form({String? id}) => DocumentFormCubit(
    repository: repo,
    pickers: pickers,
    permissions: perms,
    documentId: id,
  );

  group('DocumentFormCubit', () {
    blocTest<DocumentFormCubit, DocumentFormState>(
      'needs a file, a title and a category',
      build: form,
      act: (c) async {
        await c.load();
        await c.save();
      },
      verify: (c) {
        expect(c.state.showErrors, isTrue);
        expect(c.state.fileMissing && c.state.categoryMissing, isTrue);
        verifyNever(
          () => repo.add(
            any(),
            source: any(named: 'source'),
            originalName: any(named: 'originalName'),
          ),
        );
      },
    );

    blocTest<DocumentFormCubit, DocumentFormState>(
      'a wrong file type is reported when picked',
      setUp: () => when(
        pickers.chooseDocument,
      ).thenAnswer((_) async => picked('photo.pdf', const [0xFF, 0xD8, 0xFF])),
      build: form,
      act: (c) async {
        await c.load();
        await c.pickFile();
      },
      verify: (c) {
        expect(c.state.failure, const UnsupportedFileFailure());
        expect(c.state.file, isNull);
      },
    );

    blocTest<DocumentFormCubit, DocumentFormState>(
      'title comes from the file name until the user types one',
      setUp: () {
        var n = 0;
        when(pickers.chooseDocument).thenAnswer(
          (_) async => picked(n++ == 0 ? 'scan_01.pdf' : 'scan_02.pdf', pdf),
        );
      },
      build: form,
      act: (c) async {
        await c.load();
        await c.pickFile();
        expect(c.state.title, 'scan_01');
        await c.pickFile();
        expect(c.state.title, 'scan_02');
        c.titleChanged('Passport');
        await c.pickFile();
      },
      verify: (c) => expect(c.state.title, 'Passport'),
    );

    blocTest<DocumentFormCubit, DocumentFormState>(
      'new document is added; permission is asked for the expiry reminder',
      setUp: () =>
          when(pickers.takePhoto)
              .thenAnswer((_) async => picked('IMG_1.pdf', pdf)),
      build: form,
      act: (c) async {
        await c.load();
        await c.scanWithCamera();
        c
          ..titleChanged('Insurance')
          ..categoryChanged(DocumentCategory.propertyVehicle)
          ..expiryChanged(DateTime(2027, 1, 5));
        await c.save();
      },
      verify: (c) {
        expect(c.state.outcome, EditorOutcome.saved);
        verify(
          () => repo.add(
            DocumentDraft(
              title: 'Insurance',
              category: DocumentCategory.propertyVehicle,
              expiryDate: DateTime(2027, 1, 5),
            ),
            source: any(named: 'source'),
            originalName: 'IMG_1.pdf',
          ),
        ).called(1);
        verify(perms.ensurePermission).called(1);
      },
    );

    blocTest<DocumentFormCubit, DocumentFormState>(
      'editing without a new file updates details only, no permission '
      'prompt when the reminder is off',
      setUp: () =>
          when(() => repo.watchDocument('d1'))
              .thenAnswer((_) => Stream.value(_passport)),
      build: () => form(id: 'd1'),
      act: (c) async {
        await c.load();
        c
          ..expiryReminderChanged(value: false)
          ..descriptionChanged('both pages');
        await c.save();
      },
      verify: (c) {
        verify(
          () => repo.update(
            DocumentDraft(
              id: 'd1',
              title: 'Passport',
              description: 'both pages',
              category: DocumentCategory.personal,
              expiryDate: DateTime(2031, 8, 14),
              expiryReminder: false,
            ),
          ),
        ).called(1);
        verifyNever(perms.ensurePermission);
      },
    );

    blocTest<DocumentFormCubit, DocumentFormState>(
      'save failure keeps the form open with the error',
      setUp: () {
        when(pickers.chooseDocument)
            .thenAnswer((_) async => picked('a.pdf', pdf));
        when(
          () => repo.add(
            any(),
            source: any(named: 'source'),
            originalName: any(named: 'originalName'),
          ),
        ).thenAnswer((_) async => const Err(StorageFailure()));
      },
      build: form,
      act: (c) async {
        await c.load();
        await c.pickFile();
        c.categoryChanged(DocumentCategory.others);
        await c.save();
      },
      verify: (c) {
        expect(c.state.outcome, EditorOutcome.none);
        expect(c.state.failure, const StorageFailure());
      },
    );
  });

  group('DocumentsBloc', () {
    blocTest<DocumentsBloc, DocumentsState>(
      'loads the list and the expiring-soon banner; filters reach the repo',
      setUp: () {
        when(() => repo.watch(any()))
            .thenAnswer((_) => Stream.value([_passport]));
        when(() => repo.watchExpiringSoon(any()))
            .thenAnswer((_) => Stream.value([_passport]));
      },
      build: () => DocumentsBloc(repo, clock: () => DateTime(2026, 11, 3)),
      act: (b) async {
        b.add(const DocumentsStarted());
        await Future<void>.delayed(Duration.zero);
        b.add(
          const DocumentsFilterSelected(category: DocumentCategory.medical),
        );
      },
      wait: const Duration(milliseconds: 10),
      verify: (b) {
        expect(b.state.status, LoadStatus.ready);
        expect(b.state.expiringSoon, [_passport]);
        verify(() => repo.watchExpiringSoon(DateTime(2026, 11, 3))).called(1);
        verify(
          () => repo.watch(
            const DocumentFilter(category: DocumentCategory.medical),
          ),
        ).called(1);
      },
    );

    blocTest<DocumentsBloc, DocumentsState>(
      'the picker variant does not watch expiry',
      setUp: () =>
          when(() => repo.watch(any()))
              .thenAnswer((_) => Stream.value(const [])),
      build: () => DocumentsBloc(repo, watchExpiry: false),
      act: (b) => b.add(const DocumentsStarted()),
      verify: (_) => verifyNever(() => repo.watchExpiringSoon(any())),
    );
  });

  group('DocumentViewCubit', () {
    test('shows the document with its file; missing file is null', () async {
      when(() => repo.watchDocument('d1'))
          .thenAnswer((_) => Stream.value(_passport));
      when(() => repo.fileFor(_passport))
          .thenAnswer((_) async => const Err(NotFoundFailure()));
      final c = DocumentViewCubit(repository: repo, documentId: 'd1')..start();
      await Future<void>.delayed(Duration.zero);
      expect(c.state.document, _passport);
      expect(c.state.file, isNull);
      expect(c.state.status, LoadStatus.ready);
      await c.close();
    });

    test('delete closes the page', () async {
      when(() => repo.watchDocument('d1'))
          .thenAnswer((_) => const Stream.empty());
      when(() => repo.delete('d1')).thenAnswer((_) async => const Ok(null));
      final c = DocumentViewCubit(repository: repo, documentId: 'd1')..start();
      await c.delete();
      expect(c.state.deleted, isTrue);
      await c.close();
    });
  });

  test('LinkedDocumentsCubit follows the id list', () async {
    when(() => repo.watchByIds(['d1']))
        .thenAnswer((_) => Stream.value([_passport]));
    when(() => repo.watchByIds(const []))
        .thenAnswer((_) => Stream.value(const []));
    final c = LinkedDocumentsCubit(repo)..setIds(['d1']);
    await Future<void>.delayed(Duration.zero);
    expect(c.state, [_passport]);
    c
      ..setIds(['d1'])
      ..setIds(const []);
    await Future<void>.delayed(Duration.zero);
    expect(c.state, isEmpty);
    verify(() => repo.watchByIds(['d1'])).called(1);
    await c.close();
  });
}
