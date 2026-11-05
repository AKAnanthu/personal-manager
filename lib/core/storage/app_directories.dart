import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// All persistent app data lives under one root so it can be excluded from
/// OS backups as a unit.
final class AppDirectories {
  const AppDirectories(this.root);

  final Directory root;

  Directory get database => Directory(p.join(root.path, 'db'));
  Directory get files => Directory(p.join(root.path, 'files'));

  /// Working space for backups and restores; emptied on every launch.
  Directory get temp => Directory(p.join(root.path, 'tmp'));

  static Future<AppDirectories> resolve() async {
    final support = await getApplicationSupportDirectory();
    final dirs = AppDirectories(Directory(p.join(support.path, 'plm_data')));
    await dirs.database.create(recursive: true);
    await dirs.files.create(recursive: true);
    return dirs;
  }
}
