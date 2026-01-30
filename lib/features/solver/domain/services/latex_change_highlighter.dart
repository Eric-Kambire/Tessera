import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_colors.dart';

@LazySingleton()
class LatexChangeHighlighter {
  String apply(String latex, List<List<int>> indices) {
    if (indices.isEmpty) return latex;

    final sorted = List<List<int>>.from(indices)
      ..sort((a, b) => b[0].compareTo(a[0]));

    var result = latex;
    for (final pair in sorted) {
      if (pair.length < 2) continue;
      final start = pair[0];
      final end = pair[1];
      if (start < 0 || end > result.length || start >= end) continue;
      final before = result.substring(0, start);
      final mid = result.substring(start, end);
      final after = result.substring(end);
      result = '$before\\textcolor{${_hex(AppColors.tertiaryOrange)}}{$mid}$after';
    }
    return result;
  }

  String _hex(Color color) {
    final value = color.value & 0xFFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0')}';
  }
}
