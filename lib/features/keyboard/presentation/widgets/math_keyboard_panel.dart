import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'math_key.dart';

class MathKeyboardPanel extends StatefulWidget {
  final ValueChanged<KeyboardInsert> onInsert;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onCursorLeft;
  final VoidCallback onCursorRight;
  final VoidCallback onSubmit;

  const MathKeyboardPanel({
    super.key,
    required this.onInsert,
    required this.onBackspace,
    required this.onClear,
    required this.onCursorLeft,
    required this.onCursorRight,
    required this.onSubmit,
  });

  @override
  State<MathKeyboardPanel> createState() => _MathKeyboardPanelState();
}

class _MathKeyboardPanelState extends State<MathKeyboardPanel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final screenHeight = MediaQuery.of(context).size.height;
        final bottomInset = MediaQuery.of(context).padding.bottom;
        final baseHeight = math.min(270.0, screenHeight * 0.38);
        final panelHeight = baseHeight + bottomInset;

        final toolbarHeight = baseHeight * 0.08;
        final tabsHeight = baseHeight * 0.12;
        const verticalPadding = 6.0;
        final gridHeight = baseHeight - toolbarHeight - tabsHeight - verticalPadding * 2;

        const gridSpacing = 1.0;
        final itemSize = math.min(
          (width - gridSpacing * 5) / 6,
          (gridHeight - gridSpacing * 3) / 4,
        );
        final actualGridHeight = itemSize * 4 + gridSpacing * 3;
        final gridWidth = itemSize * 6 + gridSpacing * 5;

        return SafeArea(
          top: false,
          child: Container(
            height: panelHeight,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              boxShadow: [
                BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0, -4)),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: toolbarHeight,
                  child: _KeyboardToolbar(
                    onCursorLeft: widget.onCursorLeft,
                    onCursorRight: widget.onCursorRight,
                    onBackspace: widget.onBackspace,
                    onSubmit: widget.onSubmit,
                    onClear: widget.onClear,
                  ),
                ),
                SizedBox(
                  height: tabsHeight,
                  child: _KeyboardTabs(
                    index: _index,
                    onChanged: (i) => setState(() => _index = i),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: verticalPadding),
                  child: SizedBox(
                    height: actualGridHeight,
                    width: gridWidth,
                    child: _KeyGrid(
                      keys: keysForCategory(_categories[_index]),
                      itemExtent: itemSize,
                      spacing: gridSpacing,
                      onInsert: widget.onInsert,
                    ),
                  ),
                ),
                if (bottomInset > 0) SizedBox(height: bottomInset),
              ],
            ),
          ),
        );
      },
    );
  }

  static final _categories = <KeyboardCategory>[
    KeyboardCategory.operations,
    KeyboardCategory.functions,
    KeyboardCategory.trigo,
    KeyboardCategory.analysis,
    KeyboardCategory.constants,
  ];
}

class _KeyboardToolbar extends StatelessWidget {
  final VoidCallback onCursorLeft;
  final VoidCallback onCursorRight;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const _KeyboardToolbar({
    required this.onCursorLeft,
    required this.onCursorRight,
    required this.onBackspace,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _ToolIcon(label: 'abc', onTap: () {}),
          const SizedBox(width: 6),
          _ToolIcon(icon: Icons.history, onTap: () {}),
          const Spacer(),
          _ToolIcon(icon: Icons.arrow_left, onTap: onCursorLeft),
          const SizedBox(width: 4),
          _ToolIcon(icon: Icons.arrow_right, onTap: onCursorRight),
          const SizedBox(width: 6),
          _ToolIcon(icon: Icons.backspace_outlined, onTap: onBackspace),
          const SizedBox(width: 6),
          _ToolIcon(icon: Icons.clear, onTap: onClear),
          const SizedBox(width: 6),
          _ToolIcon(icon: Icons.play_arrow_rounded, onTap: onSubmit, filled: true),
        ],
      ),
    );
  }
}

class _ToolIcon extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final VoidCallback onTap;
  final bool filled;

  const _ToolIcon({this.icon, this.label, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: filled ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.neutralGray.withOpacity(0.4), width: 0.5),
        ),
        child: icon != null
            ? Icon(icon, size: 14, color: filled ? Colors.white : AppColors.blackText)
            : Text(label ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
      ),
    );
  }
}

