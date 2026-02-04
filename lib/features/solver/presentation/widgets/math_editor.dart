import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum _ChildSlot { numerator, denominator, radicand, exponent, argument, integrand, base }

class _CursorStep {
  final int nodeIndex;
  final _ChildSlot slot;

  const _CursorStep(this.nodeIndex, this.slot);
}

class _CursorPath {
  final List<_CursorStep> steps;
  final int index;

  const _CursorPath({required this.steps, required this.index});

  _CursorPath copyWith({List<_CursorStep>? steps, int? index}) {
    return _CursorPath(steps: steps ?? this.steps, index: index ?? this.index);
  }
}

class MathEditorController extends ChangeNotifier {
  final _MathList _root = _MathList();
  _CursorPath _cursor = const _CursorPath(steps: [], index: 0);

  String get raw => _root.toRaw();
  bool get isEmpty => _root.nodes.isEmpty;

  _MathList _activeList() {
    _MathList current = _root;
    for (final step in _cursor.steps) {
      final node = current.nodes[step.nodeIndex];
      if (node is _HasChildren) {
        current = (node as _HasChildren).childFor(step.slot);
      }
    }
    return current;
  }

  _CursorPath _parentPath() {
    if (_cursor.steps.isEmpty) return _cursor;
    final steps = List<_CursorStep>.from(_cursor.steps)..removeLast();
    final parentIndex = _cursor.steps.last.nodeIndex;
    return _CursorPath(steps: steps, index: parentIndex);
  }

  void setCursor(_CursorPath cursor) {
    _cursor = cursor;
    notifyListeners();
  }

  void clear() {
    _root.nodes.clear();
    _cursor = const _CursorPath(steps: [], index: 0);
    notifyListeners();
  }

  void moveCursorToRootEnd() {
    _cursor = _CursorPath(steps: const [], index: _root.nodes.length);
    notifyListeners();
  }

  bool isActivePath(List<_CursorStep> steps) {
    if (steps.length != _cursor.steps.length) return false;
    for (var i = 0; i < steps.length; i++) {
      if (steps[i].nodeIndex != _cursor.steps[i].nodeIndex) return false;
      if (steps[i].slot != _cursor.steps[i].slot) return false;
    }
    return true;
  }

  int cursorIndexFor(List<_CursorStep> steps) {
    return isActivePath(steps) ? _cursor.index : -1;
  }

  void insertText(String text) {
    if (text.isEmpty) return;
    final list = _activeList();
    list.nodes.insert(_cursor.index, _TextNode(text));
    _cursor = _cursor.copyWith(index: _cursor.index + 1);
    notifyListeners();
  }

  void insertFraction() {
    final list = _activeList();
    list.nodes.insert(_cursor.index, _FractionNode());
    final steps = List<_CursorStep>.from(_cursor.steps)
      ..add(_CursorStep(_cursor.index, _ChildSlot.numerator));
    _cursor = _CursorPath(steps: steps, index: 0);
    notifyListeners();
  }

  void insertSqrt() {
    final list = _activeList();
    list.nodes.insert(_cursor.index, _SqrtNode());
    final steps = List<_CursorStep>.from(_cursor.steps)
      ..add(_CursorStep(_cursor.index, _ChildSlot.radicand));
    _cursor = _CursorPath(steps: steps, index: 0);
    notifyListeners();
  }

  void insertIntegral() {
    final list = _activeList();
    list.nodes.insert(_cursor.index, _IntegralNode());
    final steps = List<_CursorStep>.from(_cursor.steps)
      ..add(_CursorStep(_cursor.index, _ChildSlot.integrand));
    _cursor = _CursorPath(steps: steps, index: 0);
    notifyListeners();
  }

  void insertFunction(String name) {
    final list = _activeList();
    list.nodes.insert(_cursor.index, _FunctionNode(name));
    final steps = List<_CursorStep>.from(_cursor.steps)
      ..add(_CursorStep(_cursor.index, _ChildSlot.argument));
    _cursor = _CursorPath(steps: steps, index: 0);
    notifyListeners();
  }

