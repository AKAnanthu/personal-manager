import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/form_page.dart';
import 'package:personal_life_manager/core/ui/widgets/pickers.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/features/documents/domain/documents_repository.dart';
import 'package:personal_life_manager/features/documents/presentation/linked_documents.dart';
import 'package:personal_life_manager/features/personal_details/domain/personal_entry.dart';
import 'package:personal_life_manager/features/personal_details/presentation/detail_text.dart';
import 'package:personal_life_manager/features/personal_details/presentation/entry_editor_cubit.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

class EntryEditorPage extends StatelessWidget {
  const EntryEditorPage({required this.documents, super.key});

  final DocumentsRepository documents;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<EntryEditorCubit>();
    return BlocConsumer<EntryEditorCubit, EntryEditorState>(
      listenWhen: (a, b) => a.outcome != b.outcome || a.failure != b.failure,
      listener: (context, s) {
        if (s.outcome != EditorOutcome.none) {
          AppBackButton.popOrHome(context);
        } else if (s.failure case final f?) {
          showSnack(context, f.message(l10n));
          cubit.clearFailure();
        }
      },
      buildWhen: (a, b) => a.loading != b.loading,
      builder: (context, s) => s.loading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _Form(documents: documents),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form({required this.documents});

  final DocumentsRepository documents;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final EntryEditorCubit _cubit = context.read<EntryEditorCubit>();
  late final _title = TextEditingController(text: _cubit.state.title);

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<EntryEditorCubit, EntryEditorState>(
      builder: (context, s) {
        final kindName = l10n.detailKind(s.kind.name);
        return FormPage(
          title: s.isNew
              ? (s.kind == DetailKind.profile
                    ? kindName
                    : l10n.addKindTitle(kindName))
              : l10n.editKindTitle(kindName),
          dirty: s.dirty,
          saving: s.busy,
          onSave: _cubit.save,
          children: [
            if (s.kind.namedByUser) ...[
              LabeledField(
                label: l10n.entryTitleLabel(s.kind.name),
                child: TextField(
                  controller: _title,
                  autofocus: s.isNew,
                  textCapitalization: TextCapitalization.words,
                  onChanged: _cubit.titleChanged,
                  decoration: InputDecoration(
                    errorText: s.showErrors && s.titleMissing
                        ? l10n.fieldRequired
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            for (final spec in s.kind.fields) ...[
              _TemplateField(
                key: ValueKey(spec.key),
                spec: spec,
                required: spec.key == s.requiredKey,
                autofocus:
                    s.isNew && !s.kind.namedByUser && spec.key == s.requiredKey,
              ),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: AppSpacing.section - 14),
            _LinkedDocuments(documents: widget.documents),
            const SizedBox(height: AppSpacing.section),
            SectionLabel(l10n.customFieldsLabel),
            for (final c in s.custom)
              _CustomRow(key: ValueKey(c.localKey), field: c),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _cubit.addCustomField,
                icon: const Icon(LucideIcons.plus),
                label: Text(l10n.addCustomField),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TemplateField extends StatefulWidget {
  const _TemplateField({
    required this.spec,
    required this.required,
    required this.autofocus,
    super.key,
  });

  final FieldSpec spec;
  final bool required;
  final bool autofocus;

  @override
  State<_TemplateField> createState() => _TemplateFieldState();
}

class _TemplateFieldState extends State<_TemplateField> {
  late final EntryEditorCubit _cubit = context.read<EntryEditorCubit>();
  late final _text = TextEditingController(
    text: _cubit.state.values[widget.spec.key] ?? '',
  );

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spec = widget.spec;
    final label = l10n.detailField(spec.key);
    final error = context.select<EntryEditorCubit, bool>(
      (c) => c.state.showErrors && widget.required && c.state.requiredMissing,
    );
    if (spec.input == FieldInput.date) {
      final value = context.select<EntryEditorCubit, String>(
        (c) => c.state.values[spec.key] ?? '',
      );
      final date = decodeDetailDate(value);
      return PickerField(
        label: label,
        optional: !widget.required,
        hint: l10n.pickDateHint,
        icon: LucideIcons.calendar,
        value: date == null ? null : AppFormats.of(context).fullDate(date),
        errorText: error ? l10n.fieldRequired : null,
        onTap: () async {
          final d = await pickDate(context, initial: date);
          if (d != null) _cubit.valueChanged(spec.key, encodeDetailDate(d));
        },
        onClear: () => _cubit.valueChanged(spec.key, ''),
      );
    }
    final multiline = spec.input == FieldInput.multiline;
    return LabeledField(
      label: label,
      optional: !widget.required,
      child: TextField(
        controller: _text,
        autofocus: widget.autofocus,
        minLines: multiline ? 2 : 1,
        maxLines: multiline ? 5 : 1,
        keyboardType: switch (spec.input) {
          FieldInput.phone => TextInputType.phone,
          FieldInput.email => TextInputType.emailAddress,
          FieldInput.multiline => TextInputType.multiline,
          _ => TextInputType.text,
        },
        textCapitalization: switch (spec.input) {
          FieldInput.idNumber => TextCapitalization.characters,
          FieldInput.email || FieldInput.phone => TextCapitalization.none,
          _ => TextCapitalization.sentences,
        },
        // ID numbers: no suggestions, so they aren't learnt by the keyboard.
        autocorrect: spec.input != FieldInput.idNumber,
        enableSuggestions: spec.input != FieldInput.idNumber,
        inputFormatters: spec.input == FieldInput.phone
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-() ]'))]
            : null,
        onChanged: (v) => _cubit.valueChanged(spec.key, v),
        decoration: InputDecoration(
          errorText: error ? l10n.fieldRequired : null,
        ),
      ),
    );
  }
}

class _CustomRow extends StatefulWidget {
  const _CustomRow({required this.field, super.key});

  final CustomFieldDraft field;

  @override
  State<_CustomRow> createState() => _CustomRowState();
}

class _CustomRowState extends State<_CustomRow> {
  late final _label = TextEditingController(text: widget.field.label);
  late final _value = TextEditingController(text: widget.field.value);

  @override
  void dispose() {
    _label.dispose();
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<EntryEditorCubit>();
    final f = widget.field;
    final labelError = context.select<EntryEditorCubit, bool>(
      (c) => c.state.showErrors && c.state.customLabelMissing(f),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _label,
              autofocus: f.label.isEmpty && f.value.isEmpty,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (v) => cubit.customChanged(f.localKey, label: v),
              decoration: InputDecoration(
                hintText: l10n.customFieldLabelHint,
                errorText: labelError ? l10n.fieldRequired : null,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _value,
              onChanged: (v) => cubit.customChanged(f.localKey, value: v),
              decoration: InputDecoration(hintText: l10n.customFieldValueHint),
            ),
          ),
          IconButton(
            tooltip: l10n.removeFieldTooltip,
            icon: const Icon(LucideIcons.x),
            onPressed: () => cubit.removeCustomField(f.localKey),
          ),
        ],
      ),
    );
  }
}

/// Linked documents as removable chips, plus "Link document".
class _LinkedDocuments extends StatelessWidget {
  const _LinkedDocuments({required this.documents});

  final DocumentsRepository documents;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<EntryEditorCubit>();
    final ids = context.select<EntryEditorCubit, List<String>>(
      (c) => c.state.linkedDocumentIds,
    );
    return BlocProvider(
      create: (_) => LinkedDocumentsCubit(documents),
      child: Builder(
        builder: (context) {
          context.read<LinkedDocumentsCubit>().setIds(ids);
          final linked = context.watch<LinkedDocumentsCubit>().state;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(l10n.linkedDocumentsLabel),
              Wrap(
                spacing: AppSpacing.gap,
                runSpacing: AppSpacing.gap,
                children: [
                  for (final d in linked)
                    InputChip(
                      avatar: const Icon(LucideIcons.fileText),
                      label: Text(d.title),
                      deleteButtonTooltipMessage: l10n.unlinkDocumentTooltip(
                        d.title,
                      ),
                      onDeleted: () => cubit.unlinkDocument(d.id),
                    ),
                  ActionChip(
                    avatar: const Icon(LucideIcons.link),
                    label: Text(l10n.linkDocumentAction),
                    onPressed: () async {
                      final id = await pickDocument(
                        context,
                        repository: documents,
                        exclude: ids.toSet(),
                      );
                      if (id != null) cubit.linkDocument(id);
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
