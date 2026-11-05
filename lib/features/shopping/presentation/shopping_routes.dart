import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_life_manager/core/ui/widgets/common.dart';
import 'package:personal_life_manager/core/utils/formats.dart';
import 'package:personal_life_manager/core/utils/money.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/l10n/gen/app_localizations.dart';

abstract final class ShoppingRoutes {
  static const root = '/shopping';
  static const newList = '/shopping/new';
  static const import = '/shopping/import';
  static const session = '/shopping/session';
  static String copy(String fromId) => '/shopping/new?from=$fromId';
  static String edit(String id) => '/shopping/lists/$id';
  static String finish(String id) => '/shopping/lists/$id/finish';
  static String history(String id) => '/shopping/history/$id';
  static String historyEdit(String id) => '/shopping/history/$id/edit';
}

/// "29 Oct · 11 items · ₹1,734 · receipt".
String historyLine(BuildContext context, ShoppingList l) {
  final l10n = AppLocalizations.of(context);
  final fmt = AppFormats.of(context);
  final date = l.purchasedOn;
  final total = l.totalPaise;
  return [
    if (date != null) fmt.shortDate(date),
    l10n.shoppingItemCount(l.items.length),
    if (total != null) Money.format(total),
    if (l.receipt != null) l10n.shoppingReceiptTag,
  ].join(' · ');
}

/// Shown when starting a list while another session is in progress.
Future<void> showSessionInProgress(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final open = await confirmDialog(
    context,
    title: l10n.shoppingInProgressTitle,
    message: l10n.shoppingInProgressBody,
    confirmLabel: l10n.shoppingOpenCurrent,
    destructive: false,
  );
  if (open && context.mounted) await context.push(ShoppingRoutes.session);
}
