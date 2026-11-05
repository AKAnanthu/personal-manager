import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// App name.
  ///
  /// In en, this message translates to:
  /// **'Personal Life Manager'**
  String get appTitle;

  /// Bottom navigation: dashboard tab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation: documents tab.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get navDocuments;

  /// Bottom navigation: shopping tab.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get navShopping;

  /// Bottom navigation: grid of remaining modules.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// Temporary body text for a tab whose feature is not built yet.
  ///
  /// In en, this message translates to:
  /// **'This section is coming soon.'**
  String get sectionUnderConstruction;

  /// Shown if the local database or file storage can't be opened at launch.
  ///
  /// In en, this message translates to:
  /// **'The app couldn\'t open its local storage. Restart the app. If this keeps happening, check that your device has free storage space.'**
  String get startupFailed;

  /// Primary button that moves to the next step.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// Tooltip/semantics for the button that locks the app immediately.
  ///
  /// In en, this message translates to:
  /// **'Lock app'**
  String get lockAppAction;

  /// Semantics for the eye button that reveals a masked password.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// Semantics for the button that masks a revealed password.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// Shown when the keychain/keystore read or write fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach this device\'s secure storage. Try again.'**
  String get secureStorageError;

  /// Progress label in first-time setup.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String setupStepLabel(int step, int total);

  /// Title of the first setup step.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get setupWelcomeTitle;

  /// Body of the first setup step.
  ///
  /// In en, this message translates to:
  /// **'Keep your personal details, documents, notes, reminders and everyday records in one place, on this phone.'**
  String get setupWelcomeBody;

  /// Title of the password setup step.
  ///
  /// In en, this message translates to:
  /// **'Create your app password'**
  String get setupPasswordTitle;

  /// Subtitle of the password setup step.
  ///
  /// In en, this message translates to:
  /// **'You\'ll enter this each time you open the app.'**
  String get setupPasswordSubtitle;

  /// Label for the new password field.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Label for the repeat-password field.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// Strength label under the new password field.
  ///
  /// In en, this message translates to:
  /// **'{strength, select, tooShort{Too short} fair{Fair} good{Good} strong{Strong} other{}} · at least {min} characters'**
  String passwordStrengthHint(String strength, int min);

  /// Screen-reader label for the strength meter.
  ///
  /// In en, this message translates to:
  /// **'Strength: {strength, select, tooShort{too short} fair{fair} good{good} strong{strong} other{}}'**
  String passwordStrengthSemantics(String strength);

  /// Error under the confirm password field.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDoNotMatch;

  /// Heading of the data-storage disclosure card.
  ///
  /// In en, this message translates to:
  /// **'How your data is stored'**
  String get dataStorageTitle;

  /// Disclosure: data is local.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on this phone. We have no servers.'**
  String get dataStorageLocal;

  /// Disclosure: Drive uploads are manual.
  ///
  /// In en, this message translates to:
  /// **'Copies go to your own Google Drive only when you choose.'**
  String get dataStorageDrive;

  /// Disclosure: no app-level encryption.
  ///
  /// In en, this message translates to:
  /// **'Data, files and backups are not encrypted. The password only controls who opens the app.'**
  String get dataStorageNotEncrypted;

  /// Checkbox the user must tick before continuing setup.
  ///
  /// In en, this message translates to:
  /// **'I understand how my data is stored'**
  String get dataStorageAcknowledge;

  /// Title of the optional biometric step.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, face{Unlock with Face ID?} fingerprint{Unlock with fingerprint?} other{Unlock with biometrics?}}'**
  String setupBiometricTitle(String kind);

  /// Body of the optional biometric step.
  ///
  /// In en, this message translates to:
  /// **'It\'s quicker than typing your password. Your password always works too, and you can change this later in Settings.'**
  String get setupBiometricBody;

  /// Enables biometric unlock.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get setupBiometricEnable;

  /// Skips biometric unlock.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get setupBiometricSkip;

  /// System biometric prompt text when enabling.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you to turn on biometric unlock'**
  String get biometricReasonEnable;

  /// System biometric prompt text when unlocking.
  ///
  /// In en, this message translates to:
  /// **'Unlock Personal Life Manager'**
  String get biometricReasonUnlock;

  /// Shown when the biometric prompt fails or is cancelled.
  ///
  /// In en, this message translates to:
  /// **'Biometric check didn\'t work. Try again or use your password.'**
  String get biometricFailed;

  /// Subtitle on the unlock screen.
  ///
  /// In en, this message translates to:
  /// **'Enter your app password to continue'**
  String get unlockSubtitle;

  /// Label for the password field on the unlock screen.
  ///
  /// In en, this message translates to:
  /// **'App password'**
  String get appPasswordLabel;

  /// Unlock button.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockAction;

  /// Divider between password and biometric unlock.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// Biometric unlock button.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, face{Use Face ID} fingerprint{Use fingerprint} other{Use biometrics}}'**
  String useBiometric(String kind);

  /// Info banner on the unlock screen.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on this device. The app password controls access — it does not encrypt your data or files.'**
  String get unlockInfo;

  /// Error after a wrong password.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Wrong password.} =1{Wrong password. 1 attempt left before a short wait.} other{Wrong password. {count} attempts left before a short wait.}}'**
  String wrongPassword(int count);

  /// Shown during the backoff period after repeated wrong passwords.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {time}.'**
  String lockedOut(String time);

  /// Android notification channel name, shown in system settings.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, medicine{Medicine} reminder{Reminders} task{Tasks} lending{Lending and borrowing} documentExpiry{Document expiry} shopping{Shopping} other{Other}}'**
  String notificationChannelName(String kind);

  /// Android notification channel description.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, medicine{Medicine schedule reminders} reminder{Your reminders} task{Task due-date reminders} lending{Money lent and borrowed due dates} documentExpiry{Documents that are about to expire} shopping{Items left on a paused shopping list} other{Other notifications}}'**
  String notificationChannelDescription(String kind);

  /// Notification action button that snoozes it.
  ///
  /// In en, this message translates to:
  /// **'Snooze {minutes} min'**
  String notificationSnoozeAction(int minutes);

  /// Save button on forms.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// Cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// Delete button or menu item.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// Discard unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardAction;

  /// Stay on the form.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditingAction;

  /// Remove an item.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeAction;

  /// Undo after a delete.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoAction;

  /// Link to the full list.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAllAction;

  /// Clears a field value.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearAction;

  /// Close button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeAction;

  /// Overflow menu tooltip.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// After an optional field label.
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get optionalSuffix;

  /// Validation error for an empty required field.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// Dialog title when leaving a form with unsaved edits.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// Dialog body when leaving a form with unsaved edits.
  ///
  /// In en, this message translates to:
  /// **'Your changes haven\'t been saved.'**
  String get discardChangesBody;

  /// Body of a delete confirmation.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get cannotUndoBody;

  /// Fallback error message.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Opened an item that was deleted.
  ///
  /// In en, this message translates to:
  /// **'This item no longer exists.'**
  String get errorNotFound;

  /// Rejected attachment.
  ///
  /// In en, this message translates to:
  /// **'This file type isn\'t supported. Use PDF, JPG, PNG, Word or Excel files.'**
  String get errorUnsupportedFile;

  /// Rejected attachment over the size limit.
  ///
  /// In en, this message translates to:
  /// **'This file is too large. The limit is {megabytes} MB.'**
  String errorFileTooLarge(int megabytes);

  /// File copy failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the file on this phone. Check free space and try again.'**
  String get errorFileStorage;

  /// No external app for a DOC/XLS file.
  ///
  /// In en, this message translates to:
  /// **'No app on this phone can open this file.'**
  String get errorNoAppToOpen;

  /// Shown when notification permission is denied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off, so reminders won\'t ring.'**
  String get notificationsOffMessage;

  /// Opens the system settings for this app.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get openSettingsAction;

  /// Android 12+: exact alarm permission not granted.
  ///
  /// In en, this message translates to:
  /// **'Reminders may ring a few minutes late. Allow exact alarms for on-time reminders.'**
  String get exactAlarmsOffMessage;

  /// Grants a permission.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allowAction;

  /// Placeholder for an empty date field.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickDateHint;

  /// Placeholder for an empty time field.
  ///
  /// In en, this message translates to:
  /// **'Pick a time'**
  String get pickTimeHint;

  /// Validation for a one-time reminder in the past.
  ///
  /// In en, this message translates to:
  /// **'Pick a time in the future.'**
  String get timeInPastError;

  /// Full module name (page titles, More grid).
  ///
  /// In en, this message translates to:
  /// **'{module, select, personal{Personal details} passwords{Password notes} documents{Documents} notes{Notes} tasks{Tasks} reminders{Reminders} shopping{Shopping} budget{Budget} lending{Lending and borrowing} medicine{Medicine schedule} breathe{Eye rest and breathing} drive{Drive storage} backup{Backup and restore} settings{Settings} other{}}'**
  String moduleName(String module);

  /// Short module name for quick-access tiles.
  ///
  /// In en, this message translates to:
  /// **'{module, select, personal{Personal} passwords{Passwords} documents{Documents} notes{Notes} tasks{Tasks} reminders{Reminders} shopping{Shopping} budget{Budget} lending{Lending} medicine{Medicine} breathe{Breathe} drive{Drive} backup{Backup} settings{Settings} other{}}'**
  String moduleShortName(String module);

  /// Dashboard greeting before noon.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// Dashboard greeting, noon to 5 PM.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// Dashboard greeting after 5 PM.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// Dashboard search button.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get searchNotesTooltip;

  /// Quick-add button label.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get quickAddNote;

  /// Quick-add button label.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get quickAddTask;

  /// Quick-add button label.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get quickAddReminder;

  /// Create a note.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get newNoteAction;

  /// Create a task.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTaskAction;

  /// Create a reminder.
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get newReminderAction;

  /// Dashboard section of upcoming items.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get comingUpTitle;

  /// Empty dashboard section.
  ///
  /// In en, this message translates to:
  /// **'Nothing coming up. Reminders and tasks with dates appear here.'**
  String get comingUpEmpty;

  /// Dashboard module shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Quick access'**
  String get quickAccessTitle;

  /// Subtitle of an upcoming item.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, medicine{Medicine} reminder{Reminder} task{Task} lending{Lending} documentExpiry{Expires} other{}} · {when}'**
  String upcomingLine(String kind, String when);

  /// Relative date with time.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String whenToday(String time);

  /// Relative date with time.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow, {time}'**
  String whenTomorrow(String time);

  /// Relative date with time.
  ///
  /// In en, this message translates to:
  /// **'Yesterday, {time}'**
  String whenYesterday(String time);

  /// Absolute date with time.
  ///
  /// In en, this message translates to:
  /// **'{date}, {time}'**
  String whenDateTime(String date, String time);

  /// Task due date.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueOn(String date);

  /// Notes search field.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get notesSearchHint;

  /// Notes filter chip.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notesFilterAll;

  /// Notes filter chip.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get notesFilterFavourites;

  /// Archived notes view title and button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Archived notes'**
  String get archivedNotesTitle;

  /// Notes section.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get notesPinned;

  /// Notes section.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get notesOthers;

  /// Empty notes list.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get notesEmptyTitle;

  /// Empty notes list.
  ///
  /// In en, this message translates to:
  /// **'Tap New note to write your first one.'**
  String get notesEmptyBody;

  /// Notes search returned nothing.
  ///
  /// In en, this message translates to:
  /// **'No notes match your search.'**
  String get notesNoResults;

  /// Archive is empty.
  ///
  /// In en, this message translates to:
  /// **'No archived notes.'**
  String get notesArchiveEmpty;

  /// Note card footer.
  ///
  /// In en, this message translates to:
  /// **'Edited {date}'**
  String noteEdited(String date);

  /// Attachment summary on a note card.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo} other{{count} photos}}'**
  String notePhotoCount(int count);

  /// Attachment summary on a note card.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file} other{{count} files}}'**
  String noteFileCount(int count);

  /// Note title placeholder.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get noteTitleHint;

  /// Note body placeholder.
  ///
  /// In en, this message translates to:
  /// **'Write something…'**
  String get noteBodyHint;

  /// Note tags section.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get noteTagsLabel;

  /// Note tag input placeholder.
  ///
  /// In en, this message translates to:
  /// **'Add a tag, e.g. home'**
  String get noteTagHint;

  /// Remove a tag.
  ///
  /// In en, this message translates to:
  /// **'Remove tag {tag}'**
  String removeTagTooltip(String tag);

  /// Pin a note.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get notePin;

  /// Unpin a note.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get noteUnpin;

  /// Mark note as favourite.
  ///
  /// In en, this message translates to:
  /// **'Add to favourites'**
  String get noteFavourite;

  /// Unmark favourite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favourites'**
  String get noteUnfavourite;

  /// Archive a note.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get noteArchive;

  /// Restore an archived note.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get noteUnarchive;

  /// Snackbar after archiving.
  ///
  /// In en, this message translates to:
  /// **'Note archived'**
  String get noteArchivedSnack;

  /// Snackbar after deleting.
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get noteDeletedSnack;

  /// Delete confirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete this note?'**
  String get deleteNoteTitle;

  /// Delete confirmation.
  ///
  /// In en, this message translates to:
  /// **'The note and its attachments will be removed from this phone. This can\'t be undone.'**
  String get deleteNoteBody;

  /// Editor title for a new note.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get newNoteTitle;

  /// Editor title for an existing note.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNoteTitle;

  /// Note attachments section.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachmentsLabel;

  /// Attach from camera.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get attachTakePhoto;

  /// Attach from gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get attachChoosePhoto;

  /// Attach a document.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get attachChooseFile;

  /// Opens attachment options.
  ///
  /// In en, this message translates to:
  /// **'Add attachment'**
  String get addAttachmentAction;

  /// Confirmation.
  ///
  /// In en, this message translates to:
  /// **'Remove this attachment?'**
  String get removeAttachmentTitle;

  /// Remove an attachment.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String removeAttachmentTooltip(String name);

  /// Open an attachment.
  ///
  /// In en, this message translates to:
  /// **'Open {name}'**
  String openAttachmentSemantics(String name);

  /// Tasks tab.
  ///
  /// In en, this message translates to:
  /// **'Pending · {count}'**
  String tasksPendingTab(int count);

  /// Tasks tab.
  ///
  /// In en, this message translates to:
  /// **'Completed · {count}'**
  String tasksCompletedTab(int count);

  /// Tasks section.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get tasksOverdue;

  /// Tasks section.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get tasksUpcoming;

  /// Task without a due date.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get taskNoDueDate;

  /// Checkbox semantics.
  ///
  /// In en, this message translates to:
  /// **'Mark {title} done'**
  String taskMarkDone(String title);

  /// Checkbox semantics.
  ///
  /// In en, this message translates to:
  /// **'Mark {title} not done'**
  String taskMarkNotDone(String title);

  /// Checklist progress.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total}'**
  String checklistProgress(int done, int total);

  /// Empty tab.
  ///
  /// In en, this message translates to:
  /// **'No pending tasks'**
  String get tasksEmptyPending;

  /// Empty tab.
  ///
  /// In en, this message translates to:
  /// **'Tap New task to add one.'**
  String get tasksEmptyPendingBody;

  /// Empty tab.
  ///
  /// In en, this message translates to:
  /// **'No completed tasks yet.'**
  String get tasksEmptyCompleted;

  /// Search returned nothing.
  ///
  /// In en, this message translates to:
  /// **'No tasks match your search.'**
  String get tasksNoResults;

  /// Tasks search field and button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Search tasks'**
  String get searchTasksHint;

  /// Task editor title.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTaskTitle;

  /// Task editor title.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTaskTitle;

  /// Title field label.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// Description field label.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// Task due date label.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get dueDateLabel;

  /// Task reminder label.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminderLabel;

  /// Date field label.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// Time field label.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// Task checklist section.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get checklistLabel;

  /// Adds a checklist row.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addChecklistItem;

  /// Checklist row placeholder.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get checklistItemHint;

  /// Removes a checklist row.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get removeChecklistItem;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Task completed'**
  String get taskCompletedSnack;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get taskDeletedSnack;

  /// Confirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete this task?'**
  String get deleteTaskTitle;

  /// Reminders section.
  ///
  /// In en, this message translates to:
  /// **'Overdue · {count}'**
  String remindersOverdue(int count);

  /// Reminders section.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get remindersUpcoming;

  /// Completes a reminder.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get reminderMarkDone;

  /// Snoozes a reminder for an hour.
  ///
  /// In en, this message translates to:
  /// **'Snooze 1 h'**
  String get reminderSnoozeHour;

  /// Info banner.
  ///
  /// In en, this message translates to:
  /// **'Reminders ring even without internet.'**
  String get remindersOffline;

  /// Empty list.
  ///
  /// In en, this message translates to:
  /// **'No reminders'**
  String get remindersEmptyTitle;

  /// Empty list.
  ///
  /// In en, this message translates to:
  /// **'Tap New reminder to add one.'**
  String get remindersEmptyBody;

  /// Repeat option.
  ///
  /// In en, this message translates to:
  /// **'{repeat, select, none{Once} daily{Daily} weekly{Weekly} monthly{Monthly} yearly{Yearly} other{}}'**
  String repeatName(String repeat);

  /// Reminder repeat chooser label.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatSectionLabel;

  /// Repeat helper text.
  ///
  /// In en, this message translates to:
  /// **'Rings once.'**
  String get repeatHelpOnce;

  /// Repeat helper text.
  ///
  /// In en, this message translates to:
  /// **'Repeats every day.'**
  String get repeatHelpDaily;

  /// Repeat helper text.
  ///
  /// In en, this message translates to:
  /// **'Repeats every {weekday}.'**
  String repeatHelpWeekly(String weekday);

  /// Repeat helper text.
  ///
  /// In en, this message translates to:
  /// **'Repeats on day {day} of every month.'**
  String repeatHelpMonthly(int day);

  /// Repeat helper for days 29-31.
  ///
  /// In en, this message translates to:
  /// **'Repeats on day {day} of every month, or the last day of shorter months.'**
  String repeatHelpMonthlyEnd(int day);

  /// Repeat helper text.
  ///
  /// In en, this message translates to:
  /// **'Repeats every year on {date}.'**
  String repeatHelpYearly(String date);

  /// Repeat helper for 29 Feb.
  ///
  /// In en, this message translates to:
  /// **'Repeats every year on 29 February, or 28 February in other years.'**
  String get repeatHelpLeapDay;

  /// Info banner on the reminder form.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be notified on this phone, even offline. Snooze from the notification.'**
  String get reminderFormInfo;

  /// Form title.
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get newReminderTitle;

  /// Form title.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get editReminderTitle;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Marked done'**
  String get reminderDoneSnack;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Snoozed for 1 hour'**
  String get reminderSnoozedSnack;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted'**
  String get reminderDeletedSnack;

  /// Confirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete this reminder?'**
  String get deleteReminderTitle;

  /// More tab title.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// Filter chip showing everything.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Filter chip for favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get filterFavourites;

  /// Edit button.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// Dismiss a banner.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissAction;

  /// Search returned nothing.
  ///
  /// In en, this message translates to:
  /// **'No matches.'**
  String get noMatches;

  /// Copy button tooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy {label}'**
  String copyTooltip(String label);

  /// After copying a value.
  ///
  /// In en, this message translates to:
  /// **'{label} copied'**
  String copiedSnack(String label);

  /// After copying a password or ID number.
  ///
  /// In en, this message translates to:
  /// **'{label} copied. It will be cleared from the clipboard in 30 seconds.'**
  String copiedSensitiveSnack(String label);

  /// Reveal a masked value.
  ///
  /// In en, this message translates to:
  /// **'Show {label}'**
  String showValueTooltip(String label);

  /// Mask a revealed value.
  ///
  /// In en, this message translates to:
  /// **'Hide {label}'**
  String hideValueTooltip(String label);

  /// Personal details tab.
  ///
  /// In en, this message translates to:
  /// **'{category, select, personal{Personal} family{Family} identification{IDs} additional{Work & more} other{}}'**
  String detailCategory(String category);

  /// Type of personal details entry.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, profile{Personal information} familyMember{Family member} aadhaar{Aadhaar} pan{PAN} passport{Passport} drivingLicence{Driving licence} voterId{Voter ID} otherId{Other ID} education{Education} employment{Employment} financial{Financial reference} custom{Custom} other{}}'**
  String detailKind(String kind);

  /// Label of a personal details field.
  ///
  /// In en, this message translates to:
  /// **'{field, select, fullName{Full name} dateOfBirth{Date of birth} phone{Phone number} email{Email address} currentAddress{Current address} permanentAddress{Permanent address} otherInfo{Other information} relationship{Relationship} address{Address} emergencyContact{Emergency contact} number{Number} nameOnId{Name on ID} expiryDate{Expiry date} notes{Notes} institution{Institution} qualification{Qualification} year{Year} employer{Employer} role{Role} employeeId{Employee ID} reference{Reference or account number} other{}}'**
  String detailField(String field);

  /// Label of the user-entered title.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, familyMember{Name} otherId{ID name} financial{Name} other{Title}}'**
  String entryTitleLabel(String kind);

  /// Profile header subtitle.
  ///
  /// In en, this message translates to:
  /// **'Born {date}'**
  String personalBorn(String date);

  /// Profile card when empty.
  ///
  /// In en, this message translates to:
  /// **'Add your details'**
  String get profileEmptyTitle;

  /// Profile card when empty.
  ///
  /// In en, this message translates to:
  /// **'Your name, date of birth, contact details and addresses.'**
  String get profileEmptyBody;

  /// Edit profile button.
  ///
  /// In en, this message translates to:
  /// **'Edit personal information'**
  String get editProfileTooltip;

  /// FAB on the Family tab.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get addFamilyMember;

  /// FAB on the IDs tab.
  ///
  /// In en, this message translates to:
  /// **'Add ID'**
  String get addIdAction;

  /// FAB on the Work & more tab.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get addEntryAction;

  /// Hint under the list.
  ///
  /// In en, this message translates to:
  /// **'Tap a card to see it in full and copy, edit or delete.'**
  String get personalCardHint;

  /// Empty tab.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved here yet.'**
  String get personalTabEmpty;

  /// Search field.
  ///
  /// In en, this message translates to:
  /// **'Search personal details'**
  String get personalSearchHint;

  /// Entry type chooser label.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get chooseTypeLabel;

  /// Custom fields section.
  ///
  /// In en, this message translates to:
  /// **'More fields'**
  String get customFieldsLabel;

  /// Adds a custom field.
  ///
  /// In en, this message translates to:
  /// **'Add field'**
  String get addCustomField;

  /// Custom field label placeholder.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get customFieldLabelHint;

  /// Custom field value placeholder.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get customFieldValueHint;

  /// Removes a custom field.
  ///
  /// In en, this message translates to:
  /// **'Remove field'**
  String get removeFieldTooltip;

  /// Confirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get deleteEntryTitle;

  /// Snackbar after deleting.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get entryDeletedSnack;

  /// Entry form title.
  ///
  /// In en, this message translates to:
  /// **'Add {kind}'**
  String addKindTitle(String kind);

  /// Entry form title.
  ///
  /// In en, this message translates to:
  /// **'Edit {kind}'**
  String editKindTitle(String kind);

  /// Warning banner on Password notes.
  ///
  /// In en, this message translates to:
  /// **'Saved without encryption. Anyone who can open this device or a backup file could read these entries.'**
  String get passwordsWarning;

  /// Search field.
  ///
  /// In en, this message translates to:
  /// **'Search websites and apps'**
  String get passwordsSearchHint;

  /// Form field.
  ///
  /// In en, this message translates to:
  /// **'Website or app name'**
  String get websiteNameLabel;

  /// Form field.
  ///
  /// In en, this message translates to:
  /// **'Website URL'**
  String get websiteUrlLabel;

  /// Form field.
  ///
  /// In en, this message translates to:
  /// **'Username or email'**
  String get usernameLabel;

  /// Form field.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// Adds a custom category chip.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newCategoryAction;

  /// Dialog title.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategoryTitle;

  /// Dialog field.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryNameHint;

  /// Confirm adding.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAction;

  /// Form field.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// Checkbox.
  ///
  /// In en, this message translates to:
  /// **'Add to favourites'**
  String get addToFavourites;

  /// Note at the bottom of the password form.
  ///
  /// In en, this message translates to:
  /// **'Saved without encryption on this device.'**
  String get savedUnencryptedNote;

  /// Copy button on a collapsed card.
  ///
  /// In en, this message translates to:
  /// **'Copy password for {name}'**
  String copyPasswordFor(String name);

  /// Empty list.
  ///
  /// In en, this message translates to:
  /// **'No password notes yet'**
  String get passwordsEmptyTitle;

  /// Empty list.
  ///
  /// In en, this message translates to:
  /// **'Tap + to save login details for a website or app.'**
  String get passwordsEmptyBody;

  /// Form title.
  ///
  /// In en, this message translates to:
  /// **'New password note'**
  String get newPasswordTitle;

  /// Form title.
  ///
  /// In en, this message translates to:
  /// **'Edit password note'**
  String get editPasswordTitle;

  /// FAB tooltip.
  ///
  /// In en, this message translates to:
  /// **'Add password note'**
  String get addPasswordNoteTooltip;

  /// Confirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete this password note?'**
  String get deletePasswordTitle;

  /// Snackbar.
  ///
  /// In en, this message translates to:
  /// **'Password note deleted'**
  String get passwordDeletedSnack;

  /// Screen-reader text for a masked value (ID number, password).
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get hiddenValueSemantics;

  /// Expiry line on an ID card row.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String idExpires(String date);

  /// Document category (PRD 7.3).
  ///
  /// In en, this message translates to:
  /// **'{category, select, personal{Personal} financial{Financial} medical{Medical} employment{Employment} educational{Educational} propertyVehicle{Property and vehicle} others{Others} other{}}'**
  String documentCategory(String category);

  /// Short category name for filter chips.
  ///
  /// In en, this message translates to:
  /// **'{category, select, personal{Personal} financial{Financial} medical{Medical} employment{Employment} educational{Educational} propertyVehicle{Property} others{Others} other{}}'**
  String documentCategoryShort(String category);

  /// Search field hint / tooltip.
  ///
  /// In en, this message translates to:
  /// **'Search documents'**
  String get documentsSearchHint;

  /// Documents app bar button.
  ///
  /// In en, this message translates to:
  /// **'Open Drive storage'**
  String get openDriveTooltip;

  /// FAB and add-form title.
  ///
  /// In en, this message translates to:
  /// **'Add document'**
  String get addDocumentAction;

  /// Form title when editing.
  ///
  /// In en, this message translates to:
  /// **'Edit document'**
  String get editDocumentTitle;

  /// Section heading over the document list.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get documentsRecent;

  /// Empty state title.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get documentsEmptyTitle;

  /// Empty state body.
  ///
  /// In en, this message translates to:
  /// **'Tap Add document to scan or pick a file. It\'s kept on this phone.'**
  String get documentsEmptyBody;

  /// Expiry banner title.
  ///
  /// In en, this message translates to:
  /// **'{title} expires {date}'**
  String documentExpiresOn(String title, String date);

  /// Days until a document expires.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Expires today} =1{1 day left} other{{count} days left}}'**
  String daysLeft(int count);

  /// Shown after the expiry date has passed.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get documentExpired;

  /// Expiry in the list row.
  ///
  /// In en, this message translates to:
  /// **'Exp. {date}'**
  String documentExpiryShort(String date);

  /// No Drive copy.
  ///
  /// In en, this message translates to:
  /// **'On this device only'**
  String get driveDeviceOnly;

  /// Drive upload in progress.
  ///
  /// In en, this message translates to:
  /// **'Uploading to Drive'**
  String get driveUploading;

  /// Uploaded to Drive.
  ///
  /// In en, this message translates to:
  /// **'Copy on Drive'**
  String get driveCopyOnDrive;

  /// Drive upload failed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get driveUploadFailed;

  /// Detail row label.
  ///
  /// In en, this message translates to:
  /// **'Google Drive'**
  String get driveLabel;

  /// Form button.
  ///
  /// In en, this message translates to:
  /// **'Scan with camera'**
  String get scanWithCamera;

  /// Form button.
  ///
  /// In en, this message translates to:
  /// **'Pick from files'**
  String get pickFromFiles;

  /// Form button once a file is chosen.
  ///
  /// In en, this message translates to:
  /// **'Replace file'**
  String get replaceFileAction;

  /// Under the chosen file name.
  ///
  /// In en, this message translates to:
  /// **'{size} · saved on this device'**
  String fileSavedOnDevice(String size);

  /// Error when saving without a file.
  ///
  /// In en, this message translates to:
  /// **'Scan or pick a file to add.'**
  String get documentFileRequired;

  /// Description hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. renewed copy, both pages'**
  String get documentDescriptionHint;

  /// Form/detail label.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get expiryDateLabel;

  /// Form checkbox.
  ///
  /// In en, this message translates to:
  /// **'Mark as favourite'**
  String get markFavourite;

  /// Switch for the expiry notification.
  ///
  /// In en, this message translates to:
  /// **'Remind me 30 days before'**
  String get expiryReminderLabel;

  /// Help under the expiry reminder switch.
  ///
  /// In en, this message translates to:
  /// **'A notification on this phone at 9:00, 30 days before it expires.'**
  String get expiryReminderHelp;

  /// Detail: reminder on.
  ///
  /// In en, this message translates to:
  /// **'Reminder 30 days before'**
  String get expiryReminderOn;

  /// Detail: reminder off.
  ///
  /// In en, this message translates to:
  /// **'No reminder'**
  String get expiryReminderOff;

  /// Open PDF/image preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewAction;

  /// Open Word/Excel files externally.
  ///
  /// In en, this message translates to:
  /// **'Open in another app'**
  String get openInOtherAppAction;

  /// Shown when the stored file can't be found.
  ///
  /// In en, this message translates to:
  /// **'The file is missing from this phone. Edit the document to add it again.'**
  String get documentFileMissing;

  /// Detail row label.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get documentFileLabel;

  /// Detail row label.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get documentAddedLabel;

  /// Confirm dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete this document?'**
  String get deleteDocumentTitle;

  /// Confirm dialog body.
  ///
  /// In en, this message translates to:
  /// **'The file will be removed from this phone. A copy on your Google Drive, if there is one, is not affected.'**
  String get deleteDocumentBody;

  /// Snackbar after delete.
  ///
  /// In en, this message translates to:
  /// **'Document deleted'**
  String get documentDeletedSnack;

  /// Expiry notification title.
  ///
  /// In en, this message translates to:
  /// **'{title} expires soon'**
  String documentExpiryNotificationTitle(String title);

  /// Expiry notification body.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Expires tomorrow.} other{Expires in {days} days.}} Tap to view it.'**
  String documentExpiryNotificationBody(int days);

  /// Section of documents linked to a personal-details entry.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get linkedDocumentsLabel;

  /// Opens the document picker.
  ///
  /// In en, this message translates to:
  /// **'Link document'**
  String get linkDocumentAction;

  /// Chip delete tooltip. The document itself is kept.
  ///
  /// In en, this message translates to:
  /// **'Remove link to {title}'**
  String unlinkDocumentTooltip(String title);

  /// Picker sheet title.
  ///
  /// In en, this message translates to:
  /// **'Choose a document'**
  String get chooseDocumentTitle;

  /// Picker empty state.
  ///
  /// In en, this message translates to:
  /// **'No documents to link. Add them in Documents first.'**
  String get noDocumentsToLink;

  /// Generic conflict error.
  ///
  /// In en, this message translates to:
  /// **'That can\'t be done right now. Please try again.'**
  String get errorConflict;

  /// Payment method.
  ///
  /// In en, this message translates to:
  /// **'{method, select, cash{Cash} upi{UPI} card{Card} other{Other}}'**
  String paymentMethod(String method);

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Start a new list'**
  String get shoppingStartNew;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Type items'**
  String get shoppingTypeItems;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Add them one by one'**
  String get shoppingTypeItemsHint;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Paste a message'**
  String get shoppingPasteMessage;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'From WhatsApp or SMS'**
  String get shoppingPasteMessageHint;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Send someone the \"how to send a list\" image'**
  String get shoppingShareInstructions;

  /// Text sent with the instruction image.
  ///
  /// In en, this message translates to:
  /// **'Please send me the shopping list like this 🙂'**
  String get shoppingShareText;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Saved lists'**
  String get shoppingSavedLists;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Previous lists'**
  String get shoppingPreviousLists;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Finished lists will appear here.'**
  String get shoppingHistoryEmpty;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String shoppingItemCount(int count);

  /// Marks a history row that has a receipt.
  ///
  /// In en, this message translates to:
  /// **'receipt'**
  String get shoppingReceiptTag;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get shoppingStartAction;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Reuse'**
  String get shoppingReuseAction;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Reuse this list'**
  String get shoppingReuseList;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get shoppingInProgress;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Paused · {when}'**
  String shoppingPausedAt(String when);

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String shoppingProgress(int done, int total);

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total}'**
  String shoppingProgressShort(int done, int total);

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Resume shopping'**
  String get shoppingResumeAction;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get shoppingFinishAction;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Finish shopping'**
  String get shoppingFinishShopping;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'A list is in progress'**
  String get shoppingInProgressTitle;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Finish or continue the list you\'re shopping for before starting another.'**
  String get shoppingInProgressBody;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Open it'**
  String get shoppingOpenCurrent;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get shoppingNewList;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Edit list'**
  String get shoppingEditList;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get shoppingListName;

  /// Default list name.
  ///
  /// In en, this message translates to:
  /// **'Shopping {date}'**
  String shoppingDefaultListName(String date);

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Copied from the {date} list — change anything before you start.'**
  String shoppingCopiedFrom(String date);

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Item · {count}'**
  String shoppingItemsHeader(int count);

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get shoppingQtyHeader;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get shoppingUnitHeader;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get shoppingQtyHint;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Add an item…'**
  String get shoppingAddItemHint;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get shoppingAddItemTooltip;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get shoppingAddItemAction;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Tip: paste several lines here and each becomes its own item.'**
  String get shoppingPasteTip;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Add at least one item.'**
  String get shoppingNoItemsError;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Start shopping'**
  String get shoppingStartShopping;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'List saved'**
  String get shoppingSavedSnack;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get shoppingItemNameLabel;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Quantity, required'**
  String get shoppingQuantityRequired;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String shoppingRemoveItem(String name);

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Import from message'**
  String get shoppingImportTitle;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Or paste or type it here'**
  String get shoppingOrTypeHere;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Milk 2\nBread 1\nRice 5 kg'**
  String get shoppingMessageExample;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Review items'**
  String get shoppingReviewAction;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Nothing to paste. Copy the message first, then tap Paste.'**
  String get shoppingClipboardEmpty;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Pasted message'**
  String get shoppingPastedMessage;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Paste again'**
  String get shoppingPasteAgain;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Review 1 item} other{Review {count} items}}'**
  String shoppingReviewCount(int count);

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'No items found in this message.'**
  String get shoppingNothingFound;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'{name} is listed {count} times.'**
  String shoppingDuplicate(String name, int count);

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'{name} is listed {count} times with different units. Check them.'**
  String shoppingDuplicateNoMerge(String name, int count);

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get shoppingMergeAction;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'No quantity found — enter one to confirm.'**
  String get shoppingNoQuantityFound;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Enter a number, like 2 or 1.5.'**
  String get shoppingQuantityInvalid;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Enter the item name.'**
  String get shoppingNameMissing;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Import 1 item} other{Import {count} items}}'**
  String shoppingImportItems(int count);

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Confirm 1 item to import} other{Confirm {count} items to import}}'**
  String shoppingConfirmToImport(int count);

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Only text you paste is read — the app never opens WhatsApp.'**
  String get shoppingPrivacyNote;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'To pick · {count}'**
  String shoppingToPick(int count);

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'In the cart · {count}'**
  String shoppingInCart(int count);

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get shoppingEditItem;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'No shopping in progress.'**
  String get shoppingNoSession;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Continue later'**
  String get shoppingContinueLater;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Keep shopping'**
  String get shoppingKeepShopping;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item still to pick} other{{count} items still to pick}}'**
  String shoppingLeaveTitle(int count);

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Continue later keeps this list and shows one notification with what\'s left. Finish saves it to history.'**
  String get shoppingLeaveBody;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Everything is picked'**
  String get shoppingAllPickedTitle;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Finish now to save the total to history?'**
  String get shoppingAllPickedBody;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Saved for later · 1 item left} other{Saved for later · {count} items left}}'**
  String shoppingPausedSnack(int count);

  /// Pending-items notification title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item left in {name}} other{{count} items left in {name}}}'**
  String shoppingNoticeTitle(int count, String name);

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The 1 item picked} other{All {count} items picked}}'**
  String shoppingAllItemsPicked(int count);

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} items picked'**
  String shoppingSomeItemsPicked(int done, int total);

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Edit purchase'**
  String get shoppingEditPurchase;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get shoppingTotalAmount;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount paid.'**
  String get shoppingTotalRequired;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get shoppingStore;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'e.g. neighbourhood supermarket'**
  String get shoppingStoreHint;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Paid with'**
  String get shoppingPaidWith;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get shoppingReceipt;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get shoppingReceiptPhoto;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get shoppingReceiptPdf;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Added once to Budget as an expense.'**
  String get shoppingBudgetNote;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Save to history'**
  String get shoppingSaveToHistory;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Saved to history'**
  String get shoppingSavedToHistory;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Delete this list?'**
  String get shoppingDeleteListTitle;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Its total is in Budget as an expense. Delete that expense too, or keep it?'**
  String get shoppingDeleteListBody;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Keep expense'**
  String get shoppingDeleteKeepExpense;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Delete both'**
  String get shoppingDeleteWithExpense;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'List deleted'**
  String get shoppingListDeleted;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get shoppingBought;

  /// Shopping.
  ///
  /// In en, this message translates to:
  /// **'Not bought'**
  String get shoppingNotBought;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above zero.'**
  String get amountRequired;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get remindMeLabel;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Remaining this month'**
  String get budgetRemaining;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Over budget by'**
  String get budgetOverBy;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Total budget'**
  String get totalBudget;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get totalSpent;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Edit budget'**
  String get editBudgetTooltip;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly budget to see what\'s left.'**
  String get budgetNotSet;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Set budget'**
  String get setBudgetAction;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get monthlyBudgetTitle;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesLabel;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month'**
  String get expensesEmpty;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Tap Add expense. Shopping totals are added automatically.'**
  String get expensesEmptyBody;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseUntitled;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'From shopping'**
  String get expenseFromShopping;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get expenseDeletedSnack;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpenseAction;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get editExpenseTitle;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Save expense'**
  String get saveExpenseAction;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Delete this expense?'**
  String get deleteExpenseTitle;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Leaves {left} of {budget} this month'**
  String expenseLeaves(String left, String budget);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Goes {over} over the {budget} budget this month'**
  String expenseGoesOver(String over, String budget);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Shopping totals are added here automatically when you finish a shopping trip — no need to enter them again.'**
  String get expenseShoppingNote;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Money lent'**
  String get moneyLentTab;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Money borrowed'**
  String get moneyBorrowedTab;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Total lent · pending'**
  String get totalLentPending;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Total borrowed · pending'**
  String get totalBorrowedPending;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing pending} =1{1 person} other{{count} people}}'**
  String lendingPeople(int count);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'next due {date}'**
  String lendingNextDue(String date);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Given {date}'**
  String lendingGivenOn(String date);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Borrowed {date}'**
  String lendingBorrowedOn(String date);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String lendingDueOn(String date);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Repaid {date}'**
  String lendingRepaidOn(String date);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Reminder {date}, {time}'**
  String lendingReminderAt(String date, String time);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'{status, select, pending{Pending} completed{Completed} other{}}'**
  String lendingStatus(String status);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Mark repaid'**
  String get markRepaidAction;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Mark paid back'**
  String get markPaidBackAction;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Add record'**
  String get addLendingRecord;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'No money lent'**
  String get lentEmpty;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'No money borrowed'**
  String get borrowedEmpty;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Tap Add record to note who owes what.'**
  String get lendingEmptyBody;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'New record'**
  String get newLendingTitle;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Edit record'**
  String get editLendingTitle;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'I lent money'**
  String get iLentMoney;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'I borrowed money'**
  String get iBorrowedMoney;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get personLabel;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Date given'**
  String get dateGivenLabel;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Date borrowed'**
  String get dateBorrowedLabel;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'The due date is before the date given.'**
  String get dueBeforeGivenError;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'e.g. for bike repair'**
  String get lendingNotesHint;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'On the due date, 9:00 AM'**
  String get lendingRemindHelp;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Delete this record?'**
  String get deleteLendingTitle;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Record deleted'**
  String get lendingDeletedSnack;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'{person} is due to repay you'**
  String lendingDueLentTitle(String person);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'{amount} is due today.'**
  String lendingDueLentBody(String amount);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Repay {person} today'**
  String lendingDueBorrowedTitle(String person);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'{amount} is due today.'**
  String lendingDueBorrowedBody(String amount);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Add medicine'**
  String get addMedicineAction;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Edit medicine'**
  String get editMedicineTitle;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Medicine name'**
  String get medicineNameLabel;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Reminder times'**
  String get reminderTimesLabel;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Add a time'**
  String get addTimeAction;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Add another time'**
  String get addAnotherTime;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Remove {time}'**
  String removeTimeTooltip(String time);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Add at least one time.'**
  String get medicineTimesRequired;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get medicineDaysLabel;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get medicineEveryDay;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Selected days'**
  String get medicineSelectedDays;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day.'**
  String get medicineDaysRequired;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'{first} – {last}'**
  String medicineDayRange(String first, String last);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Reminders on'**
  String get medicineRemindersOn;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Turn off to pause without deleting'**
  String get medicineRemindersOnHelp;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get medicinePaused;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =0{Next up · in {minutes} min} other{Next up · in {hours} h {minutes} min}}'**
  String medicineNextUp(int hours, int minutes);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'No medicine reminders'**
  String get medicineEmptyTitle;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Tap Add medicine to set reminder times.'**
  String get medicineEmptyBody;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Reminders only. This app gives no dosage or medical advice.'**
  String get medicineDisclaimer;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Delete this medicine?'**
  String get deleteMedicineTitle;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Medicine deleted'**
  String get medicineDeletedSnack;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Time for {name}'**
  String medicineNotificationTitle(String name);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Scheduled for {time}'**
  String medicineNotificationBody(String time);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Look away from the screen, relax your shoulders and follow the circle.'**
  String get breatheIntro;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Breathe in'**
  String get breatheIn;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Breathe out'**
  String get breatheOut;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get breatheReady;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get breathePaused;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Well done'**
  String get breatheDone;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'{remaining} remaining · {inhale} s in, {exhale} s out'**
  String breatheStatus(String remaining, int inhale, int exhale);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get breatheDuration;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String breatheMinutes(int count);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get breathePace;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'{inhale} s in · {exhale} s out'**
  String breathePaceLabel(int inhale, int exhale);

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Completion sound'**
  String get breatheSound;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get breatheVibration;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get breatheStart;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Start again'**
  String get breatheAgain;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get breathePause;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get breatheResume;

  /// Milestone 8.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get breatheStop;

  /// Generic done button.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneAction;

  /// Product name; do not translate.
  ///
  /// In en, this message translates to:
  /// **'Google Drive'**
  String get googleDrive;

  /// Tag on the password notes option.
  ///
  /// In en, this message translates to:
  /// **'Sensitive'**
  String get sensitiveTag;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Back up'**
  String get backupTab;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreTab;

  /// Backup category name.
  ///
  /// In en, this message translates to:
  /// **'{category, select, personal{Personal details} notes{Notes} documents{Documents with attachments} reminders{Reminders} tasks{Tasks and checklists} passwords{Password notes} shopping{Shopping lists, history & receipts} budget{Budget and expenses} lending{Lending and borrowing} medicine{Medicine schedules} preferences{App preferences} other{}}'**
  String backupCategory(String category);

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'No backup made on this phone yet.'**
  String get backupNever;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {date} · {size}'**
  String backupLast(String date, String size);

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Included by default'**
  String get backupIncludedByDefault;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get backupOptional;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Save to'**
  String get backupSaveTo;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'This phone (save or share the file)'**
  String get backupThisDevice;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Available once Google Drive is connected'**
  String get backupDriveLater;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Backup files are not encrypted. Anyone who gets the file can read its contents.'**
  String get backupUnencryptedWarning;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Backup files are not encrypted, and this one includes your password notes. Anyone who gets the file can read them. Keep it somewhere private.'**
  String get backupSensitiveWarning;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Choose what to back up} =1{Create backup · 1 category} other{Create backup · {count} categories}}'**
  String backupCreateCount(int count);

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Checking what to include…'**
  String get backupChecking;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Preparing the backup file…'**
  String get backupPreparing;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Create this backup?'**
  String get backupSummaryTitle;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String backupRecordCount(int count);

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'About {size}'**
  String backupEstimatedSize(String size);

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get backupCreateAction;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Backup ready · {size}'**
  String backupReady(String size);

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Save to this phone'**
  String get backupSaveToDevice;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Share…'**
  String get backupShare;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Send it to another app, e.g. Files or e-mail'**
  String get backupShareHint;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Backup saved · {size}'**
  String backupSaved(String size);

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'The backup couldn\'t be made. Nothing was saved.'**
  String get backupFailed;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'{problem, select, notABackup{This isn\'t a Personal Life Manager backup file.} damaged{This backup is damaged or incomplete. Nothing was restored.} tooNew{This backup was made by a newer version of the app. Update the app, then try again.} other{This file can\'t be used.}}'**
  String backupProblem(String problem);

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Choose a backup file. You can see what\'s in it and pick what to restore before anything changes.'**
  String get restoreIntro;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Choose backup file'**
  String get restoreChooseFile;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Restoring from Google Drive will be available once Drive is connected.'**
  String get restoreDriveLater;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Checking the backup…'**
  String get restoreChecking;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Restoring…'**
  String get restoreRestoring;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Can\'t use this file'**
  String get restoreCannotUse;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Backup from {date}'**
  String restoreBackupFrom(String date);

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'What to restore'**
  String get restoreChooseCategories;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'How'**
  String get restoreHow;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get restoreMerge;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get restoreReplace;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Adds what\'s missing and updates items where the backup has the newer version. Nothing on this phone is deleted.'**
  String get restoreMergeHelp;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Deletes what\'s on this phone in the chosen categories, then restores the backup\'s copy. Other categories aren\'t touched.'**
  String get restoreReplaceHelp;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Choose what to restore} =1{Restore 1 category} other{Restore {count} categories}}'**
  String restoreCount(int count);

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Restore from this backup?'**
  String get restoreMergeTitle;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Merge into: {categories}. Newer versions win; nothing is deleted.'**
  String restoreMergeBody(String categories);

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Replace this data?'**
  String get restoreReplaceTitle;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Everything currently on this phone in {categories} will be deleted and replaced with the backup. This can\'t be undone.'**
  String restoreReplaceBody(String categories);

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreAction;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get restoreReplaceAction;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'Restore finished. Reminders have been rescheduled.'**
  String get restoreDone;

  /// Backup and restore.
  ///
  /// In en, this message translates to:
  /// **'The restore stopped. The category being restored was left as it was.'**
  String get restoreFailed;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get settingsStorage;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Change app password'**
  String get changePasswordTitle;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Use at least {min} characters.'**
  String passwordTooShort(int min);

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Choose a password different from the current one.'**
  String get passwordSameAsCurrent;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'App password changed'**
  String get passwordChangedSnack;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, face{Face ID unlock} fingerprint{Fingerprint unlock} other{Biometric unlock}}'**
  String biometricUnlockSetting(String kind);

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock'**
  String get autoLockTitle;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'{option, select, immediately{As soon as you leave the app} after30s{After 30 seconds in background} after1min{After 1 minute in background} after5min{After 5 minutes in background} other{}}'**
  String autoLockOption(String option);

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Not connected · coming in a later update'**
  String get driveNotConnectedYet;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Last backup {date}'**
  String settingsLastBackup(String date);

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Allowed · exact alarms on'**
  String get notificationsStatusOn;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Allowed · may ring a few minutes late (tap to allow exact alarms)'**
  String get notificationsStatusInexact;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Off · reminders won\'t ring (tap to allow)'**
  String get notificationsStatusOff;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'{mode, select, system{System default} light{Light} dark{Dark} other{}}'**
  String themeOption(String mode);

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Budget period'**
  String get budgetPeriodTitle;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Monthly · starts on the 1st'**
  String get budgetPeriodCalendarMonth;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'App info'**
  String get appInfoTitle;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Version {version} · licences'**
  String appVersion(String version);

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Privacy & data storage'**
  String get privacyTitle;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on this phone'**
  String get privacyLocalTitle;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Your details, notes, documents and lists are stored only on this phone. The app works fully offline.'**
  String get privacyLocalBody;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'No servers, no account'**
  String get privacyNoServerTitle;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'There is no developer server or cloud database. Nothing is sent to the makers of this app.'**
  String get privacyNoServerBody;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Google Drive only when you choose'**
  String get privacyDriveTitle;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Copies go to your own Google Drive only when you upload or back up there yourself. Nothing syncs automatically.'**
  String get privacyDriveBody;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Not encrypted'**
  String get privacyEncryptionTitle;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Data, files and backups are not encrypted by the app. Anyone who can get into this phone or a backup file may be able to read them.'**
  String get privacyEncryptionBody;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'The app password controls access'**
  String get privacyPasswordTitle;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'It stops others opening the app; it does not encrypt your data. If you forget it, the only way back in is to erase everything on this phone.'**
  String get privacyPasswordBody;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Backups are files you control'**
  String get privacyBackupTitle;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'A backup is made only when you ask, and saved where you choose. Keep backup files somewhere private.'**
  String get privacyBackupBody;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Hidden from screenshots and the app switcher'**
  String get privacyScreenTitle;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Screens with passwords, ID numbers and document scans block screenshots, and the app\'s preview is hidden in the app switcher.'**
  String get privacyScreenBody;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'No tracking'**
  String get privacyAnalyticsTitle;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'No analytics, ads or crash reporting. Logs on the phone never contain your records.'**
  String get privacyAnalyticsBody;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordAction;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPasswordTitle;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'There is no server, so the password can\'t be recovered or reset. The only way back in is to erase everything and set the app up again.'**
  String get forgotPasswordBody;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Erase all data'**
  String get eraseTitle;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Everything in the app on this phone will be deleted: details, passwords, documents, notes, lists, reminders and settings. This can\'t be undone.'**
  String get eraseBody;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Backup files you saved elsewhere and copies on Google Drive are not touched. You can restore a backup after setting the app up again.'**
  String get eraseKeepsBackups;

  /// The word the user must type to confirm. Translate it, keep it short.
  ///
  /// In en, this message translates to:
  /// **'ERASE'**
  String get eraseConfirmWord;

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Type {word} to confirm'**
  String eraseTypeToConfirm(String word);

  /// Settings.
  ///
  /// In en, this message translates to:
  /// **'Erase everything'**
  String get eraseAction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
