import 'dart:math';

import 'package:custom_data_table/src/core/utils/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A widget that displays a month picker.
///
/// This widget is used to display a month picker.
/// The picker allows the user to select a month and year.
/// The picker is displayed in a dialog.
class CustomMonthPicker extends StatefulWidget {
  /// The initial date to display in the picker.
  ///
  /// If null, the current date is used.
  final DateTime? initialDate;

  /// The first date that can be selected in the picker.
  ///
  /// If null, the current date minus 10 years is used.
  final DateTime? firstDate;

  /// The last date that can be selected in the picker.
  ///
  /// If null, the current month is used.
  final DateTime? lastDate;

  const CustomMonthPicker(
      {super.key, this.initialDate, this.firstDate, this.lastDate});

  @override
  State<CustomMonthPicker> createState() => _CustomMonthPickerState();
}

class _CustomMonthPickerState extends State<CustomMonthPicker> {
  /// The current date to display in the picker.
  late DateTime date;

  /// The last date that can be selected in the picker.
  late DateTime lastDate;

  /// The first date that can be selected in the picker.
  late DateTime firstDate;

  /// If true, the year picker is shown.
  ///
  /// If false, the month picker is shown.
  bool showYear = false;

  @override
  void initState() {
    date = (widget.initialDate ?? DateTime.now()).onlyMonth;
    firstDate = widget.firstDate ?? DateTime(date.year - 10);
    lastDate = widget.lastDate ?? DateTime.now().onlyMonth;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 550,
        child: LayoutBuilder(
          builder: (context, constaints) {
            /// If the max width is less than 550, the picker is displayed in a column.
            /// Otherwise, the picker is displayed in a row.
            if (constaints.maxWidth < 550) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      width: 300,
                      constraints: const BoxConstraints(maxHeight: 450),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: selectedInfoWidget(),
                          ),
                          const Divider(),
                          Expanded(
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 300),
                              width: 300,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Expanded(child: pickerBody()),
                                  Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      buttons(),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    height: 300,
                    width: 450,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 150,
                          padding: const EdgeInsets.all(20),
                          child: selectedInfoWidget(),
                        ),
                        const VerticalDivider(),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Expanded(
                                  child: pickerBody(),
                                ),
                                const SizedBox(height: 10),
                                buttons(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Widget that displays the selected month and year.
  Widget selectedInfoWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          MaterialLocalizations.of(context).datePickerHelpText,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 30),
        Text(
          DateFormat.yMMM().format(date),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }

  /// Widget that displays the picker body.
  ///
  /// If [showYear] is true, the year picker is shown.
  /// Otherwise, the month picker is shown.
  Widget pickerBody() {
    return Column(
      children: [
        selectYearButton(),
        if (showYear)
          Expanded(
            child: yearPicker(),
          )
        else
          Expanded(
            child: monthPicker(),
          ),
      ],
    );
  }

  /// Widget that displays the select year button.
  ///
  /// If [showYear] is true, the year picker is shown.
  /// Otherwise, the month picker is shown.
  Widget selectYearButton() {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                showYear = !showYear;
                setState(() {});
              },
              child: Row(
                children: [
                  Text(
                    date.year.toString(),
                  ),
                  const SizedBox(width: 20),
                  Icon(
                    showYear
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Widget that displays the month picker.
  Widget monthPicker() {
    return GridView.builder(
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemCount: 12,
      padding: const EdgeInsets.only(top: 20),
      itemBuilder: (context, index) {
        final month = index + 1;
        final selected = date.month == month;

        final itemDate = date.copyWith(month: month);

        final enabled =
            (itemDate.isAfter(firstDate) || firstDate == itemDate) &&
                (itemDate.isBefore(lastDate) || lastDate == itemDate);

        return Center(
          child: TextButton(
            onPressed: !enabled
                ? null
                : () {
                    date = itemDate;
                    setState(() {});
                  },
            style: TextButton.styleFrom(
              backgroundColor:
                  !selected ? null : Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              DateFormat.MMM().format(itemDate),
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: selected
                        ? Colors.white
                        : enabled
                            ? null
                            : Theme.of(context).disabledColor,
                  ),
            ),
          ),
        );
      },
    );
  }

  /// Widget that displays the year picker.
  Widget yearPicker() {
    const crossAxisCount = 4;

    final rows =
        max(3, ((lastDate.year - firstDate.year + 1) ~/ crossAxisCount));

    final itemCount = crossAxisCount * (rows + 1);

    return GridView.builder(
      reverse: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount),
      itemCount: itemCount,
      padding: const EdgeInsets.only(top: 20),
      itemBuilder: (context, index) {
        final row = index ~/ crossAxisCount;

        final newIndex = (row * crossAxisCount) +
            (crossAxisCount - 1) -
            (index % crossAxisCount);

        final year = lastDate.year - newIndex;

        final selected = date.year == year;

        final enabled = year >= firstDate.year;

        return Center(
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor:
                  !selected ? null : Theme.of(context).colorScheme.primary,
            ),
            onPressed: !enabled
                ? null
                : () {
                    DateTime newDate = date.copyWith(year: year);

                    if (newDate.isBefore(firstDate)) newDate = firstDate;

                    date = newDate;

                    showYear = false;
                    setState(() {});
                  },
            child: Text(
              year.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: selected
                        ? Colors.white
                        : enabled
                            ? null
                            : Theme.of(context).disabledColor,
                    fontSize: 14,
                  ),
            ),
          ),
        );
      },
    );
  }

  /// Widget that displays dialog buttons.
  Widget buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(date);
          },
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}

/// Shows a dialog that allows the user to select a month and year.
///
/// [context] is the build context.
/// [initialDate] is the initial date to display.
/// [firstDate] is the first date that can be selected.
/// [lastDate] is the last date that can be selected.
/// [builder] is a builder that can be used to customize the dialog.
///
/// Returns the selected date or `null` if the dialog is dismissed.
Future<DateTime?> showMonthPicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  TransitionBuilder? builder,
}) async {
  final dialog = CustomMonthPicker(
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return builder == null ? dialog : builder(context, dialog);
    },
  );
}
