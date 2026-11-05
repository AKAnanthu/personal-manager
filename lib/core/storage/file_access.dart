import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:personal_life_manager/core/security/app_lock.dart';

final class PickedFile {
  const PickedFile(this.file, this.name);

  final File file;

  /// Original file name, kept as metadata only.
  final String name;
}

/// Camera, gallery and document pickers. Each trip to the system UI runs
/// under [AppLock.runExternal] so it doesn't trigger an auto-lock.
abstract interface class FilePickers {
  Future<PickedFile?> takePhoto();
  Future<PickedFile?> choosePhoto();
  Future<PickedFile?> chooseDocument();
}

/// Opens files in another app (Word, Excel). False when nothing can.
abstract interface class FileOpener {
  Future<bool> openExternally(File file);
}

final class PlatformFilePickers implements FilePickers {
  PlatformFilePickers(this._lock, [ImagePicker? images])
    : _images = images ?? ImagePicker();

  final AppLock _lock;
  final ImagePicker _images;

  static const _documentExtensions = [
    'pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'xls', 'xlsx', //
  ];

  @override
  Future<PickedFile?> takePhoto() => _image(ImageSource.camera);

  @override
  Future<PickedFile?> choosePhoto() => _image(ImageSource.gallery);

  Future<PickedFile?> _image(ImageSource source) => _lock.runExternal(() async {
    try {
      // Re-encoded at a sane size; full-resolution camera images are large.
      final x = await _images.pickImage(
        source: source,
        maxWidth: 2560,
        imageQuality: 85,
      );
      return x == null ? null : PickedFile(File(x.path), x.name);
    } on PlatformException {
      return null; // camera/photo permission denied
    }
  });

  @override
  Future<PickedFile?> chooseDocument() => _lock.runExternal(() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _documentExtensions,
    );
    final f = files.firstOrNull;
    final path = f?.path;
    if (f == null || path == null) return null;
    return PickedFile(File(path), f.name.isEmpty ? p.basename(path) : f.name);
  });
}

final class PlatformFileOpener implements FileOpener {
  const PlatformFileOpener(this._lock);

  final AppLock _lock;

  @override
  Future<bool> openExternally(File file) => _lock.runExternal(() async {
    final r = await OpenFilex.open(file.path);
    return r.type == ResultType.done;
  });
}