  void insertGroup() {
    final list = _activeList();
    list.nodes.insert(_cursor.index, _GroupNode());
    final steps = List<_CursorStep>.from(_cursor.steps)
      ..add(_CursorStep(_cursor.index, _ChildSlot.argument));
    _cursor = _CursorPath(steps: steps, index: 0);
    notifyListeners();
  }

  void insertAbsolute() {
    final list = _activeList();
    list.nodes.insert(_cursor.index, _AbsoluteNode());
    final steps = List<_CursorStep>.from(_cursor.steps)
      ..add(_CursorStep(_cursor.index, _ChildSlot.argument));
    _cursor = _CursorPath(steps: steps, index: 0);
    notifyListeners();
  }

  void insertPower() {
    final list = _activeList();
    if (_cursor.index == 0) {
      list.nodes.insert(_cursor.index, _PowerNode(_PlaceholderNode()));
      final steps = List<_CursorStep>.from(_cursor.steps)
        ..add(_CursorStep(_cursor.index, _ChildSlot.exponent));
      _cursor = _CursorPath(steps: steps, index: 0);
      notifyListeners();
      return;
    }
    final base = list.nodes.removeAt(_cursor.index - 1);
    final power = _PowerNode(base);
    list.nodes.insert(_cursor.index - 1, power);
    final steps = List<_CursorStep>.from(_cursor.steps)
      ..add(_CursorStep(_cursor.index - 1, _ChildSlot.exponent));
    _cursor = _CursorPath(steps: steps, index: 0);
    notifyListeners();
  }

  void backspace() {
    final list = _activeList();
    if (_cursor.index > 0) {
      list.nodes.removeAt(_cursor.index - 1);
      _cursor = _cursor.copyWith(index: _cursor.index - 1);
      notifyListeners();
      return;
    }
    if (_cursor.steps.isEmpty) return;
    final parent = _parentPath();
    final parentList = _listAtPath(parent.steps);
    if (parentList.nodes.isNotEmpty && parent.index < parentList.nodes.length) {
      parentList.nodes.removeAt(parent.index);
      _cursor = parent;
      notifyListeners();
    }
  }

  void moveCursor(int delta) {
    final list = _activeList();
    if (_cursor.steps.isNotEmpty) {
      final last = _cursor.steps.last;
      final parentList = _listAtPath(_cursor.steps.sublist(0, _cursor.steps.length - 1));
      final parentNode = parentList.nodes[last.nodeIndex];
      if (parentNode is _FractionNode) {
        if (delta > 0 &&
            last.slot == _ChildSlot.numerator &&
            _cursor.index == list.nodes.length) {
          final steps = List<_CursorStep>.from(_cursor.steps)
            ..removeLast()
            ..add(_CursorStep(last.nodeIndex, _ChildSlot.denominator));
          _cursor = _CursorPath(steps: steps, index: 0);
          notifyListeners();
          return;
        }
        if (delta < 0 && last.slot == _ChildSlot.denominator && _cursor.index == 0) {
          final steps = List<_CursorStep>.from(_cursor.steps)
            ..removeLast()
            ..add(_CursorStep(last.nodeIndex, _ChildSlot.numerator));
          final numerator = parentNode.numerator;
          _cursor = _CursorPath(steps: steps, index: numerator.nodes.length);
          notifyListeners();
          return;
        }
      }
    }
    if (delta < 0) {
      if (_cursor.index > 0) {
        _cursor = _cursor.copyWith(index: _cursor.index - 1);
        notifyListeners();
        return;
      }
      if (_cursor.steps.isNotEmpty) {
        _cursor = _parentPath();
        notifyListeners();
      }
      return;
    }
    if (_cursor.index < list.nodes.length) {
      _cursor = _cursor.copyWith(index: _cursor.index + 1);
      notifyListeners();
      return;
    }
    if (_cursor.steps.isNotEmpty) {
      final parent = _parentPath();
      _cursor = parent.copyWith(index: parent.index + 1);
      notifyListeners();
    }
  }

