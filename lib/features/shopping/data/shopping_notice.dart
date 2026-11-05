import 'package:personal_life_manager/core/notifications/notification_models.dart';
import 'package:personal_life_manager/core/notifications/notification_scheduler.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping.dart';
import 'package:personal_life_manager/features/shopping/domain/shopping_repository.dart';

/// Text for the notice; supplied by the app (l10n) so data stays l10n-free.
typedef NoticeText = ({String title, String body}) Function(ShoppingList list);

/// Shows the single "items left" notification right away (owner decision).
/// It's a one-off with a fixed ID per list, so it can't repeat, and it is
/// removed on resume, completion, deletion or once nothing is left.
final class SchedulerShoppingNotice implements PendingShoppingNotice {
  const SchedulerShoppingNotice(this._scheduler, this._text);

  final NotificationScheduler _scheduler;
  final NoticeText _text;

  static const route = '/shopping/session';

  @override
  Future<void> show(ShoppingList list) {
    final t = _text(list);
    return _scheduler.showNow(
      kind: NotificationKind.shopping,
      entityId: list.id,
      title: t.title,
      body: t.body,
      route: route,
    );
  }

  @override
  Future<void> clear(String listId) =>
      _scheduler.cancelShown(NotificationKind.shopping, listId);
}
