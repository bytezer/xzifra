// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Xzifra';

  @override
  String get navHome => 'Inicio';

  @override
  String get navExpenses => 'Gastos';

  @override
  String get navRecords => 'Registros';

  @override
  String get navReports => 'Reportes';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionAdd => 'Agregar';

  @override
  String get actionClear => 'Limpiar';

  @override
  String get actionUndo => 'Deshacer';

  @override
  String get actionRestore => 'Restaurar';

  @override
  String get actionMoveUp => 'Subir';

  @override
  String get actionMoveDown => 'Bajar';

  @override
  String get actionArchive => 'Archivar';

  @override
  String get actionDuplicate => 'Duplicar';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get labelNone => 'Ninguno';

  @override
  String get labelOptional => 'Opcional';

  @override
  String get labelUnknownCategory => 'Categoría desconocida';

  @override
  String get labelNoPaymentMethod => 'Sin medio de pago';

  @override
  String get labelArchived => 'Archivados';

  @override
  String get categoryArchived => 'Archivada';

  @override
  String get paymentMethodArchived => 'Archivado';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get tooltipPreviousMonth => 'Mes anterior';

  @override
  String get tooltipNextMonth => 'Mes siguiente';

  @override
  String get tooltipAddExpense => 'Agregar gasto';

  @override
  String get tooltipQuickAdd => 'Agregar rápido';

  @override
  String get quickAddExpense => 'Gasto';

  @override
  String get quickAddNote => 'Nota';

  @override
  String get quickAddBookmark => 'Marcador';

  @override
  String get quickAddReminder => 'Recordatorio';

  @override
  String get tagsLabel => 'Etiquetas';

  @override
  String get tagsHint => 'Separa las etiquetas con comas';

  @override
  String get tagsAll => 'Todas';

  @override
  String get shortcutNewExpense => 'Nuevo gasto';

  @override
  String get shortcutReports => 'Reportes';

  @override
  String get widgetEmptyMessage => 'Abre Xzifra para ver este mes';

  @override
  String get dashboardSpentThisMonth => 'Gastado este mes';

  @override
  String get dashboardTopCategories => 'Categorías principales';

  @override
  String get dashboardRecentExpenses => 'Gastos recientes';

  @override
  String get dashboardViewAll => 'Ver todo';

  @override
  String get dashboardRepeatLast => 'Repetir último';

  @override
  String get dashboardNoExpensesTitle => 'Sin gastos este mes';

  @override
  String get dashboardNoExpensesMessage =>
      'Agrega tu primer gasto para ver el desglose.';

  @override
  String get dashboardAddExpense => 'Agregar gasto';

  @override
  String get dashboardNothingRecordedTitle => 'Aún no hay registros';

  @override
  String get dashboardNothingRecordedMessage =>
      'Tus últimos gastos aparecerán aquí.';

  @override
  String get dashboardLoadingPrevious => 'Cargando el mes anterior…';

  @override
  String get dashboardNoSpendingLastMonth =>
      'No hay gastos registrados el mes pasado';

  @override
  String get dashboardNoSpendingYet => 'Aún no hay gastos registrados';

  @override
  String get dashboardSameAsLastMonth => 'Igual que el mes pasado';

  @override
  String dashboardIncreased(String percent) {
    return '+$percent% vs. el mes pasado';
  }

  @override
  String dashboardDecreased(String percent) {
    return '−$percent% vs. el mes pasado';
  }

  @override
  String get dashboardRecentNotes => 'Notas recientes';

  @override
  String get dashboardBookmarks => 'Marcadores';

  @override
  String get dashboardNothingNotesTitle => 'Aún no hay notas';

  @override
  String get dashboardNothingNotesMessage => 'Captura algo y aparecerá aquí.';

  @override
  String get dashboardNothingBookmarksTitle => 'Aún no hay marcadores';

  @override
  String get dashboardNothingBookmarksMessage =>
      'Guarda enlaces para encontrarlos aquí.';

  @override
  String get dashboardAddNote => 'Agregar nota';

  @override
  String get dashboardAddBookmark => 'Agregar marcador';

  @override
  String get expensesTitle => 'Gastos';

  @override
  String get expensesFilterCategory => 'Categoría';

  @override
  String get expensesFilterPayment => 'Pago';

  @override
  String get expensesNoMatchesTitle => 'Sin resultados';

  @override
  String get expensesNoMatchesMessage =>
      'Prueba con otra categoría o medio de pago.';

  @override
  String get expensesEmptyTitle => 'Sin gastos este mes';

  @override
  String get expensesEmptyMessage => 'Toca el botón + para registrar uno.';

  @override
  String get expensesClearFilters => 'Limpiar filtros';

  @override
  String get expensesFilterByCategory => 'Filtrar por categoría';

  @override
  String get expensesFilterByPayment => 'Filtrar por medio de pago';

  @override
  String get expensesAllCategories => 'Todas las categorías';

  @override
  String get expensesAllPaymentMethods => 'Todos los medios de pago';

  @override
  String get expensesDeleteTitle => '¿Eliminar gasto?';

  @override
  String expensesDeleted(String category) {
    return 'Gasto de $category eliminado';
  }

  @override
  String get notesTitle => 'Notas';

  @override
  String get notesEmptyTitle => 'Aún no hay notas';

  @override
  String get notesEmptyMessage =>
      'Captura una idea, una lista o una cita. Se queda en este dispositivo.';

  @override
  String get notesNoMatchesTitle => 'Sin resultados';

  @override
  String get notesNoMatchesMessage => 'Prueba con otra etiqueta.';

  @override
  String get notesNewTitle => 'Nueva nota';

  @override
  String get notesEditTitle => 'Editar nota';

  @override
  String get notesNotFound => 'No se encontró la nota.';

  @override
  String get notesLoadError => 'No se pudo cargar la nota.';

  @override
  String get notesTitleLabel => 'Título';

  @override
  String get notesBodyLabel => 'Contenido';

  @override
  String get notesBodyHint => 'Escribe en texto plano o Markdown';

  @override
  String get notesTitleError => 'Escribe un título.';

  @override
  String get notesSaveError =>
      'No se pudo guardar la nota. Inténtalo de nuevo.';

  @override
  String get notesDeleted => 'Nota eliminada';

  @override
  String get notesPinned => 'Fijada';

  @override
  String get notesPin => 'Fijar nota';

  @override
  String get notesUnpin => 'Quitar fijación';

  @override
  String get notesArchive => 'Archivar nota';

  @override
  String get notesUnarchive => 'Desarchivar nota';

  @override
  String get notesArchived => 'Archivadas';

  @override
  String get notesDeleteTitle => '¿Eliminar nota?';

  @override
  String notesDeleteMessage(String title) {
    return '¿Eliminar \"$title\"? Esto no se puede deshacer.';
  }

  @override
  String get notesExportMarkdown => 'Exportar como Markdown';

  @override
  String get notesExportAll => 'Exportar todas las notas (ZIP)';

  @override
  String get notesExportError => 'No se pudo exportar la nota.';

  @override
  String get notesExportAllError => 'No se pudieron exportar las notas.';

  @override
  String get bookmarksTitle => 'Marcadores';

  @override
  String get bookmarksEmptyTitle => 'Aún no hay marcadores';

  @override
  String get bookmarksEmptyMessage =>
      'Guarda enlaces a los que quieras volver.';

  @override
  String get bookmarksNewTitle => 'Nuevo marcador';

  @override
  String get bookmarksEditTitle => 'Editar marcador';

  @override
  String get bookmarksNotFound => 'No se encontró el marcador.';

  @override
  String get bookmarksLoadError => 'No se pudo cargar el marcador.';

  @override
  String get bookmarksUrlLabel => 'URL';

  @override
  String get bookmarksUrlError => 'Ingresa un enlace http o https válido.';

  @override
  String get bookmarksTitleLabel => 'Título';

  @override
  String get bookmarksTitleHelp => 'Si lo dejas vacío, usaremos el dominio';

  @override
  String get bookmarksNoteLabel => 'Nota';

  @override
  String get bookmarksSaveError =>
      'No se pudo guardar el marcador. Inténtalo de nuevo.';

  @override
  String get bookmarksDeleted => 'Marcador eliminado';

  @override
  String get bookmarksArchive => 'Archivar marcador';

  @override
  String get bookmarksUnarchive => 'Desarchivar marcador';

  @override
  String get bookmarksArchived => 'Archivados';

  @override
  String get bookmarksDeleteTitle => '¿Eliminar marcador?';

  @override
  String bookmarksDeleteMessage(String title) {
    return '¿Eliminar \"$title\"? Esto no se puede deshacer.';
  }

  @override
  String get bookmarksOpenError => 'No se pudo abrir este enlace.';

  @override
  String get searchTitle => 'Buscar';

  @override
  String get searchHint => 'Busca gastos, notas y marcadores';

  @override
  String get searchEmptyMessage =>
      'Encuentra gastos, notas y marcadores en este dispositivo.';

  @override
  String get searchNoResultsTitle => 'Sin resultados';

  @override
  String get searchNoResultsMessage =>
      'Prueba con otra palabra o revisa la ortografía.';

  @override
  String get searchExpenses => 'Gastos';

  @override
  String get searchNotes => 'Notas';

  @override
  String get searchBookmarks => 'Marcadores';

  @override
  String get expenseNewTitle => 'Nuevo gasto';

  @override
  String get expenseEditTitle => 'Editar gasto';

  @override
  String get expenseDuplicateTitle => 'Duplicar gasto';

  @override
  String get expenseAmount => 'Monto';

  @override
  String get expenseCurrency => 'Moneda';

  @override
  String get expenseCategory => 'Categoría';

  @override
  String get expensePaymentMethod => 'Medio de pago';

  @override
  String get expenseDate => 'Fecha';

  @override
  String get expenseNote => 'Nota';

  @override
  String get expenseSave => 'Guardar gasto';

  @override
  String get expenseSaveChanges => 'Guardar cambios';

  @override
  String get expenseSaveAndAddAnother => 'Guardar y agregar otro';

  @override
  String get expenseSavedAnother => 'Gasto guardado. Agrega otro.';

  @override
  String get expenseAmountError => 'Ingresa un monto mayor que cero.';

  @override
  String get expenseCategoryError => 'Elige una categoría.';

  @override
  String get expenseSaveError =>
      'No se pudo guardar el gasto. Inténtalo de nuevo.';

  @override
  String get expenseNoCategories =>
      'Aún no hay categorías. Agrega una en Ajustes.';

  @override
  String get expenseNotFound => 'No se encontró el gasto.';

  @override
  String get expenseLoadError => 'No se pudo cargar este gasto.';

  @override
  String get expenseDateHelp => 'Fecha del gasto';

  @override
  String get reportsTitle => 'Reportes';

  @override
  String get reportsByCategory => 'Por categoría';

  @override
  String get reportsNoDataTitle => 'Sin datos este mes';

  @override
  String get reportsNoDataMessage => 'Registra un gasto para ver el desglose.';

  @override
  String get reportsTotal => 'Total';

  @override
  String get reportsLast12Months => 'Últimos 12 meses';

  @override
  String get reportsByPaymentMethod => 'Por medio de pago';

  @override
  String get reportsNoPaymentDataMessage =>
      'Los medios de pago aparecerán aquí.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeMode => 'Modo del tema';

  @override
  String get settingsThemeModeFixed => 'Oscuro (fijo en Cyber Red)';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeSystemDescription =>
      'Seguir la configuración del dispositivo';

  @override
  String get settingsThemeLightDescription => 'Usar siempre el tema claro';

  @override
  String get settingsThemeDarkDescription => 'Usar siempre el tema oscuro';

  @override
  String get settingsPreferences => 'Preferencias';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Predeterminado del sistema';

  @override
  String get settingsDefaultCurrency => 'Moneda por defecto';

  @override
  String get settingsCurrencyPEN => 'Soles (PEN)';

  @override
  String get settingsCurrencyUSD => 'Dólares (USD)';

  @override
  String get settingsManage => 'Gestionar';

  @override
  String get settingsCategories => 'Categorías';

  @override
  String get settingsCategoriesSubtitle => 'Crear, editar, ordenar o archivar';

  @override
  String get settingsPaymentMethods => 'Medios de pago';

  @override
  String get settingsPaymentMethodsSubtitle =>
      'Crea tu lista con nombre y emoji';

  @override
  String get settingsTemplates => 'Plantillas';

  @override
  String get settingsTemplatesSubtitle =>
      'Guarda gastos frecuentes para registrarlos rápido';

  @override
  String get settingsBackup => 'Copia de seguridad';

  @override
  String get settingsExportJson => 'Exportar copia JSON';

  @override
  String get settingsExportJsonSubtitle =>
      'Solo registros y datos. Usa la copia completa para incluir adjuntos.';

  @override
  String get settingsExportCsv => 'Exportar CSV';

  @override
  String get settingsExportCsvSubtitle =>
      'Abre tus gastos en una hoja de cálculo';

  @override
  String get settingsImportJson => 'Importar copia JSON';

  @override
  String get settingsImportJsonSubtitle =>
      'Combina una copia en este dispositivo';

  @override
  String get settingsAbout => 'Acerca de Xzifra';

  @override
  String get settingsAboutSubtitle => 'Versión, código fuente y licencias';

  @override
  String get settingsExportError => 'No se pudo exportar la copia.';

  @override
  String get settingsCsvError => 'No se pudo exportar el CSV.';

  @override
  String settingsImportProcessed(
    int total,
    int expenses,
    int notes,
    int bookmarks,
    int recurring,
    int reminders,
  ) {
    return 'Se procesaron $total registros ($expenses gastos, $notes notas, $bookmarks marcadores, $recurring recurrentes, $reminders recordatorios).';
  }

  @override
  String get settingsImportError => 'No se pudo importar esta copia.';

  @override
  String get settingsImportInvalid => 'Este archivo no es una copia de Xzifra.';

  @override
  String get themeIndigo => 'Índigo';

  @override
  String get themeIndigoDescription =>
      'Acentos índigo sobre superficies Material 3.';

  @override
  String get themeCyberRed => 'Cyber Red';

  @override
  String get themeCyberRedDescription =>
      'Superficies negras con acentos rojo neón.';

  @override
  String get categoriesTitle => 'Categorías';

  @override
  String get categoriesNewTitle => 'Nueva categoría';

  @override
  String get categoriesEditTitle => 'Editar categoría';

  @override
  String get categoriesName => 'Nombre';

  @override
  String get categoriesIcon => 'Ícono';

  @override
  String get categoriesColor => 'Color';

  @override
  String get categoriesArchiveDialogTitle => '¿Archivar categoría?';

  @override
  String categoriesArchiveDialogMessage(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '\"$name\" se usa en $count gastos. Archivarla conserva el historial.',
      one: '\"$name\" se usa en 1 gasto. Archivarla conserva el historial.',
    );
    return '$_temp0';
  }

  @override
  String get categoriesDeleteDialogTitle => '¿Eliminar categoría?';

  @override
  String categoriesDeleteDialogMessage(String name) {
    return '¿Eliminar \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get categoriesEmptyTitle => 'Aún no hay categorías';

  @override
  String get categoriesEmptyMessage =>
      'Agrega tu primera categoría para empezar a registrar gastos.';

  @override
  String categoriesArchiveTemplatesMessage(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '\"$name\" se usa en $count plantillas. Archivar conserva tus plantillas intactas.',
      one:
          '\"$name\" se usa en 1 plantilla. Archivar conserva tus plantillas intactas.',
    );
    return '$_temp0';
  }

  @override
  String categoriesArchiveRecurringMessage(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '\"$name\" se usa en $count gastos recurrentes. Archivar conserva tus reglas intactas.',
      one:
          '\"$name\" se usa en 1 gasto recurrente. Archivar conserva tus reglas intactas.',
    );
    return '$_temp0';
  }

  @override
  String get paymentMethodsTitle => 'Medios de pago';

  @override
  String get paymentMethodsNewTitle => 'Nuevo medio de pago';

  @override
  String get paymentMethodsEditTitle => 'Editar medio de pago';

  @override
  String get paymentMethodsName => 'Nombre';

  @override
  String get paymentMethodsType => 'Tipo';

  @override
  String get paymentMethodsArchiveDialogTitle => '¿Archivar medio de pago?';

  @override
  String paymentMethodsArchiveDialogMessage(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '\"$name\" se usa en $count gastos. Archivarlo conserva el historial.',
      one: '\"$name\" se usa en 1 gasto. Archivarlo conserva el historial.',
    );
    return '$_temp0';
  }

  @override
  String get paymentMethodsDeleteDialogTitle => '¿Eliminar medio de pago?';

  @override
  String paymentMethodsDeleteDialogMessage(String name) {
    return '¿Eliminar \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get paymentMethodsEmptyTitle => 'Aún no hay medios de pago';

  @override
  String get paymentMethodsEmptyMessage =>
      'Agrega efectivo, tarjetas o billeteras para saber cómo pagas.';

  @override
  String paymentMethodsArchiveTemplatesMessage(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '\"$name\" se usa en $count plantillas. Archivar conserva tus plantillas intactas.',
      one:
          '\"$name\" se usa en 1 plantilla. Archivar conserva tus plantillas intactas.',
    );
    return '$_temp0';
  }

  @override
  String paymentMethodsArchiveRecurringMessage(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '\"$name\" se usa en $count gastos recurrentes. Archivar conserva tus reglas intactas.',
      one:
          '\"$name\" se usa en 1 gasto recurrente. Archivar conserva tus reglas intactas.',
    );
    return '$_temp0';
  }

  @override
  String get templatesTitle => 'Plantillas';

  @override
  String get templatesNewTitle => 'Nueva plantilla';

  @override
  String get templatesEditTitle => 'Editar plantilla';

  @override
  String get templatesName => 'Nombre';

  @override
  String get templatesNameError => 'Ingresa un nombre.';

  @override
  String get templatesAmount => 'Monto';

  @override
  String get templatesCurrency => 'Moneda';

  @override
  String get templatesCategory => 'Categoría';

  @override
  String get templatesPaymentMethod => 'Medio de pago';

  @override
  String get templatesNote => 'Nota';

  @override
  String get templatesUseTemplate => 'Usar plantilla';

  @override
  String get templatesChooseTitle => 'Elige una plantilla';

  @override
  String get templatesSaveAsTemplate => 'Guardar como plantilla';

  @override
  String get templatesSaved => 'Plantilla guardada.';

  @override
  String get templatesSaveError =>
      'No se pudo guardar la plantilla. Inténtalo de nuevo.';

  @override
  String get templatesFromExpense => 'Desde un gasto';

  @override
  String get templatesPickExpense => 'Elige un gasto';

  @override
  String get templatesFromExpenseNote =>
      'Esto solo crea una plantilla. Tu gasto no cambia.';

  @override
  String get templatesNoExpenses => 'Aún no hay gastos.';

  @override
  String get templateArchived => 'Archivada';

  @override
  String get templatesEmptyTitle => 'Aún no hay plantillas';

  @override
  String get templatesEmptyMessage =>
      'Guarda gastos frecuentes para registrarlos en un par de toques.';

  @override
  String get templatesDeleteDialogTitle => '¿Eliminar plantilla?';

  @override
  String templatesDeleteDialogMessage(String name) {
    return '¿Eliminar \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get recurringTitle => 'Recurrentes';

  @override
  String get recurringNewTitle => 'Nuevo gasto recurrente';

  @override
  String get recurringEditTitle => 'Editar gasto recurrente';

  @override
  String get recurringEmptyTitle => 'Aún no hay gastos recurrentes';

  @override
  String get recurringEmptyMessage =>
      'Configura el alquiler, suscripciones u otros pagos regulares.';

  @override
  String get recurringName => 'Nombre';

  @override
  String get recurringNameError => 'Escribe un nombre.';

  @override
  String get recurringAmount => 'Monto';

  @override
  String get recurringCurrency => 'Moneda';

  @override
  String get recurringCategory => 'Categoría';

  @override
  String get recurringPaymentMethod => 'Medio de pago';

  @override
  String get recurringFrequency => 'Frecuencia';

  @override
  String get recurringInterval => 'Repetir cada';

  @override
  String get recurringIntervalError => 'Ingresa un intervalo de al menos 1.';

  @override
  String get recurringNextDate => 'Próxima fecha';

  @override
  String get recurringEndDate => 'Fecha de fin (opcional)';

  @override
  String get recurringNoEndDate => 'Sin fecha de fin';

  @override
  String get recurringNote => 'Nota';

  @override
  String get recurringActive => 'Activo';

  @override
  String get recurringDueNow => 'Vence ahora';

  @override
  String get recurringPaused => 'En pausa';

  @override
  String get recurringPause => 'Pausar';

  @override
  String get recurringResume => 'Reanudar';

  @override
  String get recurringRegister => 'Registrar';

  @override
  String get recurringSkip => 'Omitir';

  @override
  String recurringRegistered(String name) {
    return 'Gasto de $name registrado.';
  }

  @override
  String recurringSkipped(String name) {
    return 'Se omitió $name.';
  }

  @override
  String get recurringDeleteTitle => '¿Eliminar gasto recurrente?';

  @override
  String recurringDeleteMessage(String name) {
    return '¿Eliminar \"$name\"? Los gastos anteriores se conservan.';
  }

  @override
  String get recurringSaveError => 'No se pudo guardar el gasto recurrente.';

  @override
  String get recurringNotFound => 'No se encontró el gasto recurrente.';

  @override
  String get recurringLoadError => 'No se pudo cargar el gasto recurrente.';

  @override
  String get recurringFrequencyDaily => 'Diario';

  @override
  String get recurringFrequencyWeekly => 'Semanal';

  @override
  String get recurringFrequencyMonthly => 'Mensual';

  @override
  String get recurringFrequencyYearly => 'Anual';

  @override
  String recurringEveryInterval(int count, String frequency) {
    return 'Cada $count · $frequency';
  }

  @override
  String recurringNextLabel(String date) {
    return 'Próximo: $date';
  }

  @override
  String get recurringEndDateError =>
      'La fecha de fin debe ser igual o posterior a la próxima fecha.';

  @override
  String get remindersTitle => 'Recordatorios';

  @override
  String get remindersEmptyTitle => 'Aún no hay recordatorios';

  @override
  String get remindersEmptyMessage =>
      'Agrega un recordatorio y recibe una notificación local cuando venza.';

  @override
  String get remindersNewTitle => 'Nuevo recordatorio';

  @override
  String get remindersEditTitle => 'Editar recordatorio';

  @override
  String get remindersNotFound => 'No se encontró el recordatorio.';

  @override
  String get remindersLoadError => 'No se pudo cargar el recordatorio.';

  @override
  String get remindersTitleLabel => 'Título';

  @override
  String get remindersNoteLabel => 'Nota';

  @override
  String get remindersDue => 'Fecha y hora de vencimiento';

  @override
  String get remindersTitleError => 'Escribe un título.';

  @override
  String get remindersSaveError => 'No se pudo guardar el recordatorio.';

  @override
  String get remindersDeleted => 'Recordatorio eliminado.';

  @override
  String get remindersDeleteTitle => '¿Eliminar recordatorio?';

  @override
  String remindersDeleteMessage(String title) {
    return '¿Eliminar \"$title\"? Esto no se puede deshacer.';
  }

  @override
  String get remindersMarkDone => 'Marcar como hecho';

  @override
  String get remindersMarkUndone => 'Marcar como pendiente';

  @override
  String get remindersOverdue => 'Vencidos';

  @override
  String get remindersToday => 'Hoy';

  @override
  String get remindersUpcoming => 'Próximos';

  @override
  String get remindersDone => 'Hechos';

  @override
  String get remindersNoMatchesTitle => 'Sin resultados';

  @override
  String get remindersNoMatchesMessage => 'Prueba con otra etiqueta.';

  @override
  String get remindersNotificationsDenied =>
      'Recordatorio guardado. Las notificaciones están desactivadas, así que no recibirás un aviso.';

  @override
  String get dashboardUpcomingPayments => 'Próximos pagos';

  @override
  String get dashboardNoUpcomingPaymentsTitle => 'No hay próximos pagos';

  @override
  String get dashboardNoUpcomingPaymentsMessage =>
      'Agrega un gasto recurrente para verlo aquí.';

  @override
  String get dashboardUpcomingReminders => 'Próximos recordatorios';

  @override
  String get dashboardNoUpcomingRemindersTitle =>
      'No hay próximos recordatorios';

  @override
  String get dashboardNoUpcomingRemindersMessage =>
      'Agrega un recordatorio para verlo aquí.';

  @override
  String get attachmentsTitle => 'Archivos adjuntos';

  @override
  String get attachmentsEmpty => 'No hay archivos adjuntos.';

  @override
  String get attachmentsAdd => 'Agregar adjunto';

  @override
  String get attachmentsCamera => 'Cámara';

  @override
  String get attachmentsGallery => 'Galería';

  @override
  String get attachmentsFile => 'Archivo';

  @override
  String get attachmentsSaveFirst => 'Guarda primero para adjuntar archivos.';

  @override
  String get attachmentsDeleteTitle => '¿Eliminar adjunto?';

  @override
  String attachmentsDeleteMessage(String name) {
    return '¿Eliminar \"$name\"? Esto no se puede deshacer.';
  }

  @override
  String get attachmentsMissing => 'Este archivo no está en el dispositivo.';

  @override
  String get attachmentsOpenError => 'No se pudo abrir este archivo.';

  @override
  String get attachmentsAddError => 'No se pudo agregar este adjunto.';

  @override
  String get attachmentsTooLarge =>
      'Este archivo es demasiado grande. Los adjuntos pueden pesar hasta 25 MB.';

  @override
  String get settingsExportFullBackup => 'Exportar copia completa (ZIP)';

  @override
  String get settingsExportFullBackupSubtitle =>
      'Registros y todos los archivos adjuntos';

  @override
  String get settingsImportFullBackup => 'Importar copia completa (ZIP)';

  @override
  String get settingsImportFullBackupSubtitle =>
      'Combina registros y restaura los adjuntos';

  @override
  String get settingsFullBackupExportError =>
      'No se pudo exportar la copia completa.';

  @override
  String get shortcutNewNote => 'Nueva nota';

  @override
  String get shortcutNewReminder => 'Nuevo recordatorio';

  @override
  String get widgetNextUpPrefix => 'Próximo';

  @override
  String get bookmarksExportAll => 'Exportar marcadores (ZIP)';

  @override
  String get bookmarksExportAllError =>
      'No se pudieron exportar los marcadores.';

  @override
  String get notesActions => 'Acciones de la nota';

  @override
  String get bookmarksActions => 'Acciones del marcador';

  @override
  String get remindersActions => 'Acciones del recordatorio';

  @override
  String get recurringActions => 'Acciones del gasto recurrente';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutTagline => 'Un registro de gastos local-first para Android.';

  @override
  String get aboutDataPrivacyTitle => 'Datos y privacidad';

  @override
  String get aboutDataPrivacy =>
      'Todos los gastos, categorías y ajustes viven en una base de datos SQLite en este dispositivo. Xzifra no tiene cuentas, ni analíticas, ni acceso a la red. Exporta una copia JSON antes de desinstalar la app.';

  @override
  String get aboutProject => 'Proyecto';

  @override
  String get aboutSourceCode => 'Código fuente';

  @override
  String get aboutSourceCodeSubtitle => 'github.com/bytezer/xzifra';

  @override
  String get aboutReleases => 'Versiones y actualizaciones';

  @override
  String get aboutReleasesSubtitle => 'Descarga la última beta';

  @override
  String get aboutReportIssue => 'Reportar un problema';

  @override
  String get aboutReportIssueSubtitle => 'Abrir un issue en GitHub';

  @override
  String get aboutShareApp => 'Compartir app';

  @override
  String get aboutShareAppSubtitle => 'Enviar el enlace de la versión';

  @override
  String get aboutMitLicense => 'Licencia MIT';

  @override
  String get aboutMitLicenseSubtitle => 'Ver la licencia en GitHub';

  @override
  String get aboutDiagnostics => 'Diagnóstico';

  @override
  String get aboutCopyDebugInfo => 'Copiar información de depuración';

  @override
  String get aboutCopyDebugInfoSubtitle => 'Versión, build, commit y ajustes';

  @override
  String get aboutLicenses => 'Licencias de código abierto';

  @override
  String get aboutLicensesSubtitle => 'Flutter, paquetes y el icono de Lucide';

  @override
  String get aboutBuild => 'Compilación';

  @override
  String get aboutVersion => 'Versión';

  @override
  String get aboutCommit => 'Commit';

  @override
  String get aboutBuilt => 'Compilado';

  @override
  String get aboutTheme => 'Tema';

  @override
  String get aboutCurrency => 'Moneda';

  @override
  String get aboutLanguage => 'Idioma';

  @override
  String get aboutMadeBy => 'Hecho por xzero';

  @override
  String get aboutIconCredit => 'Icono basado en Lucide x (ISC/MIT)';

  @override
  String get aboutDebugCopied => 'Información de depuración copiada.';

  @override
  String get aboutLinkError => 'No se pudo abrir el enlace.';

  @override
  String get aboutLoadError => 'No se pudo leer la información de la app.';

  @override
  String aboutVersionValue(String version, String build) {
    return '$version ($build)';
  }

  @override
  String aboutShareText(String url) {
    return 'Xzifra — un registro de gastos local-first para Android.\n$url';
  }

  @override
  String get aboutLegalese => 'Licencia MIT · Hecho por xzero';
}
