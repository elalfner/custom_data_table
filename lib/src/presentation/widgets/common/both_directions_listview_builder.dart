import 'package:flutter/material.dart';

/// A widget that builds a list of widgets in both directions.
///
/// It is used to put in the center of the list the [initIndex] and build
/// the list in both directions from the center.
class BothDirectionsListViewBuilder extends StatefulWidget {
  /// The builder function that builds the widgets.
  final IndexedWidgetBuilder itemBuilder;

  /// The starting index of the list.
  final int startIndex;

  /// The index of the center of the list.
  final int initIndex;

  /// The last index of the list.
  final int lastIndex;

  /// The maximum number of items visible in the list.
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
  /// The center key of the list.
  final UniqueKey _center = UniqueKey();

  /// The axis direction of the list.
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

      viewPort = lastIndex == 0
          ? 0
          : initIndex * ((itemsVisible - 1) / itemsVisible) / lastIndex;
    } else {
      viewPort = ((initIndex) / (lastIndex + 1));
    }

    if (viewPort.isNegative || viewPort.isNaN) viewPort = 0;

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

  /// Builds a list of widgets in the given direction.
  ///
  /// [isForward] indicates if the list is built in forward direction.
  /// [initIndex] is the index of the center of the list.
  /// [startIndex] is the starting index of the list.
  /// [lastIndex] is the last index of the list.
  Widget _getList({
    required bool isForward,
    required int initIndex,
    required int startIndex,
    required int lastIndex,
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

  /// Builds a widget at the given index.
  ///
  /// [index] is the index of the widget to build.
  Widget item(int index) => widget.itemBuilder(context, index);
}