  _MathList _listAtPath(List<_CursorStep> steps) {
    _MathList current = _root;
    for (final step in steps) {
      final node = current.nodes[step.nodeIndex];
      if (node is _HasChildren) {
        current = (node as _HasChildren).childFor(step.slot);
      }
    }
    return current;
  }
}

class MathEditor extends StatelessWidget {
  final MathEditorController controller;
  final double fontSize;
  final VoidCallback onTap;

  const MathEditor({
    super.key,
    required this.controller,
    required this.fontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onTap,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildList(context, controller, controller._root, const [], fontSize),
          ),
        );
      },
    );
  }

}

Widget _buildList(
  BuildContext context,
  MathEditorController controller,
  _MathList list,
  List<_CursorStep> path,
  double fontSize,
) {
  final isActive = controller.isActivePath(path);
  final cursorIndex = controller.cursorIndexFor(path);
  final children = <Widget>[];
  if (list.nodes.isEmpty) {
    if (isActive && cursorIndex == 0) {
      children.add(_Caret(height: fontSize * 1.1));
    }
    children.add(
      GestureDetector(
        onTap: () => controller.setCursor(_CursorPath(steps: path, index: 0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: _PlaceholderBox(size: fontSize * 0.5),
        ),
      ),
    );
  } else {
    for (var i = 0; i < list.nodes.length; i++) {
      if (isActive && cursorIndex == i) {
        children.add(_Caret(height: fontSize * 1.1));
      }
      children.add(list.nodes[i].build(context, controller, path, i, fontSize));
    }
    if (isActive && cursorIndex == list.nodes.length) {
      children.add(_Caret(height: fontSize * 1.1));
    }
  }
  return Row(mainAxisSize: MainAxisSize.min, children: children);
}

abstract class _MathNode {
  Widget build(
    BuildContext context,
    MathEditorController controller,
    List<_CursorStep> parentPath,
    int index,
    double fontSize,
  );

  String toRaw();
}

abstract class _HasChildren {
  _MathList childFor(_ChildSlot slot);
}

class _MathList {
  final List<_MathNode> nodes = [];

  String toRaw() => nodes.map((n) => n.toRaw()).join();
}

class _TextNode extends _MathNode {
  final String text;

  _TextNode(this.text);

  @override
  Widget build(
    BuildContext context,
    MathEditorController controller,
    List<_CursorStep> parentPath,
    int index,
    double fontSize,
  ) {
    return GestureDetector(
      onTap: () => controller.setCursor(_CursorPath(steps: parentPath, index: index + 1)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: 'Times New Roman',
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  String toRaw() => text;
}

class _PlaceholderNode extends _MathNode {
  @override
  Widget build(
    BuildContext context,
    MathEditorController controller,
    List<_CursorStep> parentPath,
    int index,
    double fontSize,
  ) {
    return _PlaceholderBox(size: fontSize * 0.5);
  }

  @override
  String toRaw() => '';
}

class _FractionNode extends _MathNode implements _HasChildren {
  final _MathList numerator = _MathList();
  final _MathList denominator = _MathList();

  @override
  Widget build(
    BuildContext context,
    MathEditorController controller,
    List<_CursorStep> parentPath,
    int index,
    double fontSize,
  ) {
    final numPath = List<_CursorStep>.from(parentPath)
      ..add(_CursorStep(index, _ChildSlot.numerator));
    final denPath = List<_CursorStep>.from(parentPath)
      ..add(_CursorStep(index, _ChildSlot.denominator));
    final innerSize = fontSize * 0.8;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: _FractionBox(
        numerator: _buildList(context, controller, numerator, numPath, innerSize),
        denominator: _buildList(context, controller, denominator, denPath, innerSize),
        onTapNumerator: () => controller.setCursor(_CursorPath(steps: numPath, index: numerator.nodes.length)),
        onTapDenominator: () => controller.setCursor(_CursorPath(steps: denPath, index: denominator.nodes.length)),
      ),
    );
  }

  @override
  String toRaw() => 'frac(${numerator.toRaw()},${denominator.toRaw()})';

  @override
  _MathList childFor(_ChildSlot slot) {
    switch (slot) {
      case _ChildSlot.numerator:
        return numerator;
      case _ChildSlot.denominator:
        return denominator;
      default:
        return numerator;
    }
  }
}

class _FractionBox extends StatefulWidget {
  final Widget numerator;
  final Widget denominator;
  final VoidCallback onTapNumerator;
  final VoidCallback onTapDenominator;

  const _FractionBox({
    required this.numerator,
    required this.denominator,
    required this.onTapNumerator,
    required this.onTapDenominator,
  });

  @override
  State<_FractionBox> createState() => _FractionBoxState();
}

class _FractionBoxState extends State<_FractionBox> {
  double _barWidth = 18;
  double _numWidth = 0;
  double _denWidth = 0;

  void _updateWidth({double? num, double? den}) {
    if (num != null) _numWidth = num;
    if (den != null) _denWidth = den;
    final next = math.max(18, math.max(_numWidth, _denWidth)).toDouble();
    if ((next - _barWidth).abs() < 0.5) return;
    setState(() => _barWidth = next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MeasureSize(
          onChange: (size) => _updateWidth(num: size.width),
          child: GestureDetector(onTap: widget.onTapNumerator, child: widget.numerator),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          height: 1.5,
          width: _barWidth,
          color: Colors.black,
        ),
        MeasureSize(
          onChange: (size) => _updateWidth(den: size.width),
          child: GestureDetector(onTap: widget.onTapDenominator, child: widget.denominator),
        ),
      ],
    );
  }
}

typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({super.key, required this.onChange, required Widget child}) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderMeasureSize(onChange);

  @override
  void updateRenderObject(BuildContext context, covariant _RenderMeasureSize renderObject) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  OnWidgetSizeChange onChange;
  Size? _oldSize;

  _RenderMeasureSize(this.onChange);

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size ?? Size.zero;
    if (_oldSize == newSize) return;
    _oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}


class _SqrtNode extends _MathNode implements _HasChildren {
  final _MathList radicand = _MathList();

  @override
  Widget build(
    BuildContext context,
    MathEditorController controller,
    List<_CursorStep> parentPath,
    int index,
    double fontSize,
  ) {
    final radPath = List<_CursorStep>.from(parentPath)
      ..add(_CursorStep(index, _ChildSlot.radicand));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('√', style: TextStyle(fontSize: fontSize + 6, fontFamily: 'Times New Roman')),
        Container(
          padding: const EdgeInsets.only(top: 2),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black, width: 1.2)),
          ),
          child: GestureDetector(
            onTap: () => controller.setCursor(_CursorPath(steps: radPath, index: radicand.nodes.length)),
            child: _buildList(context, controller, radicand, radPath, fontSize),
          ),
        ),
      ],
    );
  }

  @override
  String toRaw() => 'sqrt(${radicand.toRaw()})';

  @override
  _MathList childFor(_ChildSlot slot) => radicand;
}

