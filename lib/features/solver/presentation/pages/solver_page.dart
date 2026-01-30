import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/latex_view.dart';
import '../../../../core/utils/latex_input_formatter.dart';
import '../../../../injector.dart';
import '../../../keyboard/presentation/widgets/math_keyboard_sheet.dart';
import '../../domain/entities/math_solution.dart';
import '../bloc/solver_bloc.dart';
import '../widgets/step_card.dart';

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

  void _openKeyboard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MathKeyboardSheet(
        onInsert: _insert,
        onBackspace: _backspace,
        onClear: _clear,
        onClose: () => Navigator.pop(context),
        previewListenable: _controller,
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
              actions: [
                IconButton(
                  onPressed: () => _openKeyboard(context),
                  icon: const Icon(Icons.keyboard_alt_outlined),
                ),
              ],
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF7FBFF),
                    Color(0xFFFFFFFF),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InputCard(
                      controller: _controller,
                      focusNode: _focusNode,
                      hint: _inlineHint,
                      onTap: () {
                        _focusNode.requestFocus();
                        _openKeyboard(context);
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<SolverBloc>().add(SolveRequested(_controller.text));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Resoudre'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: BlocBuilder<SolverBloc, SolverState>(
                        builder: (context, state) {
                          if (state is SolverLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (state is SolverLoaded) {
                            return _SolutionView(solution: state.solution);
                          }
                          if (state is SolverError) {
                            return Center(
                              child: Text(
                                state.message,
                                style: const TextStyle(color: AppColors.tertiaryOrange),
                              ),
                            );
                          }
                          return const Center(
                            child: Text('Entrez une equation pour commencer.'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final VoidCallback onTap;

  const _InputCard({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Entrer une expression',
              style: TextStyle(color: AppColors.neutralGray, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  readOnly: true,
                  showCursor: true,
                  enableInteractiveSelection: true,
                  style: const TextStyle(
                    color: Colors.transparent,
                    fontSize: 18,
                  ),
                  cursorColor: AppColors.tertiaryOrange,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                IgnorePointer(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, _) {
                      if (value.text.isEmpty) {
                        return const Text(
                          '',
                          style: TextStyle(color: AppColors.neutralGray),
                        );
                      }
                      return LatexView(latex: latexFromRaw(value.text));
                    },
                  ),
                ),
              ],
            ),
            if (controller.text.isEmpty && hint.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(hint, style: const TextStyle(color: AppColors.neutralGray)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SolutionView extends StatelessWidget {
  final MathSolution solution;

  const _SolutionView({required this.solution});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text('Probleme', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        LatexView(latex: solution.problemLatex),
        const SizedBox(height: 16),
        ...solution.steps.asMap().entries.map(
              (entry) => StepReveal(
                index: entry.key,
                child: StepCard(step: entry.value),
              ),
            ),
        const SizedBox(height: 16),
        Text('Resultat final', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        LatexView(latex: solution.finalAnswerLatex),
      ],
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
