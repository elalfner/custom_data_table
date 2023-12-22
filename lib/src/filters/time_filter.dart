import 'package:custom_data_table/src/utils/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class TimeFilterWidget extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  final Function(DateTime dateTime) onChangeStart;
  final Function(DateTime dateTime) onChangeEnd;

  const TimeFilterWidget({
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
        const Icon(
          Icons.arrow_forward,
          color: Colors.black45,
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

  Widget timeWidget(
    BuildContext context, {
    required DateTime dateTime,
    required Function(DateTime dateTime) onChange,
  }) {
    final sDate = dateTime.onlyDate;
    final sTime = dateTime.timeOfDay;

    return Wrap(
      alignment: WrapAlignment.center,
      runSpacing: 5,
      spacing: 5,
      children: [
        Material(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: dateTime,
                firstDate:
                    DateTime.now().subtract(const Duration(days: 365 * 5)),
                lastDate: dateTime.add(const Duration(days: 365)),
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
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                DateFormat.yMMMEd().format(dateTime),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Material(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: dateTime.hour,
                  minute: dateTime.minute,
                ),
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

              if (time == null) return;

              onChange(
                sDate.onlyDate.add(
                  Duration(hours: time.hour, minutes: time.minute),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                DateFormat('hh:mm a').format(dateTime),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
