import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/latex_view.dart';
import '../../../../core/utils/latex_input_formatter.dart';
import '../widgets/math_editor.dart';
import '../../../../injector.dart';
import '../../../keyboard/presentation/widgets/math_keyboard_panel.dart';
import '../../domain/entities/math_solution.dart';
import '../../domain/entities/solution_step.dart';
import '../../domain/entities/solve_method.dart';
import '../bloc/solver_bloc.dart';
import '../widgets/step_card.dart';
import '../widgets/result_card.dart';

class SolverPage extends StatefulWidget {
  const SolverPage({super.key});

  @override
  State<SolverPage> createState() => _SolverPageState();
}

class _SolverPageState extends State<SolverPage> {
  final MathEditorController _mathController = MathEditorController();
  String _inlineHint = 'Ex: 2x + 4 = 10';
  bool _canvasExpanded = false;
  bool _isEditing = false;
  SolveMethod _selectedMethod = SolveMethod.auto;

  @override
  void dispose() {
    _mathController.dispose();
    super.dispose();
  }

  void _insert(KeyboardInsert insert) {
    final text = insert.text;
    if (text == 'frac(,)' || text == '()/()') {
      _mathController.insertFraction();
    } else if (text == '()') {
      _mathController.insertGroup();
    } else if (text.startsWith('sqrt') || text.startsWith('cbrt') || text.startsWith('root')) {
      _mathController.insertSqrt();
    } else if (text.startsWith('int')) {
      _mathController.insertIntegral();
    } else if (text.startsWith('lim')) {
      final side = text.contains('lim+') ? '+' : text.contains('lim-') ? '-' : '';
      _mathController.insertLimit(side: side);
    } else if (text.startsWith('sin')) {
      _mathController.insertFunction('sin');
    } else if (text.startsWith('cos')) {
      _mathController.insertFunction('cos');
    } else if (text.startsWith('tan')) {
      _mathController.insertFunction('tan');
    } else if (text.startsWith('log')) {
      _mathController.insertFunction('log');
    } else if (text.startsWith('ln')) {
      _mathController.insertFunction('ln');
    } else if (text.startsWith('abs')) {
      _mathController.insertAbsolute();
    } else if (text.startsWith('^')) {
      _mathController.insertPower();
    } else {
      _mathController.insertText(text);
    }
    if (_inlineHint.isNotEmpty) {
      setState(() {
        _inlineHint = '';
      });
    }
  }

  void _backspace() {
    _mathController.backspace();
  }

  void _clear() {
    _mathController.clear();
    setState(() {
      _inlineHint = 'Ex: 2x + 4 = 10';
    });
  }

  void _moveCursor(int delta) {
    _mathController.moveCursor(delta);
  }

