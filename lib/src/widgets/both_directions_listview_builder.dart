import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BothDirectionsListViewBuilder extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;

  final int startIndex;
  final int initIndex;
  final int lastIndex;

  final int? maxItemsVisible;

  const BothDirectionsListViewBuilder({
    super.key,
    required this.itemBuilder,
    required this.startIndex,
    required this.initIndex,
    required this.lastIndex,
    this.maxItemsVisible,
  });

  @override
  State<BothDirectionsListViewBuilder> createState() =>
      _BothDirectionsListViewBuilderState();
}

class _BothDirectionsListViewBuilderState
    extends State<BothDirectionsListViewBuilder> {
  final UniqueKey _center = UniqueKey();
  final AxisDirection _axisDirection = AxisDirection.down;

  @override
  Widget build(BuildContext context) {
    final startIndex = widget.startIndex;
    final initIndex = widget.initIndex;
    final lastIndex = widget.lastIndex;

    final maxItemsVisible = widget.maxItemsVisible;

    double viewPort;

    if (maxItemsVisible != null) {
      int itemsVisible = maxItemsVisible;
      if (lastIndex < maxItemsVisible) itemsVisible = lastIndex + 1;

      viewPort = initIndex * ((itemsVisible - 1) / itemsVisible) / lastIndex;
    } else {
      viewPort = ((initIndex) / (lastIndex + 1));
    }

    if (viewPort.isNegative) viewPort = 0;

    return Scaffold(
      body: CustomScrollView(
        reverse: axisDirectionIsReversed(_axisDirection),
        scrollDirection: axisDirectionToAxis(_axisDirection),
        anchor: viewPort,
        center: _center,
        slivers: <Widget>[
          _getList(
            isForward: false,
            initIndex: initIndex,
            startIndex: startIndex,
            lastIndex: lastIndex,
          ),
          SliverToBoxAdapter(
            key: _center,
            child: item(initIndex),
          ),
          _getList(
            isForward: true,
            initIndex: initIndex,
            startIndex: startIndex,
            lastIndex: lastIndex,
          ),
        ],
      ),
    );
  }

  Widget _getList({
    required bool isForward,
    required initIndex,
    required startIndex,
    required lastIndex,
  }) {
    return SliverList.builder(
      itemCount: isForward ? lastIndex - initIndex : initIndex - startIndex,
      itemBuilder: (BuildContext context, int index) {
        index = index + 1;
        final newIndex = isForward ? initIndex + index : initIndex - index;
        return item(newIndex);
      },
    );
  }

  Widget item(int index) => widget.itemBuilder(context, index);
}
