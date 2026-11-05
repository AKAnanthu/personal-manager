import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:personal_life_manager/core/db/app_database.steps.dart';
import 'package:personal_life_manager/core/db/columns.dart';
import 'package:personal_life_manager/core/notifications/recurrence.dart';
import 'package:personal_life_manager/core/storage/file_type.dart';
import 'package:personal_life_manager/features/budget/data/budget_tables.dart';
import 'package:personal_life_manager/features/budget/domain/expense.dart';
import 'package:personal_life_manager/features/documents/data/documents_tables.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';
import 'package:personal_life_manager/features/lending/data/lending_tables.dart';
import 'package:personal_life_manager/features/lending/domain/lending.dart';
import 'package:personal_life_manager/features/medicine/data/medicine_tables.dart';
import 'package:personal_life_manager/features/notes/data/notes_tables.dart';
import 'package:personal_life_manager/features/password_notes/data/password_tables.dart';
import 'package:personal_life_manager/features/personal_details/data/personal_tables.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_entry.dart';
import 'package:personal_life_manager/features/reminders/data/reminders_tables.dart';
import 'package:personal_life_manager/features/shopping/data/shopping_tables.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/features/tasks/data/tasks_tables.dart';

part 'app_database.g.dart';

/// Single local database. Every schema change bumps [schemaVersion], is
/// snapshotted with `dart run drift_dev make-migrations`, and gets a
/// non-destructive step in [migration] (tested in `test/drift/`).
@DriftDatabase(
  tables: [
    Notes,
    NoteAttachments,
    Tasks,
    TaskChecklistItems,
    Reminders,
    PersonalEntries,
    PasswordNotes,
    Documents,
    ShoppingLists,
    ShoppingItems,
    Expenses,
    BudgetAmounts,
    LendingRecords,
    Medicines,
  ],
  include: {
    'package:personal_life_manager/features/notes/data/notes.drift',
    'package:personal_life_manager/features/personal_details/data/personal.drift',
    'package:personal_life_manager/features/password_notes/data/passwords.drift',
    'package:personal_life_manager/features/documents/data/documents.drift',
    'package:personal_life_manager/features/shopping/data/shopping.drift',
  },
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Opens the on-device database inside [directory].
  factory AppDatabase.open(Directory directory) => AppDatabase(
    driftDatabase(
      name: 'plm',
      native: DriftNativeOptions(databaseDirectory: () async => directory),
    ),
  );

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.create(schema.notes);
        await m.create(schema.noteAttachments);
        await m.create(schema.notesFts);
        // Triggers aren't part of versioned schemas; v2 introduces them,
        // so the current definitions are the v2 ones. Later changes to them
        // need their own drop/create step.
        await m.create(notesFtsAi);
        await m.create(notesFtsAd);
        await m.create(notesFtsAu);
        await m.create(schema.tasks);
        await m.create(schema.taskChecklistItems);
        await m.create(schema.reminders);
      },
      from2To3: (m, schema) async {
        await m.create(schema.personalEntries);
        await m.create(schema.personalEntriesFts);
        await m.create(schema.passwordNotes);
        await m.create(schema.passwordNotesFts);
        // Introduced in v3; see the note on v2 triggers.
        for (final t in [
          personalFtsAi,
          personalFtsAd,
          personalFtsAu,
          passwordFtsAi,
          passwordFtsAd,
          passwordFtsAu,
        ]) {
          await m.create(t);
        }
      },
      from3To4: (m, schema) async {
        await m.create(schema.documents);
        await m.create(schema.documentsExpiry);
        await m.create(schema.documentsFts);
        // Introduced in v4; see the note on v2 triggers.
        for (final t in [documentsFtsAi, documentsFtsAd, documentsFtsAu]) {
          await m.create(t);
        }
      },
      from4To5: (m, schema) async {
        await m.create(schema.shoppingLists);
        await m.create(schema.shoppingItems);
        await m.create(schema.expenses);
        await m.create(schema.shoppingOneActive);
        await m.create(schema.shoppingItemsList);
      },
      from5To6: (m, schema) async {
        await m.create(schema.budgetAmounts);
        await m.create(schema.lendingRecords);
        await m.create(schema.medicines);
      },
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
