import 'package:custom_data_table/src/core/utils/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// A widget that allows to select a date and time range.
///
/// It shows a row with two date and time pickers.
/// The first picker allows to select the start date and time.
/// The second picker allows to select the end date and time.
///
/// The widget is used to filter data by date and time.
class DateTimeRangePickerWidget extends StatelessWidget {
  /// The start date and time.
  final DateTime startDate;

  /// The end date and time.
  final DateTime endDate;

  /// The callback that is called when the start date and time changes.
  final Function(DateTime dateTime) onChangeStart;

  /// The callback that is called when the end date and time changes.
  final Function(DateTime dateTime) onChangeEnd;

  const DateTimeRangePickerWidget({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.onChangeStart,
    required this.onChangeEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: timeWidget(
            context,
            dateTime: startDate,
            onChange: onChangeStart,
          ),
        ),
        Icon(
          Icons.arrow_forward,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        Expanded(
          child: timeWidget(
            context,
            dateTime: endDate,
            onChange: onChangeEnd,
          ),
        ),
      ],
    );
  }

  /// A widget that allows to select a date and time.
  ///
  /// [context] The build context.
  /// [dateTime] The initial date and time.
  /// [onChange] The callback that is called when the date and time changes.
  ///
  /// When the date is changed, we add the time of the initial date to the new date.
  /// When the time is changed, we add the time of the new date to the initial date.
  Widget timeWidget(
    BuildContext context, {
    required DateTime dateTime,
    required Function(DateTime dateTime) onChange,
  }) {
    // Get only the date.
    final sDate = dateTime.onlyDate;

    // Get only the time.
    final sTime = dateTime.timeOfDay;

    final now = DateTime.now();

    return Wrap(
      alignment: WrapAlignment.center,
      runSpacing: 5,
      spacing: 5,
      children: [
        RawChip(
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: dateTime,
              firstDate: now.copyWith(year: now.year - 10),
              lastDate: now.copyWith(year: now.year + 1),
              builder: (context, child) => PointerInterceptor(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    child!,
                  ],
                ),
              ),
            );

            if (date == null) return;

            onChange(
              date.onlyDate.add(
                Duration(hours: sTime.hour, minutes: sTime.minute),
              ),
            );
          },
          label: Text(
            DateFormat.yMMMEd().format(dateTime),
            textAlign: TextAlign.center,
          ),
        ),
        RawChip(
          onPressed: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                hour: dateTime.hour,
                minute: dateTime.minute,
              ),
              initialEntryMode: TimePickerEntryMode.input,
              builder: (context, child) => PointerInterceptor(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Localizations.override(
                      context: context,
                      locale:
                          Localizations.localeOf(context).languageCode == 'es'
                              ? const Locale('es', 'US')
                              : null,
                      child: MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(alwaysUse24HourFormat: false),
                        child: child!,
                      ),
                    ),
                  ],
                ),
              ),
            );

            if (time == null) return;

            onChange(
              sDate.onlyDate.add(
                Duration(hours: time.hour, minutes: time.minute),
              ),
            );
          },
          label: Text(
            DateFormat('hh:mm a').format(dateTime),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
