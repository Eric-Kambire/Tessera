import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class LatexView extends StatelessWidget {
  final String latex;
  final TextStyle? textStyle;
  final bool adaptToWidth;
  final bool allowScroll;

  const LatexView({
    super.key,
    required this.latex,
    this.textStyle,
    this.adaptToWidth = true,
    this.allowScroll = true,
  });

  @override
  Widget build(BuildContext context) {
    if (latex.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    Widget content = Math.tex(
      latex,
      textStyle: textStyle ?? Theme.of(context).textTheme.bodyMedium,
      mathStyle: MathStyle.text,
    );

    if (adaptToWidth) {
      content = FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: content,
      );
    }

    if (!allowScroll) {
      return content;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: content,
    );
  }
}
