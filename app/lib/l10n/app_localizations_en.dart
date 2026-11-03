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
  String get settingsExportJsonSubtitle => 'Full backup you can import later';

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
  String settingsImportProcessed(int total, int expenses) {
    return 'Processed $total records ($expenses expenses).';
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
