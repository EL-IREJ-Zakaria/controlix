import 'package:flutter/material.dart';

Color colorFromHex(String hexColor) {
  final normalized = hexColor.replaceFirst('#', '');
  final safeHex = normalized.length == 6 ? 'FF$normalized' : normalized;
  return Color(int.parse(safeHex, radix: 16));
}