class _PowerNode extends _MathNode implements _HasChildren {
  final _MathNode base;
  final _MathList exponent = _MathList();

  _PowerNode(this.base);

  @override
  Widget build(
    BuildContext context,
    MathEditorController controller,
    List<_CursorStep> parentPath,
    int index,
    double fontSize,
  ) {
    final expPath = List<_CursorStep>.from(parentPath)
      ..add(_CursorStep(index, _ChildSlot.exponent));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        base.build(context, controller, parentPath, index, fontSize),
        Padding(
          padding: const EdgeInsets.only(left: 2),
            child: Transform.translate(
              offset: Offset(0, -fontSize * 0.35),
              child: _buildList(context, controller, exponent, expPath, fontSize * 0.7),
            ),
          ),
      ],
    );
  }

  @override
  String toRaw() => '${base.toRaw()}^(${exponent.toRaw()})';

  @override
  _MathList childFor(_ChildSlot slot) => exponent;
}

class _FunctionNode extends _MathNode implements _HasChildren {
  final String name;
  final _MathList argument = _MathList();

  _FunctionNode(this.name);

  @override
  Widget build(
    BuildContext context,
    MathEditorController controller,
    List<_CursorStep> parentPath,
    int index,
    double fontSize,
  ) {
    final argPath = List<_CursorStep>.from(parentPath)
      ..add(_CursorStep(index, _ChildSlot.argument));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(name, style: TextStyle(fontSize: fontSize, fontFamily: 'Times New Roman')),
        Text('(', style: TextStyle(fontSize: fontSize, fontFamily: 'Times New Roman')),
        _buildList(context, controller, argument, argPath, fontSize),
        Text(')', style: TextStyle(fontSize: fontSize, fontFamily: 'Times New Roman')),
      ],
    );
  }

  @override
  String toRaw() => '$name(${argument.toRaw()})';

  @override
  _MathList childFor(_ChildSlot slot) => argument;
}

