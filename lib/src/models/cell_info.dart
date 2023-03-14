import 'package:flutter/material.dart';

class CellInfo {
  final String text;
  final dynamic value;

  final Widget? child;

  CellInfo({
    required this.text,
    required this.value,
    this.child,
  });
}
