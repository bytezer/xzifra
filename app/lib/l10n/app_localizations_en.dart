// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Xzifra';

  @override
  String get navHome => 'Home';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get navRecords => 'Records';

  @override
  String get navReports => 'Reports';

  @override
  String get navSettings => 'Settings';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionSave => 'Save';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionRestore => 'Restore';

  @override
  String get actionMoveUp => 'Move up';

  @override
  String get actionMoveDown => 'Move down';

  @override
  String get actionArchive => 'Archive';

  @override
  String get actionDuplicate => 'Duplicate';

  @override
  String get actionSearch => 'Search';

  @override
  String get labelNone => 'None';

  @override
  String get labelOptional => 'Optional';

  @override
  String get labelUnknownCategory => 'Unknown category';

  @override
  String get labelNoPaymentMethod => 'No payment method';

  @override
  String get labelArchived => 'Archived';

  @override
  String get categoryArchived => 'Archived';

  @override
  String get paymentMethodArchived => 'Archived';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tooltipPreviousMonth => 'Previous month';

  @override
  String get tooltipNextMonth => 'Next month';

  @override
  String get tooltipAddExpense => 'Add expense';

  @override
  String get tooltipQuickAdd => 'Quick add';

  @override
  String get quickAddExpense => 'Expense';

  @override
  String get quickAddNote => 'Note';

  @override
  String get quickAddBookmark => 'Bookmark';

  @override
  String get quickAddReminder => 'Reminder';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get tagsHint => 'Separate tags with commas';

  @override
  String get tagsAll => 'All tags';

  @override
  String get shortcutNewExpense => 'New expense';

  @override
  String get shortcutReports => 'Reports';

  @override
  String get widgetEmptyMessage => 'Open Xzifra to see this month';

  @override
  String get dashboardSpentThisMonth => 'Spent this month';

  @override
  String get dashboardTopCategories => 'Top categories';

  @override
  String get dashboardRecentExpenses => 'Recent expenses';

  @override
  String get dashboardViewAll => 'View all';

  @override
  String get dashboardRepeatLast => 'Repeat last';

  @override
  String get dashboardNoExpensesTitle => 'No expenses this month';

  @override
  String get dashboardNoExpensesMessage =>
      'Add your first expense to see the breakdown.';

  @override
  String get dashboardAddExpense => 'Add expense';

  @override
  String get dashboardNothingRecordedTitle => 'Nothing recorded yet';

  @override
  String get dashboardNothingRecordedMessage =>
      'Your latest expenses will show up here.';

  @override
  String get dashboardLoadingPrevious => 'Loading previous month…';

  @override
  String get dashboardNoSpendingLastMonth => 'No spending recorded last month';

  @override
  String get dashboardNoSpendingYet => 'No spending recorded yet';

  @override
  String get dashboardSameAsLastMonth => 'Same as last month';

  @override
  String dashboardIncreased(String percent) {
    return '+$percent% vs last month';
  }

  @override
  String dashboardDecreased(String percent) {
    return '−$percent% vs last month';
  }

  @override
  String get dashboardRecentNotes => 'Recent notes';

  @override
  String get dashboardBookmarks => 'Bookmarks';

  @override
  String get dashboardNothingNotesTitle => 'No notes yet';

  @override
  String get dashboardNothingNotesMessage =>
      'Capture something and it will show up here.';

  @override
  String get dashboardNothingBookmarksTitle => 'No bookmarks yet';

  @override
  String get dashboardNothingBookmarksMessage =>
      'Save links to find them here.';

  @override
  String get dashboardAddNote => 'Add note';

  @override
  String get dashboardAddBookmark => 'Add bookmark';

  @override
  String get expensesTitle => 'Expenses';

  @override
  String get expensesFilterCategory => 'Category';

  @override
  String get expensesFilterPayment => 'Payment';

  @override
  String get expensesNoMatchesTitle => 'No matches';

  @override
  String get expensesNoMatchesMessage =>
      'Try a different category or payment method.';

  @override
  String get expensesEmptyTitle => 'No expenses this month';

  @override
  String get expensesEmptyMessage => 'Tap the + button to record one.';

  @override
  String get expensesClearFilters => 'Clear filters';

  @override
  String get expensesFilterByCategory => 'Filter by category';

  @override
  String get expensesFilterByPayment => 'Filter by payment method';

  @override
  String get expensesAllCategories => 'All categories';

  @override
  String get expensesAllPaymentMethods => 'All payment methods';

  @override
  String get expensesDeleteTitle => 'Delete expense?';

  @override
  String expensesDeleted(String category) {
    return 'Deleted $category expense';
  }

  @override
  String get notesTitle => 'Notes';

  @override
  String get notesEmptyTitle => 'No notes yet';

  @override
  String get notesEmptyMessage =>
      'Capture an idea, a list or a quote. It stays on this device.';

  @override
  String get notesNoMatchesTitle => 'No matches';

  @override
  String get notesNoMatchesMessage => 'Try a different tag.';

  @override
  String get notesNewTitle => 'New note';

  @override
  String get notesEditTitle => 'Edit note';

  @override
  String get notesNotFound => 'Note not found.';

  @override
  String get notesLoadError => 'Could not load this note.';

  @override
  String get notesTitleLabel => 'Title';

  @override
  String get notesBodyLabel => 'Body';

  @override
  String get notesBodyHint => 'Write in plain text or Markdown';

  @override
  String get notesTitleError => 'Enter a title.';

  @override
  String get notesSaveError => 'Could not save the note. Please try again.';

  @override
  String get notesDeleted => 'Note deleted';

  @override
  String get notesPinned => 'Pinned';

  @override
  String get notesPin => 'Pin note';

  @override
  String get notesUnpin => 'Unpin note';

  @override
  String get notesArchive => 'Archive note';

  @override
  String get notesUnarchive => 'Unarchive note';

  @override
  String get notesArchived => 'Archived';

  @override
  String get notesDeleteTitle => 'Delete note?';

  @override
  String notesDeleteMessage(String title) {
    return 'Delete \"$title\"? This cannot be undone.';
  }

  @override
  String get notesExportMarkdown => 'Export as Markdown';

  @override
  String get notesExportAll => 'Export all notes (ZIP)';

  @override
  String get notesExportError => 'Could not export the note.';

  @override
  String get notesExportAllError => 'Could not export the notes.';

  @override
  String get bookmarksTitle => 'Bookmarks';

  @override
  String get bookmarksEmptyTitle => 'No bookmarks yet';

  @override
  String get bookmarksEmptyMessage => 'Save links you want to come back to.';

  @override
  String get bookmarksNewTitle => 'New bookmark';

  @override
  String get bookmarksEditTitle => 'Edit bookmark';

  @override
  String get bookmarksNotFound => 'Bookmark not found.';

  @override
  String get bookmarksLoadError => 'Could not load this bookmark.';

  @override
  String get bookmarksUrlLabel => 'URL';

  @override
  String get bookmarksUrlError => 'Enter a valid http or https link.';

  @override
  String get bookmarksTitleLabel => 'Title';

  @override
  String get bookmarksTitleHelp => 'Leave it empty to use the domain';

  @override
  String get bookmarksNoteLabel => 'Note';

  @override
  String get bookmarksSaveError =>
      'Could not save the bookmark. Please try again.';

  @override
  String get bookmarksDeleted => 'Bookmark deleted';

  @override
  String get bookmarksArchive => 'Archive bookmark';

  @override
  String get bookmarksUnarchive => 'Unarchive bookmark';

  @override
  String get bookmarksArchived => 'Archived';

  @override
  String get bookmarksDeleteTitle => 'Delete bookmark?';

  @override
  String bookmarksDeleteMessage(String title) {
    return 'Delete \"$title\"? This cannot be undone.';
  }

  @override
  String get bookmarksOpenError => 'Could not open this link.';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search expenses, notes and bookmarks';

  @override
  String get searchEmptyMessage =>
      'Find expenses, notes and bookmarks on this device.';

  @override
  String get searchNoResultsTitle => 'No results';

  @override
  String get searchNoResultsMessage =>
      'Try another word or check the spelling.';

  @override
  String get searchExpenses => 'Expenses';

  @override
  String get searchNotes => 'Notes';

  @override
  String get searchBookmarks => 'Bookmarks';

  @override
  String get expenseNewTitle => 'New expense';

  @override
  String get expenseEditTitle => 'Edit expense';

  @override
  String get expenseDuplicateTitle => 'Duplicate expense';

  @override
  String get expenseAmount => 'Amount';

  @override
  String get expenseCurrency => 'Currency';

  @override
  String get expenseCategory => 'Category';

  @override
  String get expensePaymentMethod => 'Payment method';

  @override
  String get expenseDate => 'Date';

  @override
  String get expenseNote => 'Note';

  @override
  String get expenseSave => 'Save expense';

  @override
  String get expenseSaveChanges => 'Save changes';

  @override
  String get expenseSaveAndAddAnother => 'Save & add another';

  @override
  String get expenseSavedAnother => 'Expense saved. Add another.';

  @override
  String get expenseAmountError => 'Enter an amount greater than zero.';

  @override
  String get expenseCategoryError => 'Choose a category.';

  @override
  String get expenseSaveError =>
      'Could not save the expense. Please try again.';

  @override
  String get expenseNoCategories => 'No categories yet. Add one in Settings.';

  @override
  String get expenseNotFound => 'Expense not found.';

  @override
  String get expenseLoadError => 'Could not load this expense.';

  @override
  String get expenseDateHelp => 'Expense date';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsByCategory => 'By category';

  @override
  String get reportsNoDataTitle => 'No data for this month';

  @override
  String get reportsNoDataMessage => 'Record an expense to see the breakdown.';

  @override
  String get reportsTotal => 'Total';

  @override
  String get reportsLast12Months => 'Last 12 months';

  @override
  String get reportsByPaymentMethod => 'By payment method';

  @override
  String get reportsNoPaymentDataMessage =>
      'Payment methods will show up here.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeMode => 'Theme mode';

  @override
  String get settingsThemeModeFixed => 'Dark (fixed by Cyber Red)';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystemDescription => 'Follow the device setting';

  @override
  String get settingsThemeLightDescription => 'Always use the light theme';

  @override
  String get settingsThemeDarkDescription => 'Always use the dark theme';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsDefaultCurrency => 'Default currency';

  @override
  String get settingsCurrencyPEN => 'Soles (PEN)';

  @override
  String get settingsCurrencyUSD => 'Dollars (USD)';

  @override
  String get settingsManage => 'Manage';

  @override
  String get settingsCategories => 'Categories';

  @override
  String get settingsCategoriesSubtitle => 'Create, edit, reorder or archive';

  @override
  String get settingsPaymentMethods => 'Payment methods';

  @override
  String get settingsPaymentMethodsSubtitle =>
      'Create your own list with a name and emoji';

  @override
  String get settingsTemplates => 'Templates';

  @override
  String get settingsTemplatesSubtitle =>
      'Save frequent expenses for quick entry';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get settingsExportJson => 'Export JSON backup';

  @override
  String get settingsExportJsonSubtitle =>
      'Records and data only. Use the full backup to include attachments.';

  @override
  String get settingsExportCsv => 'Export CSV';

  @override
  String get settingsExportCsvSubtitle => 'Open your expenses in a spreadsheet';

  @override
  String get settingsImportJson => 'Import JSON backup';

  @override
  String get settingsImportJsonSubtitle => 'Merge a backup into this device';

  @override
  String get settingsAbout => 'About Xzifra';

  @override
  String get settingsAboutSubtitle => 'Version, source code and licenses';

  @override
  String get settingsExportError => 'Could not export the backup.';

  @override
  String get settingsCsvError => 'Could not export the CSV.';

  @override
  String settingsImportProcessed(
    int total,
    int expenses,
    int notes,
    int bookmarks,
    int recurring,
    int reminders,
  ) {
    return 'Processed $total records ($expenses expenses, $notes notes, $bookmarks bookmarks, $recurring recurring, $reminders reminders).';
  }

  @override
  String get settingsImportError => 'Could not import this backup.';

  @override
  String get settingsImportInvalid => 'This file is not an Xzifra backup.';

  @override
  String get themeIndigo => 'Indigo';

  @override
  String get themeIndigoDescription =>
      'Calm indigo accents on Material 3 surfaces.';

  @override
  String get themeCyberRed => 'Cyber Red';

  @override
  String get themeCyberRedDescription =>
      'Black surfaces with neon red accents.';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get categoriesNewTitle => 'New category';

  @override
  String get categoriesEditTitle => 'Edit category';

  @override
  String get categoriesName => 'Name';

  @override
  String get categoriesIcon => 'Icon';

  @override
  String get categoriesColor => 'Color';

  @override
  String get categoriesArchiveDialogTitle => 'Archive category?';

  @override
  String categoriesArchiveDialogMessage(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '\"$name\" is used by $count expenses. Archiving keeps the history intact.',
      one:
          '\"$name\" is used by 1 expense. Archiving keeps the history intact.',
    );
    return '$_temp0';
  }

  @override
  String get categoriesDeleteDialogTitle => 'Delete category?';

  @override
  String categoriesDeleteDialogMessage(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get categoriesEmptyTitle => 'No categories yet';

  @override
  String get categoriesEmptyMessage =>
      'Add your first category to start recording expenses.';

  @override
  String categoriesArchiveTemplatesMessage(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '\"$name\" is used by $count templates. Archiving keeps your templates intact.',
      one:
          '\"$name\" is used by 1 template. Archiving keeps your templates intact.',
    );
    return '$_temp0';
  }

  @override
  String categoriesArchiveRecurringMessage(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '\"$name\" is used by $count recurring expenses. Archiving keeps your recurring rules intact.',
      one:
          '\"$name\" is used by 1 recurring expense. Archiving keeps your recurring rules intact.',
    );
    return '$_temp0';
  }

  @override
  String get paymentMethodsTitle => 'Payment methods';

  @override
  String get paymentMethodsNewTitle => 'New payment method';

  @override
  String get paymentMethodsEditTitle => 'Edit payment method';

  @override
  String get paymentMethodsName => 'Name';

  @override
  String get paymentMethodsType => 'Type';

  @override
  String get paymentMethodsArchiveDialogTitle => 'Archive payment method?';

  @override
  String paymentMethodsArchiveDialogMessage(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '\"$name\" is used by $count expenses. Archiving keeps the history intact.',
      one:
          '\"$name\" is used by 1 expense. Archiving keeps the history intact.',
    );
    return '$_temp0';
  }

  @override
  String get paymentMethodsDeleteDialogTitle => 'Delete payment method?';

  @override
  String paymentMethodsDeleteDialogMessage(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get paymentMethodsEmptyTitle => 'No payment methods yet';

  @override
  String get paymentMethodsEmptyMessage =>
      'Add cash, cards or wallets to track how you pay.';

  @override
  String paymentMethodsArchiveTemplatesMessage(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '\"$name\" is used by $count templates. Archiving keeps your templates intact.',
      one:
          '\"$name\" is used by 1 template. Archiving keeps your templates intact.',
    );
    return '$_temp0';
  }

  @override
  String paymentMethodsArchiveRecurringMessage(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '\"$name\" is used by $count recurring expenses. Archiving keeps your recurring rules intact.',
      one:
          '\"$name\" is used by 1 recurring expense. Archiving keeps your recurring rules intact.',
    );
    return '$_temp0';
  }

  @override
  String get templatesTitle => 'Templates';

  @override
  String get templatesNewTitle => 'New template';

  @override
  String get templatesEditTitle => 'Edit template';

  @override
  String get templatesName => 'Name';

  @override
  String get templatesNameError => 'Enter a name.';

  @override
  String get templatesAmount => 'Amount';

  @override
  String get templatesCurrency => 'Currency';

  @override
  String get templatesCategory => 'Category';

  @override
  String get templatesPaymentMethod => 'Payment method';

  @override
  String get templatesNote => 'Note';

  @override
  String get templatesUseTemplate => 'Use template';

  @override
  String get templatesChooseTitle => 'Choose a template';

  @override
  String get templatesSaveAsTemplate => 'Save as template';

  @override
  String get templatesSaved => 'Template saved.';

  @override
  String get templatesSaveError =>
      'Could not save the template. Please try again.';

  @override
  String get templatesFromExpense => 'From an expense';

  @override
  String get templatesPickExpense => 'Pick an expense';

  @override
  String get templatesFromExpenseNote =>
      'This only creates a template. Your expense won\'t change.';

  @override
  String get templatesNoExpenses => 'No expenses yet.';

  @override
  String get templateArchived => 'Archived';

  @override
  String get templatesEmptyTitle => 'No templates yet';

  @override
  String get templatesEmptyMessage =>
      'Save frequent expenses to record them in a couple of taps.';

  @override
  String get templatesDeleteDialogTitle => 'Delete template?';

  @override
  String templatesDeleteDialogMessage(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get recurringTitle => 'Recurring';

  @override
  String get recurringNewTitle => 'New recurring expense';

  @override
  String get recurringEditTitle => 'Edit recurring expense';

  @override
  String get recurringEmptyTitle => 'No recurring expenses yet';

  @override
  String get recurringEmptyMessage =>
      'Set up rent, subscriptions or other regular payments.';

  @override
  String get recurringName => 'Name';

  @override
  String get recurringNameError => 'Enter a name.';

  @override
  String get recurringAmount => 'Amount';

  @override
  String get recurringCurrency => 'Currency';

  @override
  String get recurringCategory => 'Category';

  @override
  String get recurringPaymentMethod => 'Payment method';

  @override
  String get recurringFrequency => 'Frequency';

  @override
  String get recurringInterval => 'Repeat every';

  @override
  String get recurringIntervalError => 'Enter an interval of at least 1.';

  @override
  String get recurringNextDate => 'Next date';

  @override
  String get recurringEndDate => 'End date (optional)';

  @override
  String get recurringNoEndDate => 'No end date';

  @override
  String get recurringNote => 'Note';

  @override
  String get recurringActive => 'Active';

  @override
  String get recurringDueNow => 'Due now';

  @override
  String get recurringPaused => 'Paused';

  @override
  String get recurringPause => 'Pause';

  @override
  String get recurringResume => 'Resume';

  @override
  String get recurringRegister => 'Register';

  @override
  String get recurringSkip => 'Skip';

  @override
  String recurringRegistered(String name) {
    return 'Expense registered for $name.';
  }

  @override
  String recurringSkipped(String name) {
    return 'Skipped $name.';
  }

  @override
  String get recurringDeleteTitle => 'Delete recurring expense?';

  @override
  String recurringDeleteMessage(String name) {
    return 'Delete \"$name\"? Past expenses are kept.';
  }

  @override
  String get recurringSaveError => 'Could not save the recurring expense.';

  @override
  String get recurringNotFound => 'Recurring expense not found.';

  @override
  String get recurringLoadError => 'Could not load this recurring expense.';

  @override
  String get recurringFrequencyDaily => 'Daily';

  @override
  String get recurringFrequencyWeekly => 'Weekly';

  @override
  String get recurringFrequencyMonthly => 'Monthly';

  @override
  String get recurringFrequencyYearly => 'Yearly';

  @override
  String recurringEveryInterval(int count, String frequency) {
    return 'Every $count · $frequency';
  }

  @override
  String recurringNextLabel(String date) {
    return 'Next: $date';
  }

  @override
  String get recurringEndDateError =>
      'The end date must be on or after the next date.';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get remindersEmptyTitle => 'No reminders yet';

  @override
  String get remindersEmptyMessage =>
      'Add a reminder and get a local notification when it is due.';

  @override
  String get remindersNewTitle => 'New reminder';

  @override
  String get remindersEditTitle => 'Edit reminder';

  @override
  String get remindersNotFound => 'Reminder not found.';

  @override
  String get remindersLoadError => 'Could not load this reminder.';

  @override
  String get remindersTitleLabel => 'Title';

  @override
  String get remindersNoteLabel => 'Note';

  @override
  String get remindersDue => 'Due date and time';

  @override
  String get remindersTitleError => 'Enter a title.';

  @override
  String get remindersSaveError => 'Could not save the reminder.';

  @override
  String get remindersDeleted => 'Reminder deleted.';

  @override
  String get remindersDeleteTitle => 'Delete reminder?';

  @override
  String remindersDeleteMessage(String title) {
    return 'Delete \"$title\"? This cannot be undone.';
  }

  @override
  String get remindersMarkDone => 'Mark as done';

  @override
  String get remindersMarkUndone => 'Mark as not done';

  @override
  String get remindersOverdue => 'Overdue';

  @override
  String get remindersToday => 'Today';

  @override
  String get remindersUpcoming => 'Upcoming';

  @override
  String get remindersDone => 'Done';

  @override
  String get remindersNoMatchesTitle => 'No matches';

  @override
  String get remindersNoMatchesMessage => 'Try a different tag.';

  @override
  String get remindersNotificationsDenied =>
      'Reminder saved. Notifications are off, so you won\'t get an alert.';

  @override
  String get dashboardUpcomingPayments => 'Upcoming payments';

  @override
  String get dashboardNoUpcomingPaymentsTitle => 'No upcoming payments';

  @override
  String get dashboardNoUpcomingPaymentsMessage =>
      'Add a recurring expense to see it here.';

  @override
  String get dashboardUpcomingReminders => 'Upcoming reminders';

  @override
  String get dashboardNoUpcomingRemindersTitle => 'No upcoming reminders';

  @override
  String get dashboardNoUpcomingRemindersMessage =>
      'Add a reminder to see it here.';

  @override
  String get attachmentsTitle => 'Attachments';

  @override
  String get attachmentsEmpty => 'No files attached.';

  @override
  String get attachmentsAdd => 'Add attachment';

  @override
  String get attachmentsCamera => 'Camera';

  @override
  String get attachmentsGallery => 'Gallery';

  @override
  String get attachmentsFile => 'File';

  @override
  String get attachmentsSaveFirst => 'Save first to attach files.';

  @override
  String get attachmentsDeleteTitle => 'Delete attachment?';

  @override
  String attachmentsDeleteMessage(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get attachmentsMissing => 'This file is missing from the device.';

  @override
  String get attachmentsOpenError => 'Could not open this file.';

  @override
  String get attachmentsAddError => 'Could not add this attachment.';

  @override
  String get attachmentsTooLarge =>
      'This file is too large. Attachments can be up to 25 MB.';

  @override
  String get settingsExportFullBackup => 'Export full backup (ZIP)';

  @override
  String get settingsExportFullBackupSubtitle =>
      'Records plus all attachment files';

  @override
  String get settingsImportFullBackup => 'Import full backup (ZIP)';

  @override
  String get settingsImportFullBackupSubtitle =>
      'Merge records and restore attachments';

  @override
  String get settingsFullBackupExportError =>
      'Could not export the full backup.';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutTagline => 'A local-first expense tracker for Android.';

  @override
  String get aboutDataPrivacyTitle => 'Data & privacy';

  @override
  String get aboutDataPrivacy =>
      'All expenses, categories and settings live in a SQLite database on this device. Xzifra has no accounts, no analytics and no network access. Export a JSON backup before uninstalling the app.';

  @override
  String get aboutProject => 'Project';

  @override
  String get aboutSourceCode => 'Source code';

  @override
  String get aboutSourceCodeSubtitle => 'github.com/bytezer/xzifra';

  @override
  String get aboutReleases => 'Releases & updates';

  @override
  String get aboutReleasesSubtitle => 'Download the latest beta';

  @override
  String get aboutReportIssue => 'Report an issue';

  @override
  String get aboutReportIssueSubtitle => 'Open a GitHub issue';

  @override
  String get aboutShareApp => 'Share app';

  @override
  String get aboutShareAppSubtitle => 'Send the release link';

  @override
  String get aboutMitLicense => 'MIT License';

  @override
  String get aboutMitLicenseSubtitle => 'View the license on GitHub';

  @override
  String get aboutDiagnostics => 'Diagnostics';

  @override
  String get aboutCopyDebugInfo => 'Copy debug info';

  @override
  String get aboutCopyDebugInfoSubtitle =>
      'Version, build, commit and settings';

  @override
  String get aboutLicenses => 'Open source licenses';

  @override
  String get aboutLicensesSubtitle => 'Flutter, packages and the Lucide icon';

  @override
  String get aboutBuild => 'Build';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutCommit => 'Commit';

  @override
  String get aboutBuilt => 'Built';

  @override
  String get aboutTheme => 'Theme';

  @override
  String get aboutCurrency => 'Currency';

  @override
  String get aboutLanguage => 'Language';

  @override
  String get aboutMadeBy => 'Made by xzero';

  @override
  String get aboutIconCredit => 'Icon based on Lucide x (ISC/MIT)';

  @override
  String get aboutDebugCopied => 'Debug info copied.';

  @override
  String get aboutLinkError => 'Could not open the link.';

  @override
  String get aboutLoadError => 'Could not read app information.';

  @override
  String aboutVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String aboutShareText(String url) {
    return 'Xzifra — a local-first expense tracker for Android.\n$url';
  }

  @override
  String get aboutLegalese => 'MIT License · Made by xzero';
}
