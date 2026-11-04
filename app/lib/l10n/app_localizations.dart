import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Xzifra'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get navExpenses;

  /// No description provided for @navRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get navRecords;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @actionRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get actionRestore;

  /// No description provided for @actionMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get actionMoveUp;

  /// No description provided for @actionMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get actionMoveDown;

  /// No description provided for @actionArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get actionArchive;

  /// No description provided for @actionDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get actionDuplicate;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @labelNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get labelNone;

  /// No description provided for @labelOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get labelOptional;

  /// No description provided for @labelUnknownCategory.
  ///
  /// In en, this message translates to:
  /// **'Unknown category'**
  String get labelUnknownCategory;

  /// No description provided for @labelNoPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'No payment method'**
  String get labelNoPaymentMethod;

  /// No description provided for @labelArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get labelArchived;

  /// No description provided for @categoryArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get categoryArchived;

  /// No description provided for @paymentMethodArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get paymentMethodArchived;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @tooltipPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get tooltipPreviousMonth;

  /// No description provided for @tooltipNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get tooltipNextMonth;

  /// No description provided for @tooltipAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get tooltipAddExpense;

  /// No description provided for @tooltipQuickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get tooltipQuickAdd;

  /// No description provided for @quickAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get quickAddExpense;

  /// No description provided for @quickAddNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get quickAddNote;

  /// No description provided for @quickAddBookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get quickAddBookmark;

  /// No description provided for @quickAddReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get quickAddReminder;

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsLabel;

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'Separate tags with commas'**
  String get tagsHint;

  /// No description provided for @tagsAll.
  ///
  /// In en, this message translates to:
  /// **'All tags'**
  String get tagsAll;

  /// No description provided for @shortcutNewExpense.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get shortcutNewExpense;

  /// No description provided for @shortcutReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get shortcutReports;

  /// No description provided for @widgetEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Open Xzifra to see this month'**
  String get widgetEmptyMessage;

  /// No description provided for @dashboardSpentThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Spent this month'**
  String get dashboardSpentThisMonth;

  /// No description provided for @dashboardTopCategories.
  ///
  /// In en, this message translates to:
  /// **'Top categories'**
  String get dashboardTopCategories;

  /// No description provided for @dashboardRecentExpenses.
  ///
  /// In en, this message translates to:
  /// **'Recent expenses'**
  String get dashboardRecentExpenses;

  /// No description provided for @dashboardViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get dashboardViewAll;

  /// No description provided for @dashboardRepeatLast.
  ///
  /// In en, this message translates to:
  /// **'Repeat last'**
  String get dashboardRepeatLast;

  /// No description provided for @dashboardNoExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month'**
  String get dashboardNoExpensesTitle;

  /// No description provided for @dashboardNoExpensesMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first expense to see the breakdown.'**
  String get dashboardNoExpensesMessage;

  /// No description provided for @dashboardAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get dashboardAddExpense;

  /// No description provided for @dashboardNothingRecordedTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded yet'**
  String get dashboardNothingRecordedTitle;

  /// No description provided for @dashboardNothingRecordedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your latest expenses will show up here.'**
  String get dashboardNothingRecordedMessage;

  /// No description provided for @dashboardLoadingPrevious.
  ///
  /// In en, this message translates to:
  /// **'Loading previous month…'**
  String get dashboardLoadingPrevious;

  /// No description provided for @dashboardNoSpendingLastMonth.
  ///
  /// In en, this message translates to:
  /// **'No spending recorded last month'**
  String get dashboardNoSpendingLastMonth;

  /// No description provided for @dashboardNoSpendingYet.
  ///
  /// In en, this message translates to:
  /// **'No spending recorded yet'**
  String get dashboardNoSpendingYet;

  /// No description provided for @dashboardSameAsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Same as last month'**
  String get dashboardSameAsLastMonth;

  /// No description provided for @dashboardIncreased.
  ///
  /// In en, this message translates to:
  /// **'+{percent}% vs last month'**
  String dashboardIncreased(String percent);

  /// No description provided for @dashboardDecreased.
  ///
  /// In en, this message translates to:
  /// **'−{percent}% vs last month'**
  String dashboardDecreased(String percent);

  /// No description provided for @dashboardRecentNotes.
  ///
  /// In en, this message translates to:
  /// **'Recent notes'**
  String get dashboardRecentNotes;

  /// No description provided for @dashboardBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get dashboardBookmarks;

  /// No description provided for @dashboardNothingNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get dashboardNothingNotesTitle;

  /// No description provided for @dashboardNothingNotesMessage.
  ///
  /// In en, this message translates to:
  /// **'Capture something and it will show up here.'**
  String get dashboardNothingNotesMessage;

  /// No description provided for @dashboardNothingBookmarksTitle.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get dashboardNothingBookmarksTitle;

  /// No description provided for @dashboardNothingBookmarksMessage.
  ///
  /// In en, this message translates to:
  /// **'Save links to find them here.'**
  String get dashboardNothingBookmarksMessage;

  /// No description provided for @dashboardAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get dashboardAddNote;

  /// No description provided for @dashboardAddBookmark.
  ///
  /// In en, this message translates to:
  /// **'Add bookmark'**
  String get dashboardAddBookmark;

  /// No description provided for @expensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesTitle;

  /// No description provided for @expensesFilterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expensesFilterCategory;

  /// No description provided for @expensesFilterPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get expensesFilterPayment;

  /// No description provided for @expensesNoMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get expensesNoMatchesTitle;

  /// No description provided for @expensesNoMatchesMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different category or payment method.'**
  String get expensesNoMatchesMessage;

  /// No description provided for @expensesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month'**
  String get expensesEmptyTitle;

  /// No description provided for @expensesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to record one.'**
  String get expensesEmptyMessage;

  /// No description provided for @expensesClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get expensesClearFilters;

  /// No description provided for @expensesFilterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by category'**
  String get expensesFilterByCategory;

  /// No description provided for @expensesFilterByPayment.
  ///
  /// In en, this message translates to:
  /// **'Filter by payment method'**
  String get expensesFilterByPayment;

  /// No description provided for @expensesAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get expensesAllCategories;

  /// No description provided for @expensesAllPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'All payment methods'**
  String get expensesAllPaymentMethods;

  /// No description provided for @expensesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete expense?'**
  String get expensesDeleteTitle;

  /// No description provided for @expensesDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {category} expense'**
  String expensesDeleted(String category);

  /// No description provided for @notesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTitle;

  /// No description provided for @notesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get notesEmptyTitle;

  /// No description provided for @notesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Capture an idea, a list or a quote. It stays on this device.'**
  String get notesEmptyMessage;

  /// No description provided for @notesNoMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get notesNoMatchesTitle;

  /// No description provided for @notesNoMatchesMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different tag.'**
  String get notesNoMatchesMessage;

  /// No description provided for @notesNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get notesNewTitle;

  /// No description provided for @notesEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get notesEditTitle;

  /// No description provided for @notesNotFound.
  ///
  /// In en, this message translates to:
  /// **'Note not found.'**
  String get notesNotFound;

  /// No description provided for @notesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this note.'**
  String get notesLoadError;

  /// No description provided for @notesTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get notesTitleLabel;

  /// No description provided for @notesBodyLabel.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get notesBodyLabel;

  /// No description provided for @notesBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Write in plain text or Markdown'**
  String get notesBodyHint;

  /// No description provided for @notesTitleError.
  ///
  /// In en, this message translates to:
  /// **'Enter a title.'**
  String get notesTitleError;

  /// No description provided for @notesSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the note. Please try again.'**
  String get notesSaveError;

  /// No description provided for @notesDeleted.
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get notesDeleted;

  /// No description provided for @notesPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get notesPinned;

  /// No description provided for @notesPin.
  ///
  /// In en, this message translates to:
  /// **'Pin note'**
  String get notesPin;

  /// No description provided for @notesUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin note'**
  String get notesUnpin;

  /// No description provided for @notesArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive note'**
  String get notesArchive;

  /// No description provided for @notesUnarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive note'**
  String get notesUnarchive;

  /// No description provided for @notesArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get notesArchived;

  /// No description provided for @notesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete note?'**
  String get notesDeleteTitle;

  /// No description provided for @notesDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"? This cannot be undone.'**
  String notesDeleteMessage(String title);

  /// No description provided for @notesExportMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Export as Markdown'**
  String get notesExportMarkdown;

  /// No description provided for @notesExportAll.
  ///
  /// In en, this message translates to:
  /// **'Export all notes (ZIP)'**
  String get notesExportAll;

  /// No description provided for @notesExportError.
  ///
  /// In en, this message translates to:
  /// **'Could not export the note.'**
  String get notesExportError;

  /// No description provided for @notesExportAllError.
  ///
  /// In en, this message translates to:
  /// **'Could not export the notes.'**
  String get notesExportAllError;

  /// No description provided for @bookmarksTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarksTitle;

  /// No description provided for @bookmarksEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get bookmarksEmptyTitle;

  /// No description provided for @bookmarksEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Save links you want to come back to.'**
  String get bookmarksEmptyMessage;

  /// No description provided for @bookmarksNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New bookmark'**
  String get bookmarksNewTitle;

  /// No description provided for @bookmarksEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit bookmark'**
  String get bookmarksEditTitle;

  /// No description provided for @bookmarksNotFound.
  ///
  /// In en, this message translates to:
  /// **'Bookmark not found.'**
  String get bookmarksNotFound;

  /// No description provided for @bookmarksLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this bookmark.'**
  String get bookmarksLoadError;

  /// No description provided for @bookmarksUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get bookmarksUrlLabel;

  /// No description provided for @bookmarksUrlError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid http or https link.'**
  String get bookmarksUrlError;

  /// No description provided for @bookmarksTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get bookmarksTitleLabel;

  /// No description provided for @bookmarksTitleHelp.
  ///
  /// In en, this message translates to:
  /// **'Leave it empty to use the domain'**
  String get bookmarksTitleHelp;

  /// No description provided for @bookmarksNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get bookmarksNoteLabel;

  /// No description provided for @bookmarksSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the bookmark. Please try again.'**
  String get bookmarksSaveError;

  /// No description provided for @bookmarksDeleted.
  ///
  /// In en, this message translates to:
  /// **'Bookmark deleted'**
  String get bookmarksDeleted;

  /// No description provided for @bookmarksArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive bookmark'**
  String get bookmarksArchive;

  /// No description provided for @bookmarksUnarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive bookmark'**
  String get bookmarksUnarchive;

  /// No description provided for @bookmarksArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get bookmarksArchived;

  /// No description provided for @bookmarksDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete bookmark?'**
  String get bookmarksDeleteTitle;

  /// No description provided for @bookmarksDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"? This cannot be undone.'**
  String bookmarksDeleteMessage(String title);

  /// No description provided for @bookmarksOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open this link.'**
  String get bookmarksOpenError;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search expenses, notes and bookmarks'**
  String get searchHint;

  /// No description provided for @searchEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Find expenses, notes and bookmarks on this device.'**
  String get searchEmptyMessage;

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get searchNoResultsTitle;

  /// No description provided for @searchNoResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try another word or check the spelling.'**
  String get searchNoResultsMessage;

  /// No description provided for @searchExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get searchExpenses;

  /// No description provided for @searchNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get searchNotes;

  /// No description provided for @searchBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get searchBookmarks;

  /// No description provided for @expenseNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get expenseNewTitle;

  /// No description provided for @expenseEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get expenseEditTitle;

  /// No description provided for @expenseDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate expense'**
  String get expenseDuplicateTitle;

  /// No description provided for @expenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenseAmount;

  /// No description provided for @expenseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get expenseCurrency;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseCategory;

  /// No description provided for @expensePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get expensePaymentMethod;

  /// No description provided for @expenseDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get expenseDate;

  /// No description provided for @expenseNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get expenseNote;

  /// No description provided for @expenseSave.
  ///
  /// In en, this message translates to:
  /// **'Save expense'**
  String get expenseSave;

  /// No description provided for @expenseSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get expenseSaveChanges;

  /// No description provided for @expenseSaveAndAddAnother.
  ///
  /// In en, this message translates to:
  /// **'Save & add another'**
  String get expenseSaveAndAddAnother;

  /// No description provided for @expenseSavedAnother.
  ///
  /// In en, this message translates to:
  /// **'Expense saved. Add another.'**
  String get expenseSavedAnother;

  /// No description provided for @expenseAmountError.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero.'**
  String get expenseAmountError;

  /// No description provided for @expenseCategoryError.
  ///
  /// In en, this message translates to:
  /// **'Choose a category.'**
  String get expenseCategoryError;

  /// No description provided for @expenseSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the expense. Please try again.'**
  String get expenseSaveError;

  /// No description provided for @expenseNoCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories yet. Add one in Settings.'**
  String get expenseNoCategories;

  /// No description provided for @expenseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Expense not found.'**
  String get expenseNotFound;

  /// No description provided for @expenseLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this expense.'**
  String get expenseLoadError;

  /// No description provided for @expenseDateHelp.
  ///
  /// In en, this message translates to:
  /// **'Expense date'**
  String get expenseDateHelp;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @reportsByCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get reportsByCategory;

  /// No description provided for @reportsNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No data for this month'**
  String get reportsNoDataTitle;

  /// No description provided for @reportsNoDataMessage.
  ///
  /// In en, this message translates to:
  /// **'Record an expense to see the breakdown.'**
  String get reportsNoDataMessage;

  /// No description provided for @reportsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get reportsTotal;

  /// No description provided for @reportsLast12Months.
  ///
  /// In en, this message translates to:
  /// **'Last 12 months'**
  String get reportsLast12Months;

  /// No description provided for @reportsByPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'By payment method'**
  String get reportsByPaymentMethod;

  /// No description provided for @reportsNoPaymentDataMessage.
  ///
  /// In en, this message translates to:
  /// **'Payment methods will show up here.'**
  String get reportsNoPaymentDataMessage;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get settingsThemeMode;

  /// No description provided for @settingsThemeModeFixed.
  ///
  /// In en, this message translates to:
  /// **'Dark (fixed by Cyber Red)'**
  String get settingsThemeModeFixed;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystemDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow the device setting'**
  String get settingsThemeSystemDescription;

  /// No description provided for @settingsThemeLightDescription.
  ///
  /// In en, this message translates to:
  /// **'Always use the light theme'**
  String get settingsThemeLightDescription;

  /// No description provided for @settingsThemeDarkDescription.
  ///
  /// In en, this message translates to:
  /// **'Always use the dark theme'**
  String get settingsThemeDarkDescription;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsDefaultCurrency.
  ///
  /// In en, this message translates to:
  /// **'Default currency'**
  String get settingsDefaultCurrency;

  /// No description provided for @settingsCurrencyPEN.
  ///
  /// In en, this message translates to:
  /// **'Soles (PEN)'**
  String get settingsCurrencyPEN;

  /// No description provided for @settingsCurrencyUSD.
  ///
  /// In en, this message translates to:
  /// **'Dollars (USD)'**
  String get settingsCurrencyUSD;

  /// No description provided for @settingsManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get settingsManage;

  /// No description provided for @settingsCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get settingsCategories;

  /// No description provided for @settingsCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create, edit, reorder or archive'**
  String get settingsCategoriesSubtitle;

  /// No description provided for @settingsPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get settingsPaymentMethods;

  /// No description provided for @settingsPaymentMethodsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your own list with a name and emoji'**
  String get settingsPaymentMethodsSubtitle;

  /// No description provided for @settingsTemplates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get settingsTemplates;

  /// No description provided for @settingsTemplatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save frequent expenses for quick entry'**
  String get settingsTemplatesSubtitle;

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get settingsBackup;

  /// No description provided for @settingsExportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON backup'**
  String get settingsExportJson;

  /// No description provided for @settingsExportJsonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Records and data only. Use the full backup to include attachments.'**
  String get settingsExportJsonSubtitle;

  /// No description provided for @settingsExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get settingsExportCsv;

  /// No description provided for @settingsExportCsvSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open your expenses in a spreadsheet'**
  String get settingsExportCsvSubtitle;

  /// No description provided for @settingsImportJson.
  ///
  /// In en, this message translates to:
  /// **'Import JSON backup'**
  String get settingsImportJson;

  /// No description provided for @settingsImportJsonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Merge a backup into this device'**
  String get settingsImportJsonSubtitle;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Xzifra'**
  String get settingsAbout;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version, source code and licenses'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsExportError.
  ///
  /// In en, this message translates to:
  /// **'Could not export the backup.'**
  String get settingsExportError;

  /// No description provided for @settingsCsvError.
  ///
  /// In en, this message translates to:
  /// **'Could not export the CSV.'**
  String get settingsCsvError;

  /// No description provided for @settingsImportProcessed.
  ///
  /// In en, this message translates to:
  /// **'Processed {total} records ({expenses} expenses, {notes} notes, {bookmarks} bookmarks, {recurring} recurring, {reminders} reminders).'**
  String settingsImportProcessed(
    int total,
    int expenses,
    int notes,
    int bookmarks,
    int recurring,
    int reminders,
  );

  /// No description provided for @settingsImportError.
  ///
  /// In en, this message translates to:
  /// **'Could not import this backup.'**
  String get settingsImportError;

  /// No description provided for @settingsImportInvalid.
  ///
  /// In en, this message translates to:
  /// **'This file is not an Xzifra backup.'**
  String get settingsImportInvalid;

  /// No description provided for @themeIndigo.
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get themeIndigo;

  /// No description provided for @themeIndigoDescription.
  ///
  /// In en, this message translates to:
  /// **'Calm indigo accents on Material 3 surfaces.'**
  String get themeIndigoDescription;

  /// No description provided for @themeCyberRed.
  ///
  /// In en, this message translates to:
  /// **'Cyber Red'**
  String get themeCyberRed;

  /// No description provided for @themeCyberRedDescription.
  ///
  /// In en, this message translates to:
  /// **'Black surfaces with neon red accents.'**
  String get themeCyberRedDescription;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @categoriesNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get categoriesNewTitle;

  /// No description provided for @categoriesEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get categoriesEditTitle;

  /// No description provided for @categoriesName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoriesName;

  /// No description provided for @categoriesIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get categoriesIcon;

  /// No description provided for @categoriesColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get categoriesColor;

  /// No description provided for @categoriesArchiveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive category?'**
  String get categoriesArchiveDialogTitle;

  /// No description provided for @categoriesArchiveDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{\"{name}\" is used by 1 expense. Archiving keeps the history intact.} other{\"{name}\" is used by {count} expenses. Archiving keeps the history intact.}}'**
  String categoriesArchiveDialogMessage(String name, int count);

  /// No description provided for @categoriesDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get categoriesDeleteDialogTitle;

  /// No description provided for @categoriesDeleteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String categoriesDeleteDialogMessage(String name);

  /// No description provided for @categoriesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get categoriesEmptyTitle;

  /// No description provided for @categoriesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first category to start recording expenses.'**
  String get categoriesEmptyMessage;

  /// No description provided for @categoriesArchiveTemplatesMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{\"{name}\" is used by 1 template. Archiving keeps your templates intact.} other{\"{name}\" is used by {count} templates. Archiving keeps your templates intact.}}'**
  String categoriesArchiveTemplatesMessage(String name, int count);

  /// No description provided for @categoriesArchiveRecurringMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{\"{name}\" is used by 1 recurring expense. Archiving keeps your recurring rules intact.} other{\"{name}\" is used by {count} recurring expenses. Archiving keeps your recurring rules intact.}}'**
  String categoriesArchiveRecurringMessage(String name, int count);

  /// No description provided for @paymentMethodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get paymentMethodsTitle;

  /// No description provided for @paymentMethodsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New payment method'**
  String get paymentMethodsNewTitle;

  /// No description provided for @paymentMethodsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit payment method'**
  String get paymentMethodsEditTitle;

  /// No description provided for @paymentMethodsName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get paymentMethodsName;

  /// No description provided for @paymentMethodsType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get paymentMethodsType;

  /// No description provided for @paymentMethodsArchiveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive payment method?'**
  String get paymentMethodsArchiveDialogTitle;

  /// No description provided for @paymentMethodsArchiveDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{\"{name}\" is used by 1 expense. Archiving keeps the history intact.} other{\"{name}\" is used by {count} expenses. Archiving keeps the history intact.}}'**
  String paymentMethodsArchiveDialogMessage(String name, int count);

  /// No description provided for @paymentMethodsDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete payment method?'**
  String get paymentMethodsDeleteDialogTitle;

  /// No description provided for @paymentMethodsDeleteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String paymentMethodsDeleteDialogMessage(String name);

  /// No description provided for @paymentMethodsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No payment methods yet'**
  String get paymentMethodsEmptyTitle;

  /// No description provided for @paymentMethodsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add cash, cards or wallets to track how you pay.'**
  String get paymentMethodsEmptyMessage;

  /// No description provided for @paymentMethodsArchiveTemplatesMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{\"{name}\" is used by 1 template. Archiving keeps your templates intact.} other{\"{name}\" is used by {count} templates. Archiving keeps your templates intact.}}'**
  String paymentMethodsArchiveTemplatesMessage(String name, int count);

  /// No description provided for @paymentMethodsArchiveRecurringMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{\"{name}\" is used by 1 recurring expense. Archiving keeps your recurring rules intact.} other{\"{name}\" is used by {count} recurring expenses. Archiving keeps your recurring rules intact.}}'**
  String paymentMethodsArchiveRecurringMessage(String name, int count);

  /// No description provided for @templatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templatesTitle;

  /// No description provided for @templatesNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New template'**
  String get templatesNewTitle;

  /// No description provided for @templatesEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit template'**
  String get templatesEditTitle;

  /// No description provided for @templatesName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get templatesName;

  /// No description provided for @templatesNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter a name.'**
  String get templatesNameError;

  /// No description provided for @templatesAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get templatesAmount;

  /// No description provided for @templatesCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get templatesCurrency;

  /// No description provided for @templatesCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get templatesCategory;

  /// No description provided for @templatesPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get templatesPaymentMethod;

  /// No description provided for @templatesNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get templatesNote;

  /// No description provided for @templatesUseTemplate.
  ///
  /// In en, this message translates to:
  /// **'Use template'**
  String get templatesUseTemplate;

  /// No description provided for @templatesChooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a template'**
  String get templatesChooseTitle;

  /// No description provided for @templatesSaveAsTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save as template'**
  String get templatesSaveAsTemplate;

  /// No description provided for @templatesSaved.
  ///
  /// In en, this message translates to:
  /// **'Template saved.'**
  String get templatesSaved;

  /// No description provided for @templatesSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the template. Please try again.'**
  String get templatesSaveError;

  /// No description provided for @templatesFromExpense.
  ///
  /// In en, this message translates to:
  /// **'From an expense'**
  String get templatesFromExpense;

  /// No description provided for @templatesPickExpense.
  ///
  /// In en, this message translates to:
  /// **'Pick an expense'**
  String get templatesPickExpense;

  /// No description provided for @templatesFromExpenseNote.
  ///
  /// In en, this message translates to:
  /// **'This only creates a template. Your expense won\'t change.'**
  String get templatesFromExpenseNote;

  /// No description provided for @templatesNoExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet.'**
  String get templatesNoExpenses;

  /// No description provided for @templateArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get templateArchived;

  /// No description provided for @templatesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
  String get templatesEmptyTitle;

  /// No description provided for @templatesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Save frequent expenses to record them in a couple of taps.'**
  String get templatesEmptyMessage;

  /// No description provided for @templatesDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete template?'**
  String get templatesDeleteDialogTitle;

  /// No description provided for @templatesDeleteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String templatesDeleteDialogMessage(String name);

  /// No description provided for @recurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurringTitle;

  /// No description provided for @recurringNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New recurring expense'**
  String get recurringNewTitle;

  /// No description provided for @recurringEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit recurring expense'**
  String get recurringEditTitle;

  /// No description provided for @recurringEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No recurring expenses yet'**
  String get recurringEmptyTitle;

  /// No description provided for @recurringEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Set up rent, subscriptions or other regular payments.'**
  String get recurringEmptyMessage;

  /// No description provided for @recurringName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get recurringName;

  /// No description provided for @recurringNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter a name.'**
  String get recurringNameError;

  /// No description provided for @recurringAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get recurringAmount;

  /// No description provided for @recurringCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get recurringCurrency;

  /// No description provided for @recurringCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get recurringCategory;

  /// No description provided for @recurringPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get recurringPaymentMethod;

  /// No description provided for @recurringFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get recurringFrequency;

  /// No description provided for @recurringInterval.
  ///
  /// In en, this message translates to:
  /// **'Repeat every'**
  String get recurringInterval;

  /// No description provided for @recurringIntervalError.
  ///
  /// In en, this message translates to:
  /// **'Enter an interval of at least 1.'**
  String get recurringIntervalError;

  /// No description provided for @recurringNextDate.
  ///
  /// In en, this message translates to:
  /// **'Next date'**
  String get recurringNextDate;

  /// No description provided for @recurringEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date (optional)'**
  String get recurringEndDate;

  /// No description provided for @recurringNoEndDate.
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get recurringNoEndDate;

  /// No description provided for @recurringNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get recurringNote;

  /// No description provided for @recurringActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get recurringActive;

  /// No description provided for @recurringDueNow.
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get recurringDueNow;

  /// No description provided for @recurringPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get recurringPaused;

  /// No description provided for @recurringPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get recurringPause;

  /// No description provided for @recurringResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get recurringResume;

  /// No description provided for @recurringRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get recurringRegister;

  /// No description provided for @recurringSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get recurringSkip;

  /// No description provided for @recurringRegistered.
  ///
  /// In en, this message translates to:
  /// **'Expense registered for {name}.'**
  String recurringRegistered(String name);

  /// No description provided for @recurringSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped {name}.'**
  String recurringSkipped(String name);

  /// No description provided for @recurringDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete recurring expense?'**
  String get recurringDeleteTitle;

  /// No description provided for @recurringDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? Past expenses are kept.'**
  String recurringDeleteMessage(String name);

  /// No description provided for @recurringSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the recurring expense.'**
  String get recurringSaveError;

  /// No description provided for @recurringNotFound.
  ///
  /// In en, this message translates to:
  /// **'Recurring expense not found.'**
  String get recurringNotFound;

  /// No description provided for @recurringLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this recurring expense.'**
  String get recurringLoadError;

  /// No description provided for @recurringFrequencyDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get recurringFrequencyDaily;

  /// No description provided for @recurringFrequencyWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get recurringFrequencyWeekly;

  /// No description provided for @recurringFrequencyMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get recurringFrequencyMonthly;

  /// No description provided for @recurringFrequencyYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get recurringFrequencyYearly;

  /// No description provided for @recurringEveryInterval.
  ///
  /// In en, this message translates to:
  /// **'Every {count} · {frequency}'**
  String recurringEveryInterval(int count, String frequency);

  /// No description provided for @recurringNextLabel.
  ///
  /// In en, this message translates to:
  /// **'Next: {date}'**
  String recurringNextLabel(String date);

  /// No description provided for @recurringEndDateError.
  ///
  /// In en, this message translates to:
  /// **'The end date must be on or after the next date.'**
  String get recurringEndDateError;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @remindersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get remindersEmptyTitle;

  /// No description provided for @remindersEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a reminder and get a local notification when it is due.'**
  String get remindersEmptyMessage;

  /// No description provided for @remindersNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get remindersNewTitle;

  /// No description provided for @remindersEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get remindersEditTitle;

  /// No description provided for @remindersNotFound.
  ///
  /// In en, this message translates to:
  /// **'Reminder not found.'**
  String get remindersNotFound;

  /// No description provided for @remindersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this reminder.'**
  String get remindersLoadError;

  /// No description provided for @remindersTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get remindersTitleLabel;

  /// No description provided for @remindersNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get remindersNoteLabel;

  /// No description provided for @remindersDue.
  ///
  /// In en, this message translates to:
  /// **'Due date and time'**
  String get remindersDue;

  /// No description provided for @remindersTitleError.
  ///
  /// In en, this message translates to:
  /// **'Enter a title.'**
  String get remindersTitleError;

  /// No description provided for @remindersSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the reminder.'**
  String get remindersSaveError;

  /// No description provided for @remindersDeleted.
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted.'**
  String get remindersDeleted;

  /// No description provided for @remindersDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete reminder?'**
  String get remindersDeleteTitle;

  /// No description provided for @remindersDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"? This cannot be undone.'**
  String remindersDeleteMessage(String title);

  /// No description provided for @remindersMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get remindersMarkDone;

  /// No description provided for @remindersMarkUndone.
  ///
  /// In en, this message translates to:
  /// **'Mark as not done'**
  String get remindersMarkUndone;

  /// No description provided for @remindersOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get remindersOverdue;

  /// No description provided for @remindersToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get remindersToday;

  /// No description provided for @remindersUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get remindersUpcoming;

  /// No description provided for @remindersDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get remindersDone;

  /// No description provided for @remindersNoMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get remindersNoMatchesTitle;

  /// No description provided for @remindersNoMatchesMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different tag.'**
  String get remindersNoMatchesMessage;

  /// No description provided for @remindersNotificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Reminder saved. Notifications are off, so you won\'t get an alert.'**
  String get remindersNotificationsDenied;

  /// No description provided for @dashboardUpcomingPayments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming payments'**
  String get dashboardUpcomingPayments;

  /// No description provided for @dashboardNoUpcomingPaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'No upcoming payments'**
  String get dashboardNoUpcomingPaymentsTitle;

  /// No description provided for @dashboardNoUpcomingPaymentsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a recurring expense to see it here.'**
  String get dashboardNoUpcomingPaymentsMessage;

  /// No description provided for @dashboardUpcomingReminders.
  ///
  /// In en, this message translates to:
  /// **'Upcoming reminders'**
  String get dashboardUpcomingReminders;

  /// No description provided for @dashboardNoUpcomingRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'No upcoming reminders'**
  String get dashboardNoUpcomingRemindersTitle;

  /// No description provided for @dashboardNoUpcomingRemindersMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a reminder to see it here.'**
  String get dashboardNoUpcomingRemindersMessage;

  /// No description provided for @attachmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachmentsTitle;

  /// No description provided for @attachmentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No files attached.'**
  String get attachmentsEmpty;

  /// No description provided for @attachmentsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add attachment'**
  String get attachmentsAdd;

  /// No description provided for @attachmentsCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get attachmentsCamera;

  /// No description provided for @attachmentsGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get attachmentsGallery;

  /// No description provided for @attachmentsFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get attachmentsFile;

  /// No description provided for @attachmentsSaveFirst.
  ///
  /// In en, this message translates to:
  /// **'Save first to attach files.'**
  String get attachmentsSaveFirst;

  /// No description provided for @attachmentsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete attachment?'**
  String get attachmentsDeleteTitle;

  /// No description provided for @attachmentsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String attachmentsDeleteMessage(String name);

  /// No description provided for @attachmentsMissing.
  ///
  /// In en, this message translates to:
  /// **'This file is missing from the device.'**
  String get attachmentsMissing;

  /// No description provided for @attachmentsOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open this file.'**
  String get attachmentsOpenError;

  /// No description provided for @attachmentsAddError.
  ///
  /// In en, this message translates to:
  /// **'Could not add this attachment.'**
  String get attachmentsAddError;

  /// No description provided for @attachmentsTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This file is too large. Attachments can be up to 25 MB.'**
  String get attachmentsTooLarge;

  /// No description provided for @settingsExportFullBackup.
  ///
  /// In en, this message translates to:
  /// **'Export full backup (ZIP)'**
  String get settingsExportFullBackup;

  /// No description provided for @settingsExportFullBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Records plus all attachment files'**
  String get settingsExportFullBackupSubtitle;

  /// No description provided for @settingsImportFullBackup.
  ///
  /// In en, this message translates to:
  /// **'Import full backup (ZIP)'**
  String get settingsImportFullBackup;

  /// No description provided for @settingsImportFullBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Merge records and restore attachments'**
  String get settingsImportFullBackupSubtitle;

  /// No description provided for @settingsFullBackupExportError.
  ///
  /// In en, this message translates to:
  /// **'Could not export the full backup.'**
  String get settingsFullBackupExportError;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'A local-first expense tracker for Android.'**
  String get aboutTagline;

  /// No description provided for @aboutDataPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Data & privacy'**
  String get aboutDataPrivacyTitle;

  /// No description provided for @aboutDataPrivacy.
  ///
  /// In en, this message translates to:
  /// **'All expenses, categories and settings live in a SQLite database on this device. Xzifra has no accounts, no analytics and no network access. Export a JSON backup before uninstalling the app.'**
  String get aboutDataPrivacy;

  /// No description provided for @aboutProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get aboutProject;

  /// No description provided for @aboutSourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get aboutSourceCode;

  /// No description provided for @aboutSourceCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'github.com/bytezer/xzifra'**
  String get aboutSourceCodeSubtitle;

  /// No description provided for @aboutReleases.
  ///
  /// In en, this message translates to:
  /// **'Releases & updates'**
  String get aboutReleases;

  /// No description provided for @aboutReleasesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download the latest beta'**
  String get aboutReleasesSubtitle;

  /// No description provided for @aboutReportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get aboutReportIssue;

  /// No description provided for @aboutReportIssueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open a GitHub issue'**
  String get aboutReportIssueSubtitle;

  /// No description provided for @aboutShareApp.
  ///
  /// In en, this message translates to:
  /// **'Share app'**
  String get aboutShareApp;

  /// No description provided for @aboutShareAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send the release link'**
  String get aboutShareAppSubtitle;

  /// No description provided for @aboutMitLicense.
  ///
  /// In en, this message translates to:
  /// **'MIT License'**
  String get aboutMitLicense;

  /// No description provided for @aboutMitLicenseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View the license on GitHub'**
  String get aboutMitLicenseSubtitle;

  /// No description provided for @aboutDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get aboutDiagnostics;

  /// No description provided for @aboutCopyDebugInfo.
  ///
  /// In en, this message translates to:
  /// **'Copy debug info'**
  String get aboutCopyDebugInfo;

  /// No description provided for @aboutCopyDebugInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version, build, commit and settings'**
  String get aboutCopyDebugInfoSubtitle;

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get aboutLicenses;

  /// No description provided for @aboutLicensesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter, packages and the Lucide icon'**
  String get aboutLicensesSubtitle;

  /// No description provided for @aboutBuild.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get aboutBuild;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutCommit.
  ///
  /// In en, this message translates to:
  /// **'Commit'**
  String get aboutCommit;

  /// No description provided for @aboutBuilt.
  ///
  /// In en, this message translates to:
  /// **'Built'**
  String get aboutBuilt;

  /// No description provided for @aboutTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get aboutTheme;

  /// No description provided for @aboutCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get aboutCurrency;

  /// No description provided for @aboutLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get aboutLanguage;

  /// No description provided for @aboutMadeBy.
  ///
  /// In en, this message translates to:
  /// **'Made by xzero'**
  String get aboutMadeBy;

  /// No description provided for @aboutIconCredit.
  ///
  /// In en, this message translates to:
  /// **'Icon based on Lucide x (ISC/MIT)'**
  String get aboutIconCredit;

  /// No description provided for @aboutDebugCopied.
  ///
  /// In en, this message translates to:
  /// **'Debug info copied.'**
  String get aboutDebugCopied;

  /// No description provided for @aboutLinkError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get aboutLinkError;

  /// No description provided for @aboutLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not read app information.'**
  String get aboutLoadError;

  /// No description provided for @aboutVersionValue.
  ///
  /// In en, this message translates to:
  /// **'{version} ({build})'**
  String aboutVersionValue(String version, String build);

  /// No description provided for @aboutShareText.
  ///
  /// In en, this message translates to:
  /// **'Xzifra — a local-first expense tracker for Android.\n{url}'**
  String aboutShareText(String url);

  /// No description provided for @aboutLegalese.
  ///
  /// In en, this message translates to:
  /// **'MIT License · Made by xzero'**
  String get aboutLegalese;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
