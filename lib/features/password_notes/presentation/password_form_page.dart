import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:personal_life_manager/core/ui/failure_messages.dart';
import 'package:personal_life_manager/core/ui/theme/app_theme.dart';
import 'package:personal_life_manager/core/ui/view_status.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/ui/widgets/form_page.dart';
import 'package:personal_life_manager/core/ui/widgets/notice_banner.dart';
import 'package:personal_life_manager/core/ui/widgets/password_field.dart';
import 'package:personal_life_manager/core/ui/widgets/text_prompt.dart';
import 'package:personal_life_manager/features/password_notes/presentation/password_form_cubit.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

class PasswordFormPage extends StatelessWidget {
  const PasswordFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<PasswordFormCubit>();
    return BlocConsumer<PasswordFormCubit, PasswordFormState>(
      listenWhen: (a, b) => a.outcome != b.outcome || a.failure != b.failure,
      listener: (context, s) {
        if (s.outcome != EditorOutcome.none) {
          if (s.outcome == EditorOutcome.deleted) {
            showSnack(context, l10n.passwordDeletedSnack);
          }
          AppBackButton.popOrHome(context);
        } else if (s.failure case final f?) {
          showSnack(context, f.message(l10n));
          cubit.clearFailure();
        }
      },
      buildWhen: (a, b) => a.loading != b.loading,
      builder: (context, s) => s.loading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : const _Form(),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form();

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final PasswordFormCubit _cubit = context.read<PasswordFormCubit>();
  late final _name = TextEditingController(text: _cubit.state.name);
  late final _url = TextEditingController(text: _cubit.state.url);
  late final _username = TextEditingController(text: _cubit.state.username);
  late final _password = TextEditingController(text: _cubit.state.password);
  late final _notes = TextEditingController(text: _cubit.state.notes);

  @override
  void dispose() {
    for (final c in [_name, _url, _username, _password, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l10n.deletePasswordTitle,
      message: l10n.cannotUndoBody,
      confirmLabel: l10n.deleteAction,
    );
    if (ok) await _cubit.delete();
  }

  Future<void> _newCategory() async {
    final name = await askText(
      context,
      title: AppLocalizations.of(context).newCategoryTitle,
      hint: AppLocalizations.of(context).categoryNameHint,
    );
    if (name != null) _cubit.categoryAdded(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return BlocBuilder<PasswordFormCubit, PasswordFormState>(
      builder: (context, s) => FormPage(
        title: s.isNew ? l10n.newPasswordTitle : l10n.editPasswordTitle,
        dirty: s.dirty,
        saving: s.busy,
        onSave: _cubit.save,
        actions: [
          if (!s.isNew)
            IconButton(
              tooltip: l10n.deleteAction,
              icon: const Icon(LucideIcons.trash2),
              onPressed: _confirmDelete,
            ),
        ],
        children: [
          LabeledField(
            label: l10n.websiteNameLabel,
            child: TextField(
              controller: _name,
              autofocus: s.isNew,
              textCapitalization: TextCapitalization.sentences,
              onChanged: _cubit.nameChanged,
              decoration: InputDecoration(
                errorText: s.showErrors && s.nameMissing
                    ? l10n.fieldRequired
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 14),
          LabeledField(
            label: l10n.websiteUrlLabel,
            optional: true,
            child: TextField(
              controller: _url,
              keyboardType: TextInputType.url,
              autocorrect: false,
              onChanged: _cubit.urlChanged,
              decoration: const InputDecoration(hintText: 'https://'),
            ),
          ),
          const SizedBox(height: 14),
          LabeledField(
            label: l10n.usernameLabel,
            optional: true,
            child: TextField(
              controller: _username,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: _cubit.usernameChanged,
            ),
          ),
          const SizedBox(height: 14),
          PasswordField(
            label: l10n.passwordLabel,
            controller: _password,
            onChanged: _cubit.passwordChanged,
            // Not the app's own password: keep autofill services out.
            autofillHints: const [],
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          LabeledField(
            label: l10n.categoryLabel,
            optional: true,
            child: Wrap(
              spacing: AppSpacing.gap,
              runSpacing: AppSpacing.gap,
              children: [
                for (final c in s.categories)
                  FilterChip(
                    label: Text(c),
                    showCheckmark: false,
                    selected: s.category == c,
                    onSelected: (_) => _cubit.categoryToggled(c),
                  ),
                ActionChip(
                  avatar: const Icon(LucideIcons.plus),
                  label: Text(l10n.newCategoryAction),
                  onPressed: _newCategory,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          LabeledField(
            label: l10n.notesLabel,
            optional: true,
            child: TextField(
              controller: _notes,
              minLines: 2,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              onChanged: _cubit.notesChanged,
            ),
          ),
          const SizedBox(height: 6),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: s.isFavourite,
            onChanged: (v) => _cubit.favouriteChanged(value: v ?? false),
            title: Text(
              l10n.addToFavourites,
              style: theme.textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: 6),
          NoticeBanner(
            message: l10n.savedUnencryptedNote,
            tone: NoticeTone.warning,
          ),
        ],
      ),
    );
  }
}
