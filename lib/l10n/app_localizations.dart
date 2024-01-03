import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
abstract class DataTableLocalizations {
  DataTableLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static DataTableLocalizations? of(BuildContext context) {
    return Localizations.of<DataTableLocalizations>(context, DataTableLocalizations);
  }

  static const LocalizationsDelegate<DataTableLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @showing.
  ///
  /// In en, this message translates to:
  /// **'showing'**
  String get showing;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'show'**
  String get show;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get to;

  /// No description provided for @ofLabel.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofLabel;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'results'**
  String get results;

  /// No description provided for @perPage.
  ///
  /// In en, this message translates to:
  /// **'per page'**
  String get perPage;

  /// No description provided for @moreFilters.
  ///
  /// In en, this message translates to:
  /// **'more filters'**
  String get moreFilters;

  /// No description provided for @filterDates.
  ///
  /// In en, this message translates to:
  /// **'filter dates'**
  String get filterDates;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'search'**
  String get search;

  /// No description provided for @searchAdjective.
  ///
  /// In en, this message translates to:
  /// **'search'**
  String get searchAdjective;

  /// No description provided for @filterSearch.
  ///
  /// In en, this message translates to:
  /// **'filter search'**
  String get filterSearch;

  /// No description provided for @cleanFilters.
  ///
  /// In en, this message translates to:
  /// **'clean filters'**
  String get cleanFilters;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get today;

  /// No description provided for @onlyToday.
  ///
  /// In en, this message translates to:
  /// **'Only Today'**
  String get onlyToday;

  /// No description provided for @otherDate.
  ///
  /// In en, this message translates to:
  /// **'other date'**
  String get otherDate;

  /// No description provided for @byDate.
  ///
  /// In en, this message translates to:
  /// **'date'**
  String get byDate;

  /// No description provided for @byMonth.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get byMonth;

  /// No description provided for @byOtherMonth.
  ///
  /// In en, this message translates to:
  /// **'Other Month'**
  String get byOtherMonth;

  /// No description provided for @byYear.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get byYear;

  /// No description provided for @byPeriodOfTime.
  ///
  /// In en, this message translates to:
  /// **'period of time'**
  String get byPeriodOfTime;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'select'**
  String get select;

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'results'**
  String get resultsTitle;

  /// No description provided for @showHideColumns.
  ///
  /// In en, this message translates to:
  /// **'Show/Hide columns'**
  String get showHideColumns;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'more options'**
  String get moreOptions;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'copy'**
  String get copy;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'print'**
  String get print;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'export'**
  String get export;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'all'**
  String get all;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<DataTableLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<DataTableLocalizations> load(Locale locale) {
    return SynchronousFuture<DataTableLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

DataTableLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
