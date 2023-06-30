import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../models/paginator_info.dart';

class TablePerPageWidget extends StatelessWidget {
  final PaginatorInfo paginatorInfo;

  final Function(int page)? onChange;

  const TablePerPageWidget({
    super.key,
    required this.paginatorInfo,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            'Por página: ',
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: paginatorInfo.perPage,
              icon: const Padding(
                padding: EdgeInsets.only(left: 5),
                child: Icon(Icons.keyboard_arrow_down_rounded),
              ),
              iconSize: 14,
              style: Theme.of(context).textTheme.bodySmall,
              borderRadius: BorderRadius.circular(10),
              underline: const SizedBox(),
              isDense: true,
              items: {10, 25, 50, paginatorInfo.perPage}
                  .where((element) => element != null)
                  .sorted((a, b) => a!.compareTo(b!))
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text('$e'),
                      ))
                  .toList(),
              onChanged: onChange == null
                  ? null
                  : (value) {
                      if (value == null) return;

                      onChange?.call(value);
                    },
            ),
          ),
        ),
      ],
    );
  }
}
