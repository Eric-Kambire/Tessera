import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class LatexView extends StatelessWidget {
  final String latex;
  final TextStyle? textStyle;

  const LatexView({
    super.key,
    required this.latex,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (latex.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Math.tex(
      latex,
      textStyle: textStyle ?? Theme.of(context).textTheme.bodyMedium,
      mathStyle: MathStyle.text,
    );
  }
}
