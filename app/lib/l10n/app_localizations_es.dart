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
  String get shortcutNewExpense => 'Nuevo gasto';

  @override
  String get shortcutReports => 'Reportes';

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
  String get settingsBackup => 'Copia de seguridad';

  @override
  String get settingsExportJson => 'Exportar copia JSON';

  @override
  String get settingsExportJsonSubtitle =>
      'Copia completa que puedes importar después';

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
  String settingsImportProcessed(int total, int expenses) {
    return 'Se procesaron $total registros ($expenses gastos).';
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