class _KeyboardTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _KeyboardTabs({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const tabs = ['Opérations', 'Fonctions', 'Trigonométrie', 'Analyse', 'Constantes'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = i == index;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == tabs.length - 1 ? 0 : 6),
              child: _PillTab(
                label: tabs[i],
                active: active,
                onTap: () => onChanged(i),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _PillTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: const Color(0xFFBDBDBD), width: 0.6),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppColors.blackText,
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyGrid extends StatelessWidget {
  final List<KeySpec> keys;
  final double itemExtent;
  final double spacing;
  final ValueChanged<KeyboardInsert> onInsert;

  const _KeyGrid({
    required this.keys,
    required this.itemExtent,
    required this.spacing,
    required this.onInsert,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: keys.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        mainAxisExtent: itemExtent,
      ),
      itemBuilder: (context, index) {
        final key = keys[index];
        return MathKey(
          label: key.label,
          onTap: () => onInsert(key.insert),
          background: key.kind == KeyKind.operator
              ? const Color(0xFFE8E8E8)
              : key.kind == KeyKind.symbol
                  ? const Color(0xFFF0F0F0)
                  : Colors.white,
          foreground: AppColors.blackText,
          showDot: key.hasLongPress,
        );
      },
    );
  }
}

enum KeyKind { number, symbol, operator }
enum KeyboardCategory { operations, functions, trigo, analysis, constants }

class KeySpec {
  final String label;
  final KeyboardInsert insert;
  final KeyKind kind;
  final bool hasLongPress;

  const KeySpec({
    required this.label,
    required this.insert,
    required this.kind,
    this.hasLongPress = false,
  });
}

class KeyboardInsert {
  final String text;
  final int? selectionBackOffset;

  const KeyboardInsert({required this.text, this.selectionBackOffset});
}

class _SymbolSpec {
  final String label;
  final String insert;
  final bool hasLongPress;

  const _SymbolSpec(this.label, this.insert, [this.hasLongPress = false]);
}

List<KeySpec> keysForCategory(KeyboardCategory category) {
  final symbols = _symbolsFor(category);
  const numbers = ['7', '8', '9', '4', '5', '6', '1', '2', '3', '0', '.', '='];
  const ops = ['+', '−', '×', '÷'];

  final output = <KeySpec>[];
  for (var row = 0; row < 4; row++) {
    final symIndex = row * 2;
    final numIndex = row * 3;
    output.add(_sym(symbols[symIndex]));
    output.add(_sym(symbols[symIndex + 1]));
    output.add(_num(numbers[numIndex]));
    output.add(_num(numbers[numIndex + 1]));
    output.add(_num(numbers[numIndex + 2]));
    output.add(_op(ops[row]));
  }
  return output;
}

KeySpec _num(String label) => KeySpec(label: label, insert: KeyboardInsert(text: label), kind: KeyKind.number);
KeySpec _sym(_SymbolSpec spec) => KeySpec(
      label: spec.label,
      insert: KeyboardInsert(text: spec.insert, selectionBackOffset: _caretOffset(spec.insert)),
      kind: KeyKind.symbol,
      hasLongPress: spec.hasLongPress,
    );
KeySpec _op(String label) => KeySpec(label: label, insert: KeyboardInsert(text: _opToInsert(label)), kind: KeyKind.operator);

int? _caretOffset(String insert) {
  if (insert.endsWith('()')) return 1;
  if (insert == 'frac(,)') return 2;
  return null;
}

String _opToInsert(String op) {
  if (op == '×') return '*';
  if (op == '÷') return '/';
  if (op == '−') return '-';
  return op;
}

List<_SymbolSpec> _symbolsFor(KeyboardCategory category) {
  switch (category) {
    case KeyboardCategory.functions:
      return const [
        _SymbolSpec('sin□', 'sin()', true),
        _SymbolSpec('cos□', 'cos()', true),
        _SymbolSpec('tan□', 'tan()', true),
        _SymbolSpec('log□', 'log()', true),
        _SymbolSpec('ln□', 'ln()', true),
        _SymbolSpec('|x|□', 'abs()', true),
        _SymbolSpec('frac□', 'frac(,)', true),
        _SymbolSpec('x²□', '^2'),
      ];
    case KeyboardCategory.trigo:
      return const [
        _SymbolSpec('sin□', 'sin()', true),
        _SymbolSpec('cos□', 'cos()', true),
        _SymbolSpec('tan□', 'tan()', true),
        _SymbolSpec('π', 'pi'),
        _SymbolSpec('(', '(', true),
        _SymbolSpec(')', ')', true),
        _SymbolSpec('√□', 'sqrt()', true),
        _SymbolSpec('|x|□', 'abs()', true),
      ];
    case KeyboardCategory.analysis:
      return const [
        _SymbolSpec('lim□', 'lim()', true),
        _SymbolSpec('∫□', 'int()', true),
        _SymbolSpec('dx', 'dx'),
        _SymbolSpec('∞', 'inf'),
        _SymbolSpec('frac□', 'frac(,)', true),
        _SymbolSpec('√□', 'sqrt()', true),
        _SymbolSpec('x²□', '^2'),
        _SymbolSpec('x³□', '^3'),
      ];
    case KeyboardCategory.constants:
      return const [
        _SymbolSpec('π', 'pi'),
        _SymbolSpec('e', 'e'),
        _SymbolSpec('∞', 'inf'),
        _SymbolSpec('(', '(', true),
        _SymbolSpec(')', ')', true),
        _SymbolSpec('√□', 'sqrt()', true),
        _SymbolSpec('∛□', 'cbrt()', true),
        _SymbolSpec('frac□', 'frac(,)', true),
      ];
    case KeyboardCategory.operations:
    default:
      return const [
        _SymbolSpec('(', '(', true),
        _SymbolSpec(')', ')', true),
        _SymbolSpec('√□', 'sqrt()', true),
        _SymbolSpec('∛□', 'cbrt()', true),
        _SymbolSpec('x²□', '^2'),
        _SymbolSpec('x³□', '^3'),
        _SymbolSpec('π', 'pi'),
        _SymbolSpec('e', 'e'),
      ];
  }
}