class _GroupNode extends _MathNode implements _HasChildren {
  final _MathList argument = _MathList();

  @override
  Widget build(
    BuildContext context,
    MathEditorController controller,
    List<_CursorStep> parentPath,
    int index,
    double fontSize,
  ) {
    final argPath = List<_CursorStep>.from(parentPath)
      ..add(_CursorStep(index, _ChildSlot.argument));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('(', style: TextStyle(fontSize: fontSize, fontFamily: 'Times New Roman')),
        _buildList(context, controller, argument, argPath, fontSize),
        Text(')', style: TextStyle(fontSize: fontSize, fontFamily: 'Times New Roman')),
      ],
    );
  }

  @override
  String toRaw() => '(${argument.toRaw()})';

  @override
  _MathList childFor(_ChildSlot slot) => argument;
}

class _AbsoluteNode extends _MathNode implements _HasChildren {
  final _MathList argument = _MathList();

  @override
  Widget build(
    BuildContext context,
    MathEditorController controller,
    List<_CursorStep> parentPath,
    int index,
    double fontSize,
  ) {
    final argPath = List<_CursorStep>.from(parentPath)
      ..add(_CursorStep(index, _ChildSlot.argument));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('|', style: TextStyle(fontSize: fontSize, fontFamily: 'Times New Roman')),
        _buildList(context, controller, argument, argPath, fontSize),
        Text('|', style: TextStyle(fontSize: fontSize, fontFamily: 'Times New Roman')),
      ],
    );
  }

  @override
  String toRaw() => 'abs(${argument.toRaw()})';

  @override
  _MathList childFor(_ChildSlot slot) => argument;
}

class _IntegralNode extends _MathNode implements _HasChildren {
  final _MathList integrand = _MathList();

  @override
  Widget build(
    BuildContext context,
    MathEditorController controller,
    List<_CursorStep> parentPath,
    int index,
    double fontSize,
  ) {
    final intPath = List<_CursorStep>.from(parentPath)
      ..add(_CursorStep(index, _ChildSlot.integrand));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('∫', style: TextStyle(fontSize: fontSize + 8, fontFamily: 'Times New Roman')),
        _buildList(context, controller, integrand, intPath, fontSize),
      ],
    );
  }

  @override
  String toRaw() => 'int(${integrand.toRaw()})';

  @override
  _MathList childFor(_ChildSlot slot) => integrand;
}

class _Caret extends StatelessWidget {
  final double height;

  const _Caret({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      color: Colors.orange,
    );
  }
}

class _PlaceholderBox extends StatelessWidget {
  final double size;

  const _PlaceholderBox({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DashedBoxPainter(),
    );
  }
}

class _DashedBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 2.0;
    const dashSpace = 2.0;
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final metrics = path.computeMetrics().toList();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final len = distance + dashWidth < metric.length ? dashWidth : metric.length - distance;
        final extractPath = metric.extractPath(distance, distance + len);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
