/// A record table that is copied to Google Drive.
final class SyncTable {
  const SyncTable(this.name, {this.parent, this.fileColumns = const []});

  /// SQL table name.
  final String name;

  /// (column, table) of the parent a row is deleted with, if any.
  final (String, String)? parent;

  /// Columns holding FileStore keys; those files are uploaded with the row.
  final List<String> fileColumns;
}

/// Every synced table, parents before children. sync.drift has the
/// change-recording triggers for exactly these tables.
abstract final class SyncTables {
  static const List<SyncTable> all = [
    SyncTable('notes'),
    SyncTable(
      'note_attachments',
      parent: ('note_id', 'notes'),
      fileColumns: ['file_key'],
    ),
    SyncTable('tasks'),
    SyncTable('task_checklist_items', parent: ('task_id', 'tasks')),
    SyncTable('reminders'),
    SyncTable('personal_entries'),
    SyncTable('password_notes'),
    SyncTable('documents', fileColumns: ['file_key']),
    SyncTable('shopping_lists', fileColumns: ['receipt_key']),
    SyncTable('shopping_items', parent: ('list_id', 'shopping_lists')),
    SyncTable('expenses'),
    SyncTable('budget_amounts'),
    SyncTable('lending_records'),
    SyncTable('medicines'),
  ];

  static final Map<String, SyncTable> byName = {for (final t in all) t.name: t};
}

/// File names in Drive's hidden app folder.
abstract final class SyncNames {
  static const _record = 'r.';
  static const _file = 'f.';

  /// `r.notes.<id>.json`: one small JSON file per record.
  static String record(String table, String id) => '$_record$table.$id.json';

  /// `f.<key>`: a document, attachment or receipt, under its FileStore key.
  static String file(String key) => '$_file$key';

  /// (table, id) of a record file name, or null.
  static (String, String)? parseRecord(String name) {
    if (!name.startsWith(_record) || !name.endsWith('.json')) return null;
    final parts = name
        .substring(_record.length, name.length - '.json'.length)
        .split('.');
    if (parts.length != 2 || parts.any((p) => p.isEmpty)) return null;
    return (parts[0], parts[1]);
  }

  /// The FileStore key of a file name, or null.
  static String? parseFile(String name) =>
      name.startsWith(_file) && name.length > _file.length
      ? name.substring(_file.length)
      : null;
}
