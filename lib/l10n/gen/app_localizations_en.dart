// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Personal Life Manager';

  @override
  String get navHome => 'Home';

  @override
  String get navDocuments => 'Documents';

  @override
  String get navShopping => 'Shopping';

  @override
  String get navMore => 'More';

  @override
  String get sectionUnderConstruction => 'This section is coming soon.';

  @override
  String get startupFailed =>
      'The app couldn\'t open its local storage. Restart the app. If this keeps happening, check that your device has free storage space.';

  @override
  String get continueAction => 'Continue';

  @override
  String get lockAppAction => 'Lock app';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get secureStorageError =>
      'Couldn\'t reach this device\'s secure storage. Try again.';

  @override
  String setupStepLabel(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get setupWelcomeTitle => 'Welcome';

  @override
  String get setupWelcomeBody =>
      'Keep your personal details, documents, notes, reminders and everyday records in one place, on this phone.';

  @override
  String get setupPasswordTitle => 'Create your app password';

  @override
  String get setupPasswordSubtitle =>
      'You\'ll enter this each time you open the app.';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String passwordStrengthHint(String strength, int min) {
    String _temp0 = intl.Intl.selectLogic(strength, {
      'tooShort': 'Too short',
      'fair': 'Fair',
      'good': 'Good',
      'strong': 'Strong',
      'other': '',
    });
    return '$_temp0 · at least $min characters';
  }

  @override
  String passwordStrengthSemantics(String strength) {
    String _temp0 = intl.Intl.selectLogic(strength, {
      'tooShort': 'too short',
      'fair': 'fair',
      'good': 'good',
      'strong': 'strong',
      'other': '',
    });
    return 'Strength: $_temp0';
  }

  @override
  String get passwordsDoNotMatch => 'Passwords don\'t match';

  @override
  String get dataStorageTitle => 'How your data is stored';

  @override
  String get dataStorageLocal =>
      'Everything stays on this phone. We have no servers.';

  @override
  String get dataStorageDrive =>
      'Copies go to your own Google Drive only when you choose.';

  @override
  String get dataStorageNotEncrypted =>
      'Data, files and backups are not encrypted. The password only controls who opens the app.';

  @override
  String get dataStorageAcknowledge => 'I understand how my data is stored';

  @override
  String setupBiometricTitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'face': 'Unlock with Face ID?',
      'fingerprint': 'Unlock with fingerprint?',
      'other': 'Unlock with biometrics?',
    });
    return '$_temp0';
  }

  @override
  String get setupBiometricBody =>
      'It\'s quicker than typing your password. Your password always works too, and you can change this later in Settings.';

  @override
  String get setupBiometricEnable => 'Turn on';

  @override
  String get setupBiometricSkip => 'Not now';

  @override
  String get biometricReasonEnable =>
      'Confirm it\'s you to turn on biometric unlock';

  @override
  String get biometricReasonUnlock => 'Unlock Personal Life Manager';

  @override
  String get biometricFailed =>
      'Biometric check didn\'t work. Try again or use your password.';

  @override
  String get unlockSubtitle => 'Enter your app password to continue';

  @override
  String get appPasswordLabel => 'App password';

  @override
  String get unlockAction => 'Unlock';

  @override
  String get orDivider => 'or';

  @override
  String useBiometric(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'face': 'Use Face ID',
      'fingerprint': 'Use fingerprint',
      'other': 'Use biometrics',
    });
    return '$_temp0';
  }

  @override
  String get unlockInfo =>
      'Your data stays on this device. The app password controls access — it does not encrypt your data or files.';

  @override
  String wrongPassword(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wrong password. $count attempts left before a short wait.',
      one: 'Wrong password. 1 attempt left before a short wait.',
      zero: 'Wrong password.',
    );
    return '$_temp0';
  }

  @override
  String lockedOut(String time) {
    return 'Too many attempts. Try again in $time.';
  }

  @override
  String notificationChannelName(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'medicine': 'Medicine',
      'reminder': 'Reminders',
      'task': 'Tasks',
      'lending': 'Lending and borrowing',
      'documentExpiry': 'Document expiry',
      'shopping': 'Shopping',
      'other': 'Other',
    });
    return '$_temp0';
  }

  @override
  String notificationChannelDescription(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'medicine': 'Medicine schedule reminders',
      'reminder': 'Your reminders',
      'task': 'Task due-date reminders',
      'lending': 'Money lent and borrowed due dates',
      'documentExpiry': 'Documents that are about to expire',
      'shopping': 'Items left on a paused shopping list',
      'other': 'Other notifications',
    });
    return '$_temp0';
  }

  @override
  String notificationSnoozeAction(int minutes) {
    return 'Snooze $minutes min';
  }

  @override
  String get saveAction => 'Save';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get deleteAction => 'Delete';

  @override
  String get discardAction => 'Discard';

  @override
  String get keepEditingAction => 'Keep editing';

  @override
  String get removeAction => 'Remove';

  @override
  String get undoAction => 'Undo';

  @override
  String get seeAllAction => 'See all';

  @override
  String get clearAction => 'Clear';

  @override
  String get closeAction => 'Close';

  @override
  String get moreOptions => 'More options';

  @override
  String get optionalSuffix => '(optional)';

  @override
  String get fieldRequired => 'Required';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesBody => 'Your changes haven\'t been saved.';

  @override
  String get cannotUndoBody => 'This can\'t be undone.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNotFound => 'This item no longer exists.';

  @override
  String get errorUnsupportedFile =>
      'This file type isn\'t supported. Use PDF, JPG, PNG, Word or Excel files.';

  @override
  String errorFileTooLarge(int megabytes) {
    return 'This file is too large. The limit is $megabytes MB.';
  }

  @override
  String get errorFileStorage =>
      'Couldn\'t save the file on this phone. Check free space and try again.';

  @override
  String get errorNoAppToOpen => 'No app on this phone can open this file.';

  @override
  String get notificationsOffMessage =>
      'Notifications are off, so reminders won\'t ring.';

  @override
  String get openSettingsAction => 'Settings';

  @override
  String get exactAlarmsOffMessage =>
      'Reminders may ring a few minutes late. Allow exact alarms for on-time reminders.';

  @override
  String get allowAction => 'Allow';

  @override
  String get pickDateHint => 'Pick a date';

  @override
  String get pickTimeHint => 'Pick a time';

  @override
  String get timeInPastError => 'Pick a time in the future.';

  @override
  String moduleName(String module) {
    String _temp0 = intl.Intl.selectLogic(module, {
      'personal': 'Personal details',
      'passwords': 'Password notes',
      'documents': 'Documents',
      'notes': 'Notes',
      'tasks': 'Tasks',
      'reminders': 'Reminders',
      'shopping': 'Shopping',
      'budget': 'Budget',
      'lending': 'Lending and borrowing',
      'medicine': 'Medicine schedule',
      'breathe': 'Eye rest and breathing',
      'drive': 'Drive storage',
      'backup': 'Backup and restore',
      'settings': 'Settings',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String moduleShortName(String module) {
    String _temp0 = intl.Intl.selectLogic(module, {
      'personal': 'Personal',
      'passwords': 'Passwords',
      'documents': 'Documents',
      'notes': 'Notes',
      'tasks': 'Tasks',
      'reminders': 'Reminders',
      'shopping': 'Shopping',
      'budget': 'Budget',
      'lending': 'Lending',
      'medicine': 'Medicine',
      'breathe': 'Breathe',
      'drive': 'Drive',
      'backup': 'Backup',
      'settings': 'Settings',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get searchNotesTooltip => 'Search notes';

  @override
  String get quickAddNote => 'Note';

  @override
  String get quickAddTask => 'Task';

  @override
  String get quickAddReminder => 'Reminder';

  @override
  String get newNoteAction => 'New note';

  @override
  String get newTaskAction => 'New task';

  @override
  String get newReminderAction => 'New reminder';

  @override
  String get comingUpTitle => 'Coming up';

  @override
  String get comingUpEmpty =>
      'Nothing coming up. Reminders and tasks with dates appear here.';

  @override
  String get quickAccessTitle => 'Quick access';

  @override
  String upcomingLine(String kind, String when) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'medicine': 'Medicine',
      'reminder': 'Reminder',
      'task': 'Task',
      'lending': 'Lending',
      'documentExpiry': 'Expires',
      'other': '',
    });
    return '$_temp0 · $when';
  }

  @override
  String whenToday(String time) {
    return 'Today, $time';
  }

  @override
  String whenTomorrow(String time) {
    return 'Tomorrow, $time';
  }

  @override
  String whenYesterday(String time) {
    return 'Yesterday, $time';
  }

  @override
  String whenDateTime(String date, String time) {
    return '$date, $time';
  }

  @override
  String dueOn(String date) {
    return 'Due $date';
  }

  @override
  String get notesSearchHint => 'Search notes';

  @override
  String get notesFilterAll => 'All';

  @override
  String get notesFilterFavourites => 'Favourites';

  @override
  String get archivedNotesTitle => 'Archived notes';

  @override
  String get notesPinned => 'Pinned';

  @override
  String get notesOthers => 'Others';

  @override
  String get notesEmptyTitle => 'No notes yet';

  @override
  String get notesEmptyBody => 'Tap New note to write your first one.';

  @override
  String get notesNoResults => 'No notes match your search.';

  @override
  String get notesArchiveEmpty => 'No archived notes.';

  @override
  String noteEdited(String date) {
    return 'Edited $date';
  }

  @override
  String notePhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String noteFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '1 file',
    );
    return '$_temp0';
  }

  @override
  String get noteTitleHint => 'Title';

  @override
  String get noteBodyHint => 'Write something…';

  @override
  String get noteTagsLabel => 'Tags';

  @override
  String get noteTagHint => 'Add a tag, e.g. home';

  @override
  String removeTagTooltip(String tag) {
    return 'Remove tag $tag';
  }

  @override
  String get notePin => 'Pin';

  @override
  String get noteUnpin => 'Unpin';

  @override
  String get noteFavourite => 'Add to favourites';

  @override
  String get noteUnfavourite => 'Remove from favourites';

  @override
  String get noteArchive => 'Archive';

  @override
  String get noteUnarchive => 'Unarchive';

  @override
  String get noteArchivedSnack => 'Note archived';

  @override
  String get noteDeletedSnack => 'Note deleted';

  @override
  String get deleteNoteTitle => 'Delete this note?';

  @override
  String get deleteNoteBody =>
      'The note and its attachments will be removed from this phone. This can\'t be undone.';

  @override
  String get newNoteTitle => 'New note';

  @override
  String get editNoteTitle => 'Edit note';

  @override
  String get attachmentsLabel => 'Attachments';

  @override
  String get attachTakePhoto => 'Take photo';

  @override
  String get attachChoosePhoto => 'Choose photo';

  @override
  String get attachChooseFile => 'Choose file';

  @override
  String get addAttachmentAction => 'Add attachment';

  @override
  String get removeAttachmentTitle => 'Remove this attachment?';

  @override
  String removeAttachmentTooltip(String name) {
    return 'Remove $name';
  }

  @override
  String openAttachmentSemantics(String name) {
    return 'Open $name';
  }

  @override
  String tasksPendingTab(int count) {
    return 'Pending · $count';
  }

  @override
  String tasksCompletedTab(int count) {
    return 'Completed · $count';
  }

  @override
  String get tasksOverdue => 'Overdue';

  @override
  String get tasksUpcoming => 'Upcoming';

  @override
  String get taskNoDueDate => 'No due date';

  @override
  String taskMarkDone(String title) {
    return 'Mark $title done';
  }

  @override
  String taskMarkNotDone(String title) {
    return 'Mark $title not done';
  }

  @override
  String checklistProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String get tasksEmptyPending => 'No pending tasks';

  @override
  String get tasksEmptyPendingBody => 'Tap New task to add one.';

  @override
  String get tasksEmptyCompleted => 'No completed tasks yet.';

  @override
  String get tasksNoResults => 'No tasks match your search.';

  @override
  String get searchTasksHint => 'Search tasks';

  @override
  String get newTaskTitle => 'New task';

  @override
  String get editTaskTitle => 'Edit task';

  @override
  String get titleLabel => 'Title';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get dueDateLabel => 'Due date';

  @override
  String get reminderLabel => 'Reminder';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';

  @override
  String get checklistLabel => 'Checklist';

  @override
  String get addChecklistItem => 'Add item';

  @override
  String get checklistItemHint => 'Item';

  @override
  String get removeChecklistItem => 'Remove item';

  @override
  String get taskCompletedSnack => 'Task completed';

  @override
  String get taskDeletedSnack => 'Task deleted';

  @override
  String get deleteTaskTitle => 'Delete this task?';

  @override
  String remindersOverdue(int count) {
    return 'Overdue · $count';
  }

  @override
  String get remindersUpcoming => 'Upcoming';

  @override
  String get reminderMarkDone => 'Mark done';

  @override
  String get reminderSnoozeHour => 'Snooze 1 h';

  @override
  String get remindersOffline => 'Reminders ring even without internet.';

  @override
  String get remindersEmptyTitle => 'No reminders';

  @override
  String get remindersEmptyBody => 'Tap New reminder to add one.';

  @override
  String repeatName(String repeat) {
    String _temp0 = intl.Intl.selectLogic(repeat, {
      'none': 'Once',
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'yearly': 'Yearly',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get repeatSectionLabel => 'Repeat';

  @override
  String get repeatHelpOnce => 'Rings once.';

  @override
  String get repeatHelpDaily => 'Repeats every day.';

  @override
  String repeatHelpWeekly(String weekday) {
    return 'Repeats every $weekday.';
  }

  @override
  String repeatHelpMonthly(int day) {
    return 'Repeats on day $day of every month.';
  }

  @override
  String repeatHelpMonthlyEnd(int day) {
    return 'Repeats on day $day of every month, or the last day of shorter months.';
  }

  @override
  String repeatHelpYearly(String date) {
    return 'Repeats every year on $date.';
  }

  @override
  String get repeatHelpLeapDay =>
      'Repeats every year on 29 February, or 28 February in other years.';

  @override
  String get reminderFormInfo =>
      'You\'ll be notified on this phone, even offline. Snooze from the notification.';

  @override
  String get newReminderTitle => 'New reminder';

  @override
  String get editReminderTitle => 'Edit reminder';

  @override
  String get reminderDoneSnack => 'Marked done';

  @override
  String get reminderSnoozedSnack => 'Snoozed for 1 hour';

  @override
  String get reminderDeletedSnack => 'Reminder deleted';

  @override
  String get deleteReminderTitle => 'Delete this reminder?';

  @override
  String get moreTitle => 'More';

  @override
  String get filterAll => 'All';

  @override
  String get filterFavourites => 'Favourites';

  @override
  String get editAction => 'Edit';

  @override
  String get dismissAction => 'Dismiss';

  @override
  String get noMatches => 'No matches.';

  @override
  String copyTooltip(String label) {
    return 'Copy $label';
  }

  @override
  String copiedSnack(String label) {
    return '$label copied';
  }

  @override
  String copiedSensitiveSnack(String label) {
    return '$label copied. It will be cleared from the clipboard in 30 seconds.';
  }

  @override
  String showValueTooltip(String label) {
    return 'Show $label';
  }

  @override
  String hideValueTooltip(String label) {
    return 'Hide $label';
  }

  @override
  String detailCategory(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'personal': 'Personal',
      'family': 'Family',
      'identification': 'IDs',
      'additional': 'Work & more',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String detailKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'profile': 'Personal information',
      'familyMember': 'Family member',
      'aadhaar': 'Aadhaar',
      'pan': 'PAN',
      'passport': 'Passport',
      'drivingLicence': 'Driving licence',
      'voterId': 'Voter ID',
      'otherId': 'Other ID',
      'education': 'Education',
      'employment': 'Employment',
      'financial': 'Financial reference',
      'custom': 'Custom',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String detailField(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'fullName': 'Full name',
      'dateOfBirth': 'Date of birth',
      'phone': 'Phone number',
      'email': 'Email address',
      'currentAddress': 'Current address',
      'permanentAddress': 'Permanent address',
      'otherInfo': 'Other information',
      'relationship': 'Relationship',
      'address': 'Address',
      'emergencyContact': 'Emergency contact',
      'number': 'Number',
      'nameOnId': 'Name on ID',
      'expiryDate': 'Expiry date',
      'notes': 'Notes',
      'institution': 'Institution',
      'qualification': 'Qualification',
      'year': 'Year',
      'employer': 'Employer',
      'role': 'Role',
      'employeeId': 'Employee ID',
      'reference': 'Reference or account number',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String entryTitleLabel(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'familyMember': 'Name',
      'otherId': 'ID name',
      'financial': 'Name',
      'other': 'Title',
    });
    return '$_temp0';
  }

  @override
  String personalBorn(String date) {
    return 'Born $date';
  }

  @override
  String get profileEmptyTitle => 'Add your details';

  @override
  String get profileEmptyBody =>
      'Your name, date of birth, contact details and addresses.';

  @override
  String get editProfileTooltip => 'Edit personal information';

  @override
  String get addFamilyMember => 'Add member';

  @override
  String get addIdAction => 'Add ID';

  @override
  String get addEntryAction => 'Add entry';

  @override
  String get personalCardHint =>
      'Tap a card to see it in full and copy, edit or delete.';

  @override
  String get personalTabEmpty => 'Nothing saved here yet.';

  @override
  String get personalSearchHint => 'Search personal details';

  @override
  String get chooseTypeLabel => 'Type';

  @override
  String get customFieldsLabel => 'More fields';

  @override
  String get addCustomField => 'Add field';

  @override
  String get customFieldLabelHint => 'Label';

  @override
  String get customFieldValueHint => 'Value';

  @override
  String get removeFieldTooltip => 'Remove field';

  @override
  String get deleteEntryTitle => 'Delete this entry?';

  @override
  String get entryDeletedSnack => 'Deleted';

  @override
  String addKindTitle(String kind) {
    return 'Add $kind';
  }

  @override
  String editKindTitle(String kind) {
    return 'Edit $kind';
  }

  @override
  String get passwordsWarning =>
      'Saved without encryption. Anyone who can open this device or a backup file could read these entries.';

  @override
  String get passwordsSearchHint => 'Search websites and apps';

  @override
  String get websiteNameLabel => 'Website or app name';

  @override
  String get websiteUrlLabel => 'Website URL';

  @override
  String get usernameLabel => 'Username or email';

  @override
  String get categoryLabel => 'Category';

  @override
  String get newCategoryAction => 'New';

  @override
  String get newCategoryTitle => 'New category';

  @override
  String get categoryNameHint => 'Category name';

  @override
  String get addAction => 'Add';

  @override
  String get notesLabel => 'Notes';

  @override
  String get addToFavourites => 'Add to favourites';

  @override
  String get savedUnencryptedNote => 'Saved without encryption on this device.';

  @override
  String copyPasswordFor(String name) {
    return 'Copy password for $name';
  }

  @override
  String get passwordsEmptyTitle => 'No password notes yet';

  @override
  String get passwordsEmptyBody =>
      'Tap + to save login details for a website or app.';

  @override
  String get newPasswordTitle => 'New password note';

  @override
  String get editPasswordTitle => 'Edit password note';

  @override
  String get addPasswordNoteTooltip => 'Add password note';

  @override
  String get deletePasswordTitle => 'Delete this password note?';

  @override
  String get passwordDeletedSnack => 'Password note deleted';

  @override
  String get hiddenValueSemantics => 'Hidden';

  @override
  String idExpires(String date) {
    return 'Expires $date';
  }

  @override
  String documentCategory(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'personal': 'Personal',
      'financial': 'Financial',
      'medical': 'Medical',
      'employment': 'Employment',
      'educational': 'Educational',
      'propertyVehicle': 'Property and vehicle',
      'others': 'Others',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String documentCategoryShort(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'personal': 'Personal',
      'financial': 'Financial',
      'medical': 'Medical',
      'employment': 'Employment',
      'educational': 'Educational',
      'propertyVehicle': 'Property',
      'others': 'Others',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get documentsSearchHint => 'Search documents';

  @override
  String get openDriveTooltip => 'Open Drive storage';

  @override
  String get addDocumentAction => 'Add document';

  @override
  String get editDocumentTitle => 'Edit document';

  @override
  String get documentsRecent => 'Recent';

  @override
  String get documentsEmptyTitle => 'No documents yet';

  @override
  String get documentsEmptyBody =>
      'Tap Add document to scan or pick a file. It\'s kept on this phone.';

  @override
  String documentExpiresOn(String title, String date) {
    return '$title expires $date';
  }

  @override
  String daysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
      zero: 'Expires today',
    );
    return '$_temp0';
  }

  @override
  String get documentExpired => 'Expired';

  @override
  String documentExpiryShort(String date) {
    return 'Exp. $date';
  }

  @override
  String get driveDeviceOnly => 'On this device only';

  @override
  String get driveUploading => 'Uploading to Drive';

  @override
  String get driveCopyOnDrive => 'Copy on Drive';

  @override
  String get driveUploadFailed => 'Upload failed';

  @override
  String get driveLabel => 'Google Drive';

  @override
  String get scanWithCamera => 'Scan with camera';

  @override
  String get pickFromFiles => 'Pick from files';

  @override
  String get replaceFileAction => 'Replace file';

  @override
  String fileSavedOnDevice(String size) {
    return '$size · saved on this device';
  }

  @override
  String get documentFileRequired => 'Scan or pick a file to add.';

  @override
  String get documentDescriptionHint => 'e.g. renewed copy, both pages';

  @override
  String get expiryDateLabel => 'Expiry date';

  @override
  String get markFavourite => 'Mark as favourite';

  @override
  String get expiryReminderLabel => 'Remind me 30 days before';

  @override
  String get expiryReminderHelp =>
      'A notification on this phone at 9:00, 30 days before it expires.';

  @override
  String get expiryReminderOn => 'Reminder 30 days before';

  @override
  String get expiryReminderOff => 'No reminder';

  @override
  String get previewAction => 'Preview';

  @override
  String get openInOtherAppAction => 'Open in another app';

  @override
  String get documentFileMissing =>
      'The file is missing from this phone. Edit the document to add it again.';

  @override
  String get documentFileLabel => 'File';

  @override
  String get documentAddedLabel => 'Added';

  @override
  String get deleteDocumentTitle => 'Delete this document?';

  @override
  String get deleteDocumentBody =>
      'The file will be removed from this phone. A copy on your Google Drive, if there is one, is not affected.';

  @override
  String get documentDeletedSnack => 'Document deleted';

  @override
  String documentExpiryNotificationTitle(String title) {
    return '$title expires soon';
  }

  @override
  String documentExpiryNotificationBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Expires in $days days.',
      one: 'Expires tomorrow.',
    );
    return '$_temp0 Tap to view it.';
  }

  @override
  String get linkedDocumentsLabel => 'Documents';

  @override
  String get linkDocumentAction => 'Link document';

  @override
  String unlinkDocumentTooltip(String title) {
    return 'Remove link to $title';
  }

  @override
  String get chooseDocumentTitle => 'Choose a document';

  @override
  String get noDocumentsToLink =>
      'No documents to link. Add them in Documents first.';

  @override
  String get errorConflict =>
      'That can\'t be done right now. Please try again.';

  @override
  String paymentMethod(String method) {
    String _temp0 = intl.Intl.selectLogic(method, {
      'cash': 'Cash',
      'upi': 'UPI',
      'card': 'Card',
      'other': 'Other',
    });
    return '$_temp0';
  }

  @override
  String get shoppingStartNew => 'Start a new list';

  @override
  String get shoppingTypeItems => 'Type items';

  @override
  String get shoppingTypeItemsHint => 'Add them one by one';

  @override
  String get shoppingPasteMessage => 'Paste a message';

  @override
  String get shoppingPasteMessageHint => 'From WhatsApp or SMS';

  @override
  String get shoppingShareInstructions =>
      'Send someone the \"how to send a list\" image';

  @override
  String get shoppingShareText =>
      'Please send me the shopping list like this 🙂';

  @override
  String get shoppingSavedLists => 'Saved lists';

  @override
  String get shoppingPreviousLists => 'Previous lists';

  @override
  String get shoppingHistoryEmpty => 'Finished lists will appear here.';

  @override
  String shoppingItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get shoppingReceiptTag => 'receipt';

  @override
  String get shoppingStartAction => 'Start';

  @override
  String get shoppingReuseAction => 'Reuse';

  @override
  String get shoppingReuseList => 'Reuse this list';

  @override
  String get shoppingInProgress => 'In progress';

  @override
  String shoppingPausedAt(String when) {
    return 'Paused · $when';
  }

  @override
  String shoppingProgress(int done, int total) {
    return '$done of $total';
  }

  @override
  String shoppingProgressShort(int done, int total) {
    return '$done / $total';
  }

  @override
  String get shoppingResumeAction => 'Resume shopping';

  @override
  String get shoppingFinishAction => 'Finish';

  @override
  String get shoppingFinishShopping => 'Finish shopping';

  @override
  String get shoppingInProgressTitle => 'A list is in progress';

  @override
  String get shoppingInProgressBody =>
      'Finish or continue the list you\'re shopping for before starting another.';

  @override
  String get shoppingOpenCurrent => 'Open it';

  @override
  String get shoppingNewList => 'New list';

  @override
  String get shoppingEditList => 'Edit list';

  @override
  String get shoppingListName => 'List name';

  @override
  String shoppingDefaultListName(String date) {
    return 'Shopping $date';
  }

  @override
  String shoppingCopiedFrom(String date) {
    return 'Copied from the $date list — change anything before you start.';
  }

  @override
  String shoppingItemsHeader(int count) {
    return 'Item · $count';
  }

  @override
  String get shoppingQtyHeader => 'Qty';

  @override
  String get shoppingUnitHeader => 'Unit';

  @override
  String get shoppingQtyHint => 'Qty';

  @override
  String get shoppingAddItemHint => 'Add an item…';

  @override
  String get shoppingAddItemTooltip => 'Add item';

  @override
  String get shoppingAddItemAction => 'Add item';

  @override
  String get shoppingPasteTip =>
      'Tip: paste several lines here and each becomes its own item.';

  @override
  String get shoppingNoItemsError => 'Add at least one item.';

  @override
  String get shoppingStartShopping => 'Start shopping';

  @override
  String get shoppingSavedSnack => 'List saved';

  @override
  String get shoppingItemNameLabel => 'Item name';

  @override
  String get shoppingQuantityRequired => 'Quantity, required';

  @override
  String shoppingRemoveItem(String name) {
    return 'Remove $name';
  }

  @override
  String get shoppingImportTitle => 'Import from message';

  @override
  String get shoppingOrTypeHere => 'Or paste or type it here';

  @override
  String get shoppingMessageExample => 'Milk 2\nBread 1\nRice 5 kg';

  @override
  String get shoppingReviewAction => 'Review items';

  @override
  String get shoppingClipboardEmpty =>
      'Nothing to paste. Copy the message first, then tap Paste.';

  @override
  String get shoppingPastedMessage => 'Pasted message';

  @override
  String get shoppingPasteAgain => 'Paste again';

  @override
  String shoppingReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Review $count items',
      one: 'Review 1 item',
    );
    return '$_temp0';
  }

  @override
  String get shoppingNothingFound => 'No items found in this message.';

  @override
  String shoppingDuplicate(String name, int count) {
    return '$name is listed $count times.';
  }

  @override
  String shoppingDuplicateNoMerge(String name, int count) {
    return '$name is listed $count times with different units. Check them.';
  }

  @override
  String get shoppingMergeAction => 'Merge';

  @override
  String get shoppingNoQuantityFound =>
      'No quantity found — enter one to confirm.';

  @override
  String get shoppingQuantityInvalid => 'Enter a number, like 2 or 1.5.';

  @override
  String get shoppingNameMissing => 'Enter the item name.';

  @override
  String shoppingImportItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count items',
      one: 'Import 1 item',
    );
    return '$_temp0';
  }

  @override
  String shoppingConfirmToImport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Confirm $count items to import',
      one: 'Confirm 1 item to import',
    );
    return '$_temp0';
  }

  @override
  String get shoppingPrivacyNote =>
      'Only text you paste is read — the app never opens WhatsApp.';

  @override
  String shoppingToPick(int count) {
    return 'To pick · $count';
  }

  @override
  String shoppingInCart(int count) {
    return 'In the cart · $count';
  }

  @override
  String get shoppingEditItem => 'Edit item';

  @override
  String get shoppingNoSession => 'No shopping in progress.';

  @override
  String get shoppingContinueLater => 'Continue later';

  @override
  String get shoppingKeepShopping => 'Keep shopping';

  @override
  String shoppingLeaveTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items still to pick',
      one: '1 item still to pick',
    );
    return '$_temp0';
  }

  @override
  String get shoppingLeaveBody =>
      'Continue later keeps this list and shows one notification with what\'s left. Finish saves it to history.';

  @override
  String get shoppingAllPickedTitle => 'Everything is picked';

  @override
  String get shoppingAllPickedBody =>
      'Finish now to save the total to history?';

  @override
  String shoppingPausedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saved for later · $count items left',
      one: 'Saved for later · 1 item left',
    );
    return '$_temp0';
  }

  @override
  String shoppingNoticeTitle(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items left in $name',
      one: '1 item left in $name',
    );
    return '$_temp0';
  }

  @override
  String shoppingAllItemsPicked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'All $count items picked',
      one: 'The 1 item picked',
    );
    return '$_temp0';
  }

  @override
  String shoppingSomeItemsPicked(int done, int total) {
    return '$done of $total items picked';
  }

  @override
  String get shoppingEditPurchase => 'Edit purchase';

  @override
  String get shoppingTotalAmount => 'Total amount';

  @override
  String get shoppingTotalRequired => 'Enter the amount paid.';

  @override
  String get shoppingStore => 'Store';

  @override
  String get shoppingStoreHint => 'e.g. neighbourhood supermarket';

  @override
  String get shoppingPaidWith => 'Paid with';

  @override
  String get shoppingReceipt => 'Receipt';

  @override
  String get shoppingReceiptPhoto => 'Photo';

  @override
  String get shoppingReceiptPdf => 'PDF';

  @override
  String get shoppingBudgetNote => 'Added once to Budget as an expense.';

  @override
  String get shoppingSaveToHistory => 'Save to history';

  @override
  String get shoppingSavedToHistory => 'Saved to history';

  @override
  String get shoppingDeleteListTitle => 'Delete this list?';

  @override
  String get shoppingDeleteListBody =>
      'Its total is in Budget as an expense. Delete that expense too, or keep it?';

  @override
  String get shoppingDeleteKeepExpense => 'Keep expense';

  @override
  String get shoppingDeleteWithExpense => 'Delete both';

  @override
  String get shoppingListDeleted => 'List deleted';

  @override
  String get shoppingBought => 'Bought';

  @override
  String get shoppingNotBought => 'Not bought';

  @override
  String get amountLabel => 'Amount';

  @override
  String get amountRequired => 'Enter an amount above zero.';

  @override
  String get statusLabel => 'Status';

  @override
  String get remindMeLabel => 'Remind me';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get budgetRemaining => 'Remaining this month';

  @override
  String get budgetOverBy => 'Over budget by';

  @override
  String get totalBudget => 'Total budget';

  @override
  String get totalSpent => 'Total spent';

  @override
  String get editBudgetTooltip => 'Edit budget';

  @override
  String get budgetNotSet => 'Set a monthly budget to see what\'s left.';

  @override
  String get setBudgetAction => 'Set budget';

  @override
  String get monthlyBudgetTitle => 'Monthly budget';

  @override
  String get expensesLabel => 'Expenses';

  @override
  String get expensesEmpty => 'No expenses this month';

  @override
  String get expensesEmptyBody =>
      'Tap Add expense. Shopping totals are added automatically.';

  @override
  String get expenseUntitled => 'Expense';

  @override
  String get expenseFromShopping => 'From shopping';

  @override
  String get expenseDeletedSnack => 'Expense deleted';

  @override
  String get addExpenseAction => 'Add expense';

  @override
  String get editExpenseTitle => 'Edit expense';

  @override
  String get saveExpenseAction => 'Save expense';

  @override
  String get deleteExpenseTitle => 'Delete this expense?';

  @override
  String expenseLeaves(String left, String budget) {
    return 'Leaves $left of $budget this month';
  }

  @override
  String expenseGoesOver(String over, String budget) {
    return 'Goes $over over the $budget budget this month';
  }

  @override
  String get expenseShoppingNote =>
      'Shopping totals are added here automatically when you finish a shopping trip — no need to enter them again.';

  @override
  String get moneyLentTab => 'Money lent';

  @override
  String get moneyBorrowedTab => 'Money borrowed';

  @override
  String get totalLentPending => 'Total lent · pending';

  @override
  String get totalBorrowedPending => 'Total borrowed · pending';

  @override
  String lendingPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
      zero: 'Nothing pending',
    );
    return '$_temp0';
  }

  @override
  String lendingNextDue(String date) {
    return 'next due $date';
  }

  @override
  String lendingGivenOn(String date) {
    return 'Given $date';
  }

  @override
  String lendingBorrowedOn(String date) {
    return 'Borrowed $date';
  }

  @override
  String lendingDueOn(String date) {
    return 'Due $date';
  }

  @override
  String lendingRepaidOn(String date) {
    return 'Repaid $date';
  }

  @override
  String lendingReminderAt(String date, String time) {
    return 'Reminder $date, $time';
  }

  @override
  String lendingStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'pending': 'Pending',
      'completed': 'Completed',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get markRepaidAction => 'Mark repaid';

  @override
  String get markPaidBackAction => 'Mark paid back';

  @override
  String get addLendingRecord => 'Add record';

  @override
  String get lentEmpty => 'No money lent';

  @override
  String get borrowedEmpty => 'No money borrowed';

  @override
  String get lendingEmptyBody => 'Tap Add record to note who owes what.';

  @override
  String get newLendingTitle => 'New record';

  @override
  String get editLendingTitle => 'Edit record';

  @override
  String get iLentMoney => 'I lent money';

  @override
  String get iBorrowedMoney => 'I borrowed money';

  @override
  String get personLabel => 'Person';

  @override
  String get dateGivenLabel => 'Date given';

  @override
  String get dateBorrowedLabel => 'Date borrowed';

  @override
  String get dueBeforeGivenError => 'The due date is before the date given.';

  @override
  String get lendingNotesHint => 'e.g. for bike repair';

  @override
  String get lendingRemindHelp => 'On the due date, 9:00 AM';

  @override
  String get deleteLendingTitle => 'Delete this record?';

  @override
  String get lendingDeletedSnack => 'Record deleted';

  @override
  String lendingDueLentTitle(String person) {
    return '$person is due to repay you';
  }

  @override
  String lendingDueLentBody(String amount) {
    return '$amount is due today.';
  }

  @override
  String lendingDueBorrowedTitle(String person) {
    return 'Repay $person today';
  }

  @override
  String lendingDueBorrowedBody(String amount) {
    return '$amount is due today.';
  }

  @override
  String get addMedicineAction => 'Add medicine';

  @override
  String get editMedicineTitle => 'Edit medicine';

  @override
  String get medicineNameLabel => 'Medicine name';

  @override
  String get reminderTimesLabel => 'Reminder times';

  @override
  String get addTimeAction => 'Add a time';

  @override
  String get addAnotherTime => 'Add another time';

  @override
  String removeTimeTooltip(String time) {
    return 'Remove $time';
  }

  @override
  String get medicineTimesRequired => 'Add at least one time.';

  @override
  String get medicineDaysLabel => 'Days';

  @override
  String get medicineEveryDay => 'Every day';

  @override
  String get medicineSelectedDays => 'Selected days';

  @override
  String get medicineDaysRequired => 'Pick at least one day.';

  @override
  String medicineDayRange(String first, String last) {
    return '$first – $last';
  }

  @override
  String get medicineRemindersOn => 'Reminders on';

  @override
  String get medicineRemindersOnHelp => 'Turn off to pause without deleting';

  @override
  String get medicinePaused => 'Paused';

  @override
  String medicineNextUp(int hours, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Next up · in $hours h $minutes min',
      zero: 'Next up · in $minutes min',
    );
    return '$_temp0';
  }

  @override
  String get medicineEmptyTitle => 'No medicine reminders';

  @override
  String get medicineEmptyBody => 'Tap Add medicine to set reminder times.';

  @override
  String get medicineDisclaimer =>
      'Reminders only. This app gives no dosage or medical advice.';

  @override
  String get deleteMedicineTitle => 'Delete this medicine?';

  @override
  String get medicineDeletedSnack => 'Medicine deleted';

  @override
  String medicineNotificationTitle(String name) {
    return 'Time for $name';
  }

  @override
  String medicineNotificationBody(String time) {
    return 'Scheduled for $time';
  }

  @override
  String get breatheIntro =>
      'Look away from the screen, relax your shoulders and follow the circle.';

  @override
  String get breatheIn => 'Breathe in';

  @override
  String get breatheOut => 'Breathe out';

  @override
  String get breatheReady => 'Ready';

  @override
  String get breathePaused => 'Paused';

  @override
  String get breatheDone => 'Well done';

  @override
  String breatheStatus(String remaining, int inhale, int exhale) {
    return '$remaining remaining · $inhale s in, $exhale s out';
  }

  @override
  String get breatheDuration => 'Duration';

  @override
  String breatheMinutes(int count) {
    return '$count min';
  }

  @override
  String get breathePace => 'Pace';

  @override
  String breathePaceLabel(int inhale, int exhale) {
    return '$inhale s in · $exhale s out';
  }

  @override
  String get breatheSound => 'Completion sound';

  @override
  String get breatheVibration => 'Vibration';

  @override
  String get breatheStart => 'Start';

  @override
  String get breatheAgain => 'Start again';

  @override
  String get breathePause => 'Pause';

  @override
  String get breatheResume => 'Resume';

  @override
  String get breatheStop => 'Stop';

  @override
  String get doneAction => 'Done';

  @override
  String get googleDrive => 'Google Drive';

  @override
  String get sensitiveTag => 'Sensitive';

  @override
  String get backupTab => 'Back up';

  @override
  String get restoreTab => 'Restore';

  @override
  String backupCategory(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'personal': 'Personal details',
      'notes': 'Notes',
      'documents': 'Documents with attachments',
      'reminders': 'Reminders',
      'tasks': 'Tasks and checklists',
      'passwords': 'Password notes',
      'shopping': 'Shopping lists, history & receipts',
      'budget': 'Budget and expenses',
      'lending': 'Lending and borrowing',
      'medicine': 'Medicine schedules',
      'preferences': 'App preferences',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get backupNever => 'No backup made on this phone yet.';

  @override
  String backupLast(String date, String size) {
    return 'Last backup: $date · $size';
  }

  @override
  String get backupIncludedByDefault => 'Included by default';

  @override
  String get backupOptional => 'Optional';

  @override
  String get backupSaveTo => 'Save to';

  @override
  String get backupThisDevice => 'This phone (save or share the file)';

  @override
  String get backupDriveLater => 'Available once Google Drive is connected';

  @override
  String get backupUnencryptedWarning =>
      'Backup files are not encrypted. Anyone who gets the file can read its contents.';

  @override
  String get backupSensitiveWarning =>
      'Backup files are not encrypted, and this one includes your password notes. Anyone who gets the file can read them. Keep it somewhere private.';

  @override
  String backupCreateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Create backup · $count categories',
      one: 'Create backup · 1 category',
      zero: 'Choose what to back up',
    );
    return '$_temp0';
  }

  @override
  String get backupChecking => 'Checking what to include…';

  @override
  String get backupPreparing => 'Preparing the backup file…';

  @override
  String get backupSummaryTitle => 'Create this backup?';

  @override
  String backupRecordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String backupEstimatedSize(String size) {
    return 'About $size';
  }

  @override
  String get backupCreateAction => 'Create backup';

  @override
  String backupReady(String size) {
    return 'Backup ready · $size';
  }

  @override
  String get backupSaveToDevice => 'Save to this phone';

  @override
  String get backupShare => 'Share…';

  @override
  String get backupShareHint => 'Send it to another app, e.g. Files or e-mail';

  @override
  String backupSaved(String size) {
    return 'Backup saved · $size';
  }

  @override
  String get backupFailed => 'The backup couldn\'t be made. Nothing was saved.';

  @override
  String backupProblem(String problem) {
    String _temp0 = intl.Intl.selectLogic(problem, {
      'notABackup': 'This isn\'t a Personal Life Manager backup file.',
      'damaged': 'This backup is damaged or incomplete. Nothing was restored.',
      'tooNew': 'This backup was made by a newer version of the app. Update the app, then try again.',
      'other': 'This file can\'t be used.',
    });
    return '$_temp0';
  }

  @override
  String get restoreIntro =>
      'Choose a backup file. You can see what\'s in it and pick what to restore before anything changes.';

  @override
  String get restoreChooseFile => 'Choose backup file';

  @override
  String get restoreDriveLater =>
      'Restoring from Google Drive will be available once Drive is connected.';

  @override
  String get restoreChecking => 'Checking the backup…';

  @override
  String get restoreRestoring => 'Restoring…';

  @override
  String get restoreCannotUse => 'Can\'t use this file';

  @override
  String restoreBackupFrom(String date) {
    return 'Backup from $date';
  }

  @override
  String get restoreChooseCategories => 'What to restore';

  @override
  String get restoreHow => 'How';

  @override
  String get restoreMerge => 'Merge';

  @override
  String get restoreReplace => 'Replace';

  @override
  String get restoreMergeHelp =>
      'Adds what\'s missing and updates items where the backup has the newer version. Nothing on this phone is deleted.';

  @override
  String get restoreReplaceHelp =>
      'Deletes what\'s on this phone in the chosen categories, then restores the backup\'s copy. Other categories aren\'t touched.';

  @override
  String restoreCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Restore $count categories',
      one: 'Restore 1 category',
      zero: 'Choose what to restore',
    );
    return '$_temp0';
  }

  @override
  String get restoreMergeTitle => 'Restore from this backup?';

  @override
  String restoreMergeBody(String categories) {
    return 'Merge into: $categories. Newer versions win; nothing is deleted.';
  }

  @override
  String get restoreReplaceTitle => 'Replace this data?';

  @override
  String restoreReplaceBody(String categories) {
    return 'Everything currently on this phone in $categories will be deleted and replaced with the backup. This can\'t be undone.';
  }

  @override
  String get restoreAction => 'Restore';

  @override
  String get restoreReplaceAction => 'Replace';

  @override
  String get restoreDone =>
      'Restore finished. Reminders have been rescheduled.';

  @override
  String get restoreFailed =>
      'The restore stopped. The category being restored was left as it was.';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsStorage => 'Storage';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsAbout => 'About';

  @override
  String get changePasswordTitle => 'Change app password';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String passwordTooShort(int min) {
    return 'Use at least $min characters.';
  }

  @override
  String get passwordSameAsCurrent =>
      'Choose a password different from the current one.';

  @override
  String get passwordChangedSnack => 'App password changed';

  @override
  String biometricUnlockSetting(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'face': 'Face ID unlock',
      'fingerprint': 'Fingerprint unlock',
      'other': 'Biometric unlock',
    });
    return '$_temp0';
  }

  @override
  String get autoLockTitle => 'Auto-lock';

  @override
  String autoLockOption(String option) {
    String _temp0 = intl.Intl.selectLogic(option, {
      'immediately': 'As soon as you leave the app',
      'after30s': 'After 30 seconds in background',
      'after1min': 'After 1 minute in background',
      'after5min': 'After 5 minutes in background',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get driveNotConnectedYet => 'Not connected · coming in a later update';

  @override
  String settingsLastBackup(String date) {
    return 'Last backup $date';
  }

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get notificationsStatusOn => 'Allowed · exact alarms on';

  @override
  String get notificationsStatusInexact =>
      'Allowed · may ring a few minutes late (tap to allow exact alarms)';

  @override
  String get notificationsStatusOff =>
      'Off · reminders won\'t ring (tap to allow)';

  @override
  String get themeTitle => 'Theme';

  @override
  String themeOption(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'system': 'System default',
      'light': 'Light',
      'dark': 'Dark',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get budgetPeriodTitle => 'Budget period';

  @override
  String get budgetPeriodCalendarMonth => 'Monthly · starts on the 1st';

  @override
  String get appInfoTitle => 'App info';

  @override
  String appVersion(String version) {
    return 'Version $version · licences';
  }

  @override
  String get privacyTitle => 'Privacy & data storage';

  @override
  String get privacyLocalTitle => 'Everything stays on this phone';

  @override
  String get privacyLocalBody =>
      'Your details, notes, documents and lists are stored only on this phone. The app works fully offline.';

  @override
  String get privacyNoServerTitle => 'No servers, no account';

  @override
  String get privacyNoServerBody =>
      'There is no developer server or cloud database. Nothing is sent to the makers of this app.';

  @override
  String get privacyDriveTitle => 'Google Drive only when you choose';

  @override
  String get privacyDriveBody =>
      'Copies go to your own Google Drive only when you upload or back up there yourself. Nothing syncs automatically.';

  @override
  String get privacyEncryptionTitle => 'Not encrypted';

  @override
  String get privacyEncryptionBody =>
      'Data, files and backups are not encrypted by the app. Anyone who can get into this phone or a backup file may be able to read them.';

  @override
  String get privacyPasswordTitle => 'The app password controls access';

  @override
  String get privacyPasswordBody =>
      'It stops others opening the app; it does not encrypt your data. If you forget it, the only way back in is to erase everything on this phone.';

  @override
  String get privacyBackupTitle => 'Backups are files you control';

  @override
  String get privacyBackupBody =>
      'A backup is made only when you ask, and saved where you choose. Keep backup files somewhere private.';

  @override
  String get privacyScreenTitle =>
      'Hidden from screenshots and the app switcher';

  @override
  String get privacyScreenBody =>
      'Screens with passwords, ID numbers and document scans block screenshots, and the app\'s preview is hidden in the app switcher.';

  @override
  String get privacyAnalyticsTitle => 'No tracking';

  @override
  String get privacyAnalyticsBody =>
      'No analytics, ads or crash reporting. Logs on the phone never contain your records.';

  @override
  String get forgotPasswordAction => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Forgot your password?';

  @override
  String get forgotPasswordBody =>
      'There is no server, so the password can\'t be recovered or reset. The only way back in is to erase everything and set the app up again.';

  @override
  String get eraseTitle => 'Erase all data';

  @override
  String get eraseBody =>
      'Everything in the app on this phone will be deleted: details, passwords, documents, notes, lists, reminders and settings. This can\'t be undone.';

  @override
  String get eraseKeepsBackups =>
      'Backup files you saved elsewhere and copies on Google Drive are not touched. You can restore a backup after setting the app up again.';

  @override
  String get eraseConfirmWord => 'ERASE';

  @override
  String eraseTypeToConfirm(String word) {
    return 'Type $word to confirm';
  }

  @override
  String get eraseAction => 'Erase everything';
}
