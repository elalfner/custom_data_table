import 'dart:async';

import 'package:flutter/material.dart';

class DebouncerOptionsBuilder<T> {
  final int milliseconds;

  DebouncerOptionsBuilder({required this.milliseconds});

  String? lastSearch;

  Future<Iterable<T>> result(String query,
      Future<Iterable<T>> Function(String query) optionsBuilder) async {
    lastSearch = query;

    await Future.delayed(Duration(milliseconds: milliseconds));

    if (lastSearch == query) {
      return optionsBuilder(query);
    }

    return [];
  }
}

class Debouncer {
  final int milliseconds;

  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
