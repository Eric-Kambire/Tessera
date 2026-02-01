import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
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
  bool _alphaMode = false;

  @override
  Widget build(BuildContext context) {
    const headerTarget = 48.0;
    const pillsTarget = 56.0;
    const gridTarget = 240.0;
    const dividerTarget = 0.5;
    const targetTotal = headerTarget + pillsTarget + gridTarget + dividerTarget;
    const desiredGridWidth = 36.0 * 6 + 1.0 * 5;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final screenHeight = MediaQuery.of(context).size.height;
        final desiredHeight = screenHeight * 0.45;
        final maxHeight = constraints.hasBoundedHeight ? constraints.maxHeight : desiredHeight;
        final baseHeight = math.max(0.0, math.min(desiredHeight, maxHeight));
        final heightScale = targetTotal == 0 ? 1.0 : baseHeight / targetTotal;
        final widthScale = desiredGridWidth == 0 ? 1.0 : width / desiredGridWidth;
        final scale = math.min(1.0, math.min(heightScale, widthScale));

        final headerHeight = headerTarget * scale;
        final pillsHeight = pillsTarget * scale;
        final dividerHeight = dividerTarget * scale;
        final gridHeight = math.max(0.0, baseHeight - headerHeight - pillsHeight - dividerHeight);

        const gridSpacing = 1.0;
        final itemExtent = math.max(
          0.0,
          math.min(
            (gridHeight - gridSpacing * 3) / 4,
            (width - gridSpacing * 5) / 6,
          ),
        );
        final keyScale = itemExtent <= 0 ? 1.0 : (itemExtent / 36.0).clamp(0.8, 1.2);
        final gridWidth = itemExtent * 6 + gridSpacing * 5;

        final activeGrid = _alphaMode ? _alphaGrid : _categories[_index].grid;

        return SafeArea(
          top: false,
          child: Container(
            height: constraints.maxHeight,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              boxShadow: [
                BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0, -4)),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: headerHeight,
                  child: _KeyboardHeader(
                    scale: scale,
                    alphaActive: _alphaMode,
                    onAlphaToggle: () => setState(() => _alphaMode = !_alphaMode),
                    onCursorLeft: widget.onCursorLeft,
                    onCursorRight: widget.onCursorRight,
                    onReturn: widget.onSubmit,
                    onBackspace: widget.onBackspace,
                  ),
                ),
                Container(height: dividerHeight, color: const Color(0xFFD1D1D6)),
                SizedBox(
                  height: pillsHeight,
                  child: _KeyboardPills(
                    index: _index,
                    onChanged: (i) {
                      setState(() {
                        _alphaMode = false;
                        _index = i;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: math.min(width, gridWidth),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) {
                          return SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(anim),
                            child: FadeTransition(opacity: anim, child: child),
                          );
                        },
                        child: _KeyGrid(
                          key: ValueKey(_alphaMode ? 'alpha' : _index.toString()),
                          keys: activeGrid,
                          spacing: gridSpacing,
                          itemExtent: itemExtent,
                          onInsert: widget.onInsert,
                          scale: keyScale,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static final _categories = <_KeyboardCategoryData>[
    _KeyboardCategoryData(
      labelTop: '+ −',
      labelBottom: '× ÷',
      grid: _basicGrid,
    ),
    _KeyboardCategoryData(
      labelTop: 'f(x) e',
      labelBottom: 'log ln',
      grid: _functionsGrid,
    ),
    _KeyboardCategoryData(
      labelTop: 'sin cos',
      labelBottom: 'tan cot',
      grid: _trigGrid,
    ),
    _KeyboardCategoryData(
      labelTop: 'lim dx',
      labelBottom: '∫ Σ ∞',
      grid: _calcGrid,
    ),
  ];
}

class _KeyboardHeader extends StatelessWidget {
  final double scale;
  final bool alphaActive;
  final VoidCallback onAlphaToggle;
  final VoidCallback onCursorLeft;
  final VoidCallback onCursorRight;
  final VoidCallback onReturn;
  final VoidCallback onBackspace;

  const _KeyboardHeader({
    required this.scale,
    required this.alphaActive,
    required this.onAlphaToggle,
    required this.onCursorLeft,
    required this.onCursorRight,
    required this.onReturn,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    final gap = 16.0 * scale;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _HeaderPill(active: alphaActive, label: 'abc', onTap: onAlphaToggle),
          SizedBox(width: gap),
          _HeaderIcon(icon: CupertinoIcons.clock, onTap: () {}),
          SizedBox(width: gap),
          _HeaderIcon(icon: CupertinoIcons.chevron_left, onTap: onCursorLeft),
          SizedBox(width: gap),
          _HeaderIcon(icon: CupertinoIcons.chevron_right, onTap: onCursorRight),
          SizedBox(width: gap),
          _HeaderIcon(icon: CupertinoIcons.arrow_turn_down_left, onTap: onReturn),
          SizedBox(width: gap),
          _HeaderIcon(icon: CupertinoIcons.delete_left, onTap: onBackspace),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final bool active;
  final String label;
  final VoidCallback onTap;

  const _HeaderPill({required this.active, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1D1D1F) : const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : const Color(0xFF1D1D1F),
          ),
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, size: 20, color: const Color(0xFF1D1D1F)),
    );
  }
}

class _KeyboardPills extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _KeyboardPills({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: List.generate(_pillLabels.length, (i) {
          final active = i == index;
          final label = _pillLabels[i];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == _pillLabels.length - 1 ? 0 : 6),
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label.top,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                          color: active ? Colors.white : const Color(0xFF1D1D1F),
                        ),
                      ),
                      Text(
                        label.bottom,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                          color: active ? Colors.white : const Color(0xFF1D1D1F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _KeyGrid extends StatelessWidget {
  final List<_KeySpec> keys;
  final double spacing;
  final double itemExtent;
  final ValueChanged<KeyboardInsert> onInsert;
  final double scale;

  const _KeyGrid({
    super.key,
    required this.keys,
    required this.spacing,
    required this.itemExtent,
    required this.onInsert,
    required this.scale,
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
        if (key.isEmpty) return const SizedBox.shrink();
        return Builder(
          builder: (itemContext) {
            return MathKey(
              label: key.label,
              onTap: () => onInsert(key.insert),
              onLongPress: key.variants.isEmpty ? null : () => _showVariants(itemContext, key),
              background: key.kind == _KeyKind.operator
                  ? const Color(0xFFE5E5EA)
                  : key.kind == _KeyKind.symbol
                      ? const Color(0xFFF8F8F8)
                      : Colors.white,
              foreground: const Color(0xFF1D1D1F),
              showDot: key.showDot,
              scale: scale,
            );
          },
        );
      },
    );
  }

  void _showVariants(BuildContext itemContext, _KeySpec key) async {
    final renderBox = itemContext.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(itemContext).context.findRenderObject() as RenderBox?;
    if (renderBox == null || overlay == null) return;

    final pos = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    final selected = await showMenu<_KeyVariant>(
      context: itemContext,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      position: RelativeRect.fromLTRB(
        pos.dx,
        pos.dy,
        overlay.size.width - pos.dx,
        overlay.size.height - pos.dy,
      ),
      items: key.variants
          .map((variant) => PopupMenuItem<_KeyVariant>(
                value: variant,
                child: Text(variant.label),
              ))
          .toList(),
    );

    if (selected != null) {
      onInsert(KeyboardInsert(text: selected.insert, selectionBackOffset: selected.caretBack));
    }
  }
}

class KeyboardInsert {
  final String text;
  final int? selectionBackOffset;

  const KeyboardInsert({required this.text, this.selectionBackOffset});
}

class _KeyboardCategoryData {
  final String labelTop;
  final String labelBottom;
  final List<_KeySpec> grid;

  const _KeyboardCategoryData({required this.labelTop, required this.labelBottom, required this.grid});
}

enum _KeyKind { number, symbol, operator }

class _KeySpec {
  final String label;
  final KeyboardInsert insert;
  final _KeyKind kind;
  final bool showDot;
  final bool isEmpty;
  final List<_KeyVariant> variants;

  const _KeySpec._({
    required this.label,
    required this.insert,
    required this.kind,
    required this.showDot,
    required this.isEmpty,
    required this.variants,
  });

  factory _KeySpec.num(String label) => _KeySpec._(
        label: label,
        insert: KeyboardInsert(text: label),
        kind: _KeyKind.number,
        showDot: false,
        isEmpty: false,
        variants: const [],
      );

  factory _KeySpec.op(String label) => _KeySpec._(
        label: label,
        insert: KeyboardInsert(text: _opToInsert(label)),
        kind: _KeyKind.operator,
        showDot: false,
        isEmpty: false,
        variants: const [],
      );

  factory _KeySpec.text(
    String label, {
    required String insert,
    int? caretBack,
    bool dot = false,
    List<_KeyVariant> variants = const [],
  }) =>
      _KeySpec._(
        label: label,
        insert: KeyboardInsert(text: insert, selectionBackOffset: caretBack),
        kind: _KeyKind.symbol,
        showDot: dot,
        isEmpty: false,
        variants: variants,
      );

  factory _KeySpec.empty() => _KeySpec._(
        label: '',
        insert: const KeyboardInsert(text: ''),
        kind: _KeyKind.symbol,
        showDot: false,
        isEmpty: true,
        variants: const [],
      );
}

class _KeyVariant {
  final String label;
  final String insert;
  final int? caretBack;

  const _KeyVariant({required this.label, required this.insert, this.caretBack});
}

class _PillLabel {
  final String top;
  final String bottom;

  const _PillLabel(this.top, this.bottom);
}

const _pillLabels = <_PillLabel>[
  _PillLabel('+ −', '× ÷'),
  _PillLabel('f(x) e', 'log ln'),
  _PillLabel('sin cos', 'tan cot'),
  _PillLabel('lim dx', '∫ Σ ∞'),
];

final _basicGrid = <_KeySpec>[
  _KeySpec.text('(□)', insert: '()', caretBack: 1, dot: true, variants: [
    _KeyVariant(label: '(□)', insert: '()', caretBack: 1),
    _KeyVariant(label: '(', insert: '('),
    _KeyVariant(label: ')', insert: ')'),
  ]),
  _KeySpec.text('>', insert: '>', dot: true, variants: [
    _KeyVariant(label: '>', insert: '>'),
    _KeyVariant(label: '≥', insert: '>='),
    _KeyVariant(label: '<', insert: '<'),
    _KeyVariant(label: '≤', insert: '<='),
  ]),
  _KeySpec.num('7'),
  _KeySpec.num('8'),
  _KeySpec.num('9'),
  _KeySpec.op('÷'),
  _KeySpec.text('□/□', insert: 'frac(,)', caretBack: 2, dot: true, variants: [
    _KeyVariant(label: '□/□', insert: 'frac(,)', caretBack: 2),
    _KeyVariant(label: '□ □/□', insert: '()/()', caretBack: 4),
  ]),
  _KeySpec.text('√□', insert: 'sqrt()', caretBack: 1, dot: true, variants: [
    _KeyVariant(label: '√□', insert: 'sqrt()', caretBack: 1),
    _KeyVariant(label: '³√□', insert: 'cbrt()', caretBack: 1),
    _KeyVariant(label: 'ⁿ√□', insert: 'root()', caretBack: 1),
  ]),
  _KeySpec.num('4'),
  _KeySpec.num('5'),
  _KeySpec.num('6'),
  _KeySpec.op('×'),
  _KeySpec.text('□²', insert: '^2', dot: true, variants: [
    _KeyVariant(label: '□²', insert: '^2'),
    _KeyVariant(label: '□³', insert: '^3'),
    _KeyVariant(label: '□ⁿ', insert: '^()' , caretBack: 1),
  ]),
  _KeySpec.text('x', insert: 'x', dot: true, variants: [
    _KeyVariant(label: 'x', insert: 'x'),
    _KeyVariant(label: 'y', insert: 'y'),
    _KeyVariant(label: 'z', insert: 'z'),
  ]),
  _KeySpec.num('1'),
  _KeySpec.num('2'),
  _KeySpec.num('3'),
  _KeySpec.op('−'),
  _KeySpec.text('π', insert: 'pi', dot: true, variants: [
    _KeyVariant(label: 'π', insert: 'pi'),
    _KeyVariant(label: 'π/2', insert: 'pi/2'),
    _KeyVariant(label: 'π/3', insert: 'pi/3'),
  ]),
  _KeySpec.text('%', insert: '%'),
  _KeySpec.num('0'),
  _KeySpec.text(',', insert: ','),
  _KeySpec.text('=', insert: '='),
  _KeySpec.op('+'),
];

final _functionsGrid = <_KeySpec>[
  _KeySpec.text('|□|', insert: 'abs()', caretBack: 1),
  _KeySpec.text('f(x)', insert: 'f()', caretBack: 1),
  _KeySpec.text('log₁₀', insert: 'log()', caretBack: 1),
  _KeySpec.text('□V', insert: 'sqrt()', caretBack: 1),
  _KeySpec.text('i', insert: 'i'),
  _KeySpec.text('∞', insert: 'inf'),
  _KeySpec.text('□', insert: '()', caretBack: 1),
  _KeySpec.text('□(□)', insert: '()()', caretBack: 1),
  _KeySpec.text('log₂', insert: 'log()', caretBack: 1),
  _KeySpec.text('P', insert: 'P'),
  _KeySpec.text('z', insert: 'z'),
  _KeySpec.text('!', insert: '!'),
  _KeySpec.text('e', insert: 'e'),
  _KeySpec.text('f(x,y)', insert: 'f(,)', caretBack: 2),
  _KeySpec.text('ln', insert: 'ln()', caretBack: 1),
  _KeySpec.text('C', insert: 'C'),
  _KeySpec.text('Σ', insert: 'sum()', caretBack: 1),
  _KeySpec.text('[□]', insert: '[]', caretBack: 1),
  _KeySpec.text('exp', insert: 'exp()', caretBack: 1),
  _KeySpec.text('□(□,□)', insert: '()(,)', caretBack: 2),
  _KeySpec.text('(□ₙ)', insert: '()', caretBack: 1),
  _KeySpec.text('sign', insert: 'sign()', caretBack: 1),
  _KeySpec.text('|□|', insert: 'abs()', caretBack: 1),
  _KeySpec.text('', insert: ''),
];

final _trigGrid = <_KeySpec>[
  _KeySpec.text('rad', insert: 'rad'),
  _KeySpec.text('sin', insert: 'sin()', caretBack: 1),
  _KeySpec.text('cos', insert: 'cos()', caretBack: 1),
  _KeySpec.text('tan', insert: 'tan()', caretBack: 1),
  _KeySpec.text('cot', insert: 'cot()', caretBack: 1),
  _KeySpec.text('sec', insert: 'sec()', caretBack: 1),
  _KeySpec.text('□°', insert: 'deg', caretBack: 0),
  _KeySpec.text('arcsin', insert: 'arcsin()', caretBack: 1),
  _KeySpec.text('arccos', insert: 'arccos()', caretBack: 1),
  _KeySpec.text('arctan', insert: 'arctan()', caretBack: 1),
  _KeySpec.text('arccot', insert: 'arccot()', caretBack: 1),
  _KeySpec.text('arcsec', insert: 'arcsec()', caretBack: 1),
  _KeySpec.text('□°□\'', insert: 'deg'),
  _KeySpec.text('sinh', insert: 'sinh()', caretBack: 1),
  _KeySpec.text('cosh', insert: 'cosh()', caretBack: 1),
  _KeySpec.text('tanh', insert: 'tanh()', caretBack: 1),
  _KeySpec.text('coth', insert: 'coth()', caretBack: 1),
  _KeySpec.text('sech', insert: 'sech()', caretBack: 1),
  _KeySpec.text('□°□\'□″', insert: 'deg'),
  _KeySpec.text('arsinh', insert: 'arsinh()', caretBack: 1),
  _KeySpec.text('arcosh', insert: 'arcosh()', caretBack: 1),
  _KeySpec.text('artanh', insert: 'artanh()', caretBack: 1),
  _KeySpec.text('arcoth', insert: 'arcoth()', caretBack: 1),
  _KeySpec.text('arsech', insert: 'arsech()', caretBack: 1),
];

final _calcGrid = <_KeySpec>[
  _KeySpec.text('lim□→□', insert: 'lim()', caretBack: 1, dot: true),
  _KeySpec.text('d/dx□', insert: 'd/dx()', caretBack: 1),
  _KeySpec.text('∫□dx', insert: 'int()', caretBack: 1),
  _KeySpec.text('dy/dx', insert: 'dy/dx'),
  _KeySpec.text('aₙ', insert: 'a_n'),
  _KeySpec.text('∞', insert: 'inf'),
  _KeySpec.text('lim□→+', insert: 'lim()', caretBack: 1, dot: true),
  _KeySpec.text('d²/dx²', insert: 'd^2/dx^2'),
  _KeySpec.text('∫□d□', insert: 'int()', caretBack: 1),
  _KeySpec.text('dx/dy', insert: 'dx/dy'),
  _KeySpec.text('□,□,…', insert: ',,', caretBack: 1),
  _KeySpec.text('Σ', insert: 'sum()', caretBack: 1),
  _KeySpec.text('lim□→−', insert: 'lim()', caretBack: 1, dot: true),
  _KeySpec.text('∂/∂x□', insert: '∂/∂x()', caretBack: 1),
  _KeySpec.text('∑□', insert: 'sum()', caretBack: 1),
  _KeySpec.text("y'", insert: "y'"),
  _KeySpec.text("''", insert: "''"),
  _KeySpec.text('Π', insert: 'pi'),
  _KeySpec.text('lim□→∞', insert: 'lim()', caretBack: 1, dot: true),
  _KeySpec.text('∂²/∂x²', insert: '∂^2/∂x^2'),
  _KeySpec.text('□', insert: '()', caretBack: 1),
  _KeySpec.text('∫□□□d□', insert: 'int()', caretBack: 1),
  _KeySpec.text('y\'\'', insert: 'y\'\''),
  _KeySpec.text('!', insert: '!'),
];

final _alphaGrid = <_KeySpec>[
  _KeySpec.text('a', insert: 'a'),
  _KeySpec.text('b', insert: 'b'),
  _KeySpec.text('c', insert: 'c'),
  _KeySpec.text('d', insert: 'd'),
  _KeySpec.text('e', insert: 'e'),
  _KeySpec.text('f', insert: 'f'),
  _KeySpec.text('g', insert: 'g'),
  _KeySpec.text('h', insert: 'h'),
  _KeySpec.text('i', insert: 'i'),
  _KeySpec.text('j', insert: 'j'),
  _KeySpec.text('k', insert: 'k'),
  _KeySpec.text('l', insert: 'l'),
  _KeySpec.text('m', insert: 'm'),
  _KeySpec.text('n', insert: 'n'),
  _KeySpec.text('o', insert: 'o'),
  _KeySpec.text('p', insert: 'p'),
  _KeySpec.text('q', insert: 'q'),
  _KeySpec.text('r', insert: 'r'),
  _KeySpec.text('s', insert: 's'),
  _KeySpec.text('t', insert: 't'),
  _KeySpec.text('u', insert: 'u'),
  _KeySpec.text('v', insert: 'v'),
  _KeySpec.text('α', insert: 'alpha'),
  _KeySpec.text('β', insert: 'beta'),
];

String _opToInsert(String op) {
  if (op == '×') return '*';
  if (op == '÷') return '/';
  if (op == '−') return '-';
  return op;
}
