import 'package:collection/collection.dart';
import 'package:custom_data_table/l10n/localization_extension.dart';
import 'package:custom_data_table/src/core/utils/string_extension.dart';
import 'package:flutter/material.dart';

import 'package:custom_data_table/src/domain/entities/paginator_info.dart';

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
    final paginatorPerPage = paginatorInfo.perPage;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            '${context.appLocalizations.perPage.naturalCapitalized}: ',
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
        Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: paginatorInfo.perPage,
              icon: const Padding(
                padding: EdgeInsets.only(left: 0),
                child: Icon(Icons.keyboard_arrow_down_rounded),
              ),
              iconSize: 14,
              style: Theme.of(context).textTheme.bodySmall,
              borderRadius: BorderRadius.circular(10),
              underline: const SizedBox(),
              items: {
                10,
                25,
                50,
                75,
                100,
                150,
                200,
                if (paginatorPerPage != null) paginatorPerPage
              }
                  .sorted((a, b) => a.compareTo(b))
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