  void _solve(BuildContext context) {
    setState(() => _isEditing = false);
    context.read<SolverBloc>().add(
          SolveRequested(
            _mathController.raw,
            method: _selectedMethod,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SolverBloc>(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Tessera'),
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                const solveButtonHeight = 52.0;
                const solveButtonPadding = 20.0;
                final keyboardHeight = _canvasExpanded ? 0.0 : MediaQuery.of(context).size.height * 0.45;
                return Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.white,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                solveButtonHeight + solveButtonPadding,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    _MathCanvas(
                                    controller: _mathController,
                                    hint: _inlineHint,
                                    onTap: () {
                                      setState(() => _isEditing = true);
                                      _mathController.moveCursorToRootEnd();
                                    },
                                    onDoubleTap: () {
                                      if (_canvasExpanded) {
                                        setState(() => _canvasExpanded = false);
                                      }
                                      setState(() => _isEditing = true);
                                      _mathController.moveCursorToRootEnd();
                                    },
                                    onClear: _clear,
                                    onCopyLatex: () {
                                      final latex = latexFromRaw(_mathController.raw);
                                      Clipboard.setData(ClipboardData(text: latex));
                                    },
                                    onToggleFullscreen: () {
                                      setState(() => _canvasExpanded = !_canvasExpanded);
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  BlocBuilder<SolverBloc, SolverState>(
                                    builder: (context, state) {
                                      if (state is SolverLoading) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      if (state is SolverLoaded) {
                                        final sameAsInput = _mathController.raw.isNotEmpty &&
                                            latexFromRaw(_mathController.raw) == state.solution.problemLatex;
                                        final hideProblem = _isEditing && sameAsInput;
                                        return _SolutionView(
                                          solution: state.solution,
                                          showProblem: !hideProblem,
                                          method: _selectedMethod,
                                          onMethodChanged: (method) {
                                            setState(() => _selectedMethod = method);
                                            _solve(context);
                                          },
                                        );
                                      }
                                      if (state is SolverError) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            state.message,
                                            style: const TextStyle(color: AppColors.tertiaryOrange),
                                          ),
                                        );
                                      }
                                      return const Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Text('Entrez une equation pour commencer.'),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 12,
                          child: _SolvePill(
                              onPressed: () {
                                _solve(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_canvasExpanded)
                      SizedBox(
                        height: keyboardHeight,
                        child: MathKeyboardPanel(
                          onInsert: _insert,
                          onBackspace: _backspace,
                          onClear: _clear,
                          onCursorLeft: () => _moveCursor(-1),
                          onCursorRight: () => _moveCursor(1),
                          onSubmit: () {
                            _solve(context);
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _MathCanvas extends StatelessWidget {
  final MathEditorController controller;
  final String hint;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onClear;
  final VoidCallback onCopyLatex;
  final VoidCallback onToggleFullscreen;

  const _MathCanvas({
    required this.controller,
    required this.hint,
    required this.onTap,
    required this.onDoubleTap,
    required this.onClear,
    required this.onCopyLatex,
    required this.onToggleFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    const inputFontSize = 32.0;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onDoubleTap: onDoubleTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.fullscreen, color: AppColors.blackText),
                  onPressed: onToggleFullscreen,
                ),
                const SizedBox(width: 4),
                PopupMenuButton<_CanvasAction>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: _CanvasAction.copyLatex,
                      child: Text('Copier LaTeX'),
                    ),
                  ],
                  onSelected: (action) {
                    switch (action) {
                      case _CanvasAction.copyLatex:
                        onCopyLatex();
                        break;
                    }
                  },
                ),
                if (!controller.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: onClear,
                    ),
                  ),
              ],
            ),
            MathEditor(
              controller: controller,
              fontSize: inputFontSize,
              onTap: onTap,
            ),
            if (controller.isEmpty && hint.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(hint, style: const TextStyle(color: AppColors.neutralGray)),
            ],
          ],
        ),
      ),
    );
  }
}

enum _CanvasAction { copyLatex }

class _SolutionView extends StatelessWidget {
  final MathSolution solution;
  final bool showProblem;
  final SolveMethod method;
  final ValueChanged<SolveMethod> onMethodChanged;

  const _SolutionView({
    required this.solution,
    required this.showProblem,
    required this.method,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showProblem) ...[
          Text('Probleme', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          LatexView(latex: solution.problemLatex),
          const SizedBox(height: 16),
        ],
        _StepsNavigator(
          steps: solution.steps,
          method: method,
          onMethodChanged: onMethodChanged,
        ),
        ResultCard(solution: solution),
      ],
    );
  }
}

class _StepsNavigator extends StatefulWidget {
  final List<SolutionStep> steps;
  final SolveMethod method;
  final ValueChanged<SolveMethod> onMethodChanged;

  const _StepsNavigator({
    required this.steps,
    required this.method,
    required this.onMethodChanged,
  });

  @override
  State<_StepsNavigator> createState() => _StepsNavigatorState();
}

class _StepsNavigatorState extends State<_StepsNavigator> {
  late List<_StepEntry> _entries;
  late List<GlobalKey> _keys;
  int _current = 0;
  final ScrollController _controller = ScrollController();
  final ValueNotifier<int> _activeIndex = ValueNotifier<int>(0);
  bool _expandAll = false;

  @override
  void initState() {
    super.initState();
    _syncEntries();
  }

