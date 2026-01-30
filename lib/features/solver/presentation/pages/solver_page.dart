import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/latex_view.dart';
import '../../../../core/utils/latex_input_formatter.dart';
import '../../../../injector.dart';
import '../../../keyboard/presentation/widgets/math_keyboard_panel.dart';
import '../../domain/entities/math_solution.dart';
import '../bloc/solver_bloc.dart';
import '../widgets/step_card.dart';
import '../widgets/result_card.dart';

class SolverPage extends StatefulWidget {
  const SolverPage({super.key});

  @override
  State<SolverPage> createState() => _SolverPageState();
}

class _SolverPageState extends State<SolverPage> {
  final TextEditingController _controller = TextEditingController(text: '2x + 4 = 10');
  final FocusNode _focusNode = FocusNode();
  String _inlineHint = 'Ex: 2x + 4 = 10';

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _insert(KeyboardInsert insert) {
    final value = _controller.value;
    final selection = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);
    final start = selection.start;
    final end = selection.end;

    final newText = value.text.replaceRange(start, end, insert.text);
    var offset = start + insert.text.length;
    if (insert.selectionBackOffset != null) {
      offset = (offset - insert.selectionBackOffset!).clamp(0, newText.length);
    }

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: offset),
    );
    if (_inlineHint.isNotEmpty) {
      setState(() {
        _inlineHint = '';
      });
    }
  }

  void _backspace() {
    final value = _controller.value;
    if (value.text.isEmpty) return;

    final selection = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);

    if (!selection.isCollapsed) {
      final newText = value.text.replaceRange(selection.start, selection.end, '');
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start),
      );
      return;
    }

    if (selection.start == 0) return;
    final newText = value.text.replaceRange(selection.start - 1, selection.start, '');
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start - 1),
    );
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _inlineHint = 'Ex: 2x + 4 = 10';
    });
  }

  void _moveCursor(int delta) {
    final value = _controller.value;
    final selection = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);
    var next = (selection.extentOffset + delta).clamp(0, value.text.length);
    if (delta > 0 && next < value.text.length && value.text[next] == ',') {
      next = (next + 1).clamp(0, value.text.length);
    } else if (delta < 0 && next > 0 && value.text[next - 1] == ',') {
      next = (next - 1).clamp(0, value.text.length);
    }
    _controller.value = value.copyWith(
      selection: TextSelection.collapsed(offset: next),
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
                final keyboardHeight = MediaQuery.of(context).size.height * 0.45;
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
                                    controller: _controller,
                                    focusNode: _focusNode,
                                    hint: _inlineHint,
                                    onTap: () => _focusNode.requestFocus(),
                                    onClear: _clear,
                                  ),
                                  const SizedBox(height: 12),
                                  BlocBuilder<SolverBloc, SolverState>(
                                    builder: (context, state) {
                                      if (state is SolverLoading) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      if (state is SolverLoaded) {
                                        final sameAsInput = _controller.text.isNotEmpty &&
                                            latexFromRaw(_controller.text) == state.solution.problemLatex;
                                        final hideProblem = _focusNode.hasFocus && sameAsInput;
                                        return _SolutionView(
                                          solution: state.solution,
                                          showProblem: !hideProblem,
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
                                context.read<SolverBloc>().add(SolveRequested(_controller.text));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: keyboardHeight,
                      child: MathKeyboardPanel(
                        onInsert: _insert,
                        onBackspace: _backspace,
                        onClear: _clear,
                        onCursorLeft: () => _moveCursor(-1),
                        onCursorRight: () => _moveCursor(1),
                        onSubmit: () {
                          context.read<SolverBloc>().add(SolveRequested(_controller.text));
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
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _MathCanvas({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    const inputFontSize = 32.0;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: IntrinsicWidth(
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        SizedBox(
                          width: constraints.maxWidth,
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            readOnly: true,
                            maxLines: 1,
                            showCursor: true,
                            enableInteractiveSelection: true,
                            style: const TextStyle(
                              color: Colors.transparent,
                              fontSize: inputFontSize,
                              fontFamily: 'Times New Roman',
                              fontWeight: FontWeight.w400,
                            ),
                            cursorHeight: inputFontSize,
                            cursorWidth: 1.4,
                            cursorColor: AppColors.blackText,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        IgnorePointer(
                          child: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: controller,
                            builder: (context, value, _) {
                              if (value.text.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return LatexView(latex: latexFromRaw(value.text));
                            },
                          ),
                        ),
                        if (controller.text.isNotEmpty)
                          Positioned(
                            right: 0,
                            child: IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: onClear,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (controller.text.isEmpty && hint.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(hint, style: const TextStyle(color: AppColors.neutralGray)),
          ],
        ],
      ),
    );
  }
}

class _SolutionView extends StatelessWidget {
  final MathSolution solution;
  final bool showProblem;

  const _SolutionView({
    required this.solution,
    required this.showProblem,
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
        ListView.builder(
          itemCount: solution.steps.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return StepReveal(
              index: index,
              child: StepCard(step: solution.steps[index]),
            );
          },
        ),
        ResultCard(solution: solution),
      ],
    );
  }
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

class StepReveal extends StatefulWidget {
  final int index;
  final Widget child;

  const StepReveal({super.key, required this.index, required this.child});

  @override
  State<StepReveal> createState() => _StepRevealState();
}

class _StepRevealState extends State<StepReveal> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: 80 * widget.index)).then((_) {
      if (mounted) {
        setState(() {
          _show = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _show ? 1 : 0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _show ? Offset.zero : const Offset(0, 0.06),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

