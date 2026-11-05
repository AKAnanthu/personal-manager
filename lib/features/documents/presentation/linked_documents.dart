import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/features/documents/domain/document.dart';
import 'package:personal_life_manager/features/documents/domain/documents_repository.dart';
import 'package:personal_life_manager/features/documents/presentation/document_widgets.dart';
import 'package:personal_life_manager/features/documents/presentation/documents_bloc.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

/// Resolves linked document ids (e.g. on a personal-details entry) to
/// documents, live. Deleted documents simply drop out.
class LinkedDocumentsCubit extends Cubit<List<AppDocument>> {
  LinkedDocumentsCubit(this._repository) : super(const []);

  final DocumentsRepository _repository;
  StreamSubscription<List<AppDocument>>? _sub;
  List<String> _ids = const [];

  void setIds(List<String> ids) {
    if (_listEquals(ids, _ids) && _sub != null) return;
    _ids = List.unmodifiable(ids);
    unawaited(_sub?.cancel());
    _sub = _repository.watchByIds(_ids).listen(emit);
  }

  static bool _listEquals(List<String> a, List<String> b) =>
      a.length == b.length &&
      Iterable<int>.generate(a.length).every((i) => a[i] == b[i]);

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await super.close();
  }
}

/// Bottom sheet listing documents (with search) to link. Returns the
/// chosen document's id.
Future<String?> pickDocument(
  BuildContext context, {
  required DocumentsRepository repository,
  Set<String> exclude = const {},
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => BlocProvider(
    create: (_) =>
        DocumentsBloc(repository, watchExpiry: false)
          ..add(const DocumentsStarted()),
    child: _PickerSheet(exclude: exclude),
  ),
);

class _PickerSheet extends StatelessWidget {
  const _PickerSheet({required this.exclude});

  final Set<String> exclude;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<DocumentsBloc>();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, scroll) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              l10n.chooseDocumentTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SearchBar(
              hintText: l10n.documentsSearchHint,
              leading: const Icon(LucideIcons.search),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: (q) => bloc.add(DocumentsQueryChanged(q)),
            ),
            Expanded(
              child: BlocBuilder<DocumentsBloc, DocumentsState>(
                builder: (context, s) {
                  final docs = s.documents
                      .where((d) => !exclude.contains(d.id))
                      .toList();
                  if (s.status == LoadStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (docs.isEmpty) {
                    return EmptyState(
                      icon: LucideIcons.fileText,
                      title: s.isFiltered
                          ? l10n.noMatches
                          : l10n.noDocumentsToLink,
                    );
                  }
                  return ListView.separated(
                    controller: scroll,
                    itemCount: docs.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, i) => DocumentTile(
                      document: docs[i],
                      onTap: () => Navigator.of(context).pop(docs[i].id),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