  @override
  void didUpdateWidget(covariant _StepsNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.steps != widget.steps) {
      _syncEntries();
    }
  }

  void _syncEntries() {
    _entries = _flattenSteps(widget.steps);
    _keys = List.generate(_entries.length, (_) => GlobalKey());
    if (_current >= _entries.length) {
      _current = _entries.isEmpty ? 0 : _entries.length - 1;
    }
    _activeIndex.value = _current;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
  }

  void _scrollToCurrent() {
    if (_current < 0 || _current >= _keys.length) return;
    final ctx = _keys[_current].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 250), alignment: 0.15);
    }
  }

  void _setCurrent(int index) {
    if (index < 0 || index >= _entries.length) return;
    setState(() => _current = index);
    _activeIndex.value = _current;
    _scrollToCurrent();
  }

  @override
  void dispose() {
    _activeIndex.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepsToolbar(
          current: _current + 1,
          total: _entries.length,
          expanded: _expandAll,
          onToggleExpand: () => setState(() => _expandAll = !_expandAll),
          onPrev: _current > 0 ? () => _setCurrent(_current - 1) : null,
          onNext: _current < _entries.length - 1 ? () => _setCurrent(_current + 1) : null,
          method: widget.method,
          onMethodChanged: widget.onMethodChanged,
        ),
        const SizedBox(height: 8),
        ListView.builder(
          controller: _controller,
          itemCount: _entries.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final entry = _entries[index];
            return KeyedSubtree(
              key: _keys[index],
              child: GestureDetector(
                onTap: () => _setCurrent(index),
                child: ValueListenableBuilder<int>(
                  valueListenable: _activeIndex,
                  builder: (context, active, _) {
                    final isActive = index == active;
                    return StepCard(
                      step: entry.step,
                      indent: entry.indent,
                      isActive: isActive,
                      indexLabel: '${index + 1}',
                      forceExpanded: _expandAll,
                      onPrev: isActive && index > 0 ? () => _setCurrent(index - 1) : null,
                      onNext: isActive && index < _entries.length - 1 ? () => _setCurrent(index + 1) : null,
                    );
                  },
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _StepsToolbar extends StatelessWidget {
  final int current;
  final int total;
  final bool expanded;
  final VoidCallback onToggleExpand;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final SolveMethod method;
  final ValueChanged<SolveMethod> onMethodChanged;

  const _StepsToolbar({
    required this.current,
    required this.total,
    required this.expanded,
    required this.onToggleExpand,
    required this.method,
    required this.onMethodChanged,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 420;
        final left = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Étapes', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 12),
            _MethodSelector(
              method: method,
              onChanged: onMethodChanged,
            ),
          ],
        );
        final right = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: onToggleExpand,
              child: Text(expanded ? 'Tout replier' : 'Tout déplier'),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_upward, size: 18),
              onPressed: onPrev,
              visualDensity: VisualDensity.compact,
            ),
            Text('$current / $total', style: const TextStyle(color: AppColors.neutralGray)),
            IconButton(
              icon: const Icon(Icons.arrow_downward, size: 18),
              onPressed: onNext,
              visualDensity: VisualDensity.compact,
            ),
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              left,
              const SizedBox(height: 4),
              right,
            ],
          );
        }

        return Row(
          children: [
            left,
            const Spacer(),
            right,
          ],
        );
      },
    );
  }
}

class _MethodSelector extends StatelessWidget {
  final SolveMethod method;
  final ValueChanged<SolveMethod> onChanged;

  const _MethodSelector({
    required this.method,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SolveMethod>(
      tooltip: 'Changer de méthode',
      onSelected: onChanged,
      itemBuilder: (context) => SolveMethod.values
          .map(
            (m) => PopupMenuItem(
              value: m,
              child: Text(solveMethodLabel(m)),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Méthode: ${solveMethodLabel(method)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.expand_more, size: 16),
          ],
        ),
      ),
    );
  }
}

class _StepEntry {
  final SolutionStep step;
  final double indent;

  const _StepEntry(this.step, this.indent);
}

List<_StepEntry> _flattenSteps(List<SolutionStep> steps, {double indent = 0}) {
  final items = <_StepEntry>[];
  for (final step in steps) {
    items.add(_StepEntry(step, indent));
    if (step.subSteps.isNotEmpty) {
      items.addAll(_flattenSteps(step.subSteps, indent: indent + 12));
    }
  }
  return items;
}

class _SolvePill extends StatelessWidget {
  final VoidCallback onPressed;

  const _SolvePill({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_forward, size: 18),
        label: const Text('Montrer la solution'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD7263D),
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
