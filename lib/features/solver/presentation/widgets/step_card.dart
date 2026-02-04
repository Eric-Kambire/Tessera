import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/latex_view.dart';
import '../../domain/entities/solution_step.dart';

class StepCard extends StatelessWidget {
  final SolutionStep step;
  final double indent;
  final bool isActive;
  final String? indexLabel;
  final bool forceExpanded;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const StepCard({
    super.key,
    required this.step,
    this.indent = 0,
    this.isActive = false,
    this.indexLabel,
    this.forceExpanded = false,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final titleText = indexLabel == null || indexLabel!.isEmpty ? 'Étape' : 'Étape $indexLabel';
    final borderColor = isActive ? AppColors.primaryBlue : AppColors.primaryBlue.withOpacity(0.08);
    final shadowColor = isActive ? AppColors.primaryBlue.withOpacity(0.18) : Colors.black.withOpacity(0.04);
    final outputBackground = AppColors.tertiaryOrange.withOpacity(isActive ? 0.08 : 0.05);

    final card = Padding(
      padding: EdgeInsets.only(left: indent),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF4F8FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: isActive ? 1.3 : 1,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.18),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            BoxShadow(
              color: shadowColor,
              blurRadius: isActive ? 10 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primaryBlue : AppColors.neutralGray.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      titleText,
                      style: TextStyle(
                        color: isActive ? Colors.white : AppColors.blackText,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isActive)
                    Row(
                      children: [
                        IconButton(
                          onPressed: onPrev,
                          icon: const Icon(Icons.chevron_left),
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          onPressed: onNext,
                          icon: const Icon(Icons.chevron_right),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _StepSection(
                label: 'Entrée',
                child: LatexView(
                  latex: step.inputLatex,
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 10),
              _StepSection(
                label: 'Justification',
                child: Text(
                  step.description,
                  style: const TextStyle(color: AppColors.neutralGray),
                ),
              ),
              const SizedBox(height: 10),
              _StepSection(
                label: 'Sortie',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: outputBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.tertiaryOrange.withOpacity(0.18)),
                  ),
                  child: LatexView(
                    latex: step.outputLatex,
                    textStyle: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (step.subSteps.isEmpty) {
      return Column(
        children: [
          card,
          const Divider(height: 1, indent: 16, endIndent: 16),
        ],
      );
    }

    return ExpansionTile(
      key: ValueKey('${step.description}-$forceExpanded'),
      initiallyExpanded: forceExpanded,
      tilePadding: EdgeInsets.only(left: indent),
      title: Text(
        titleText,
        style: TextStyle(
          color: AppColors.blackText,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        step.description,
        style: const TextStyle(color: AppColors.neutralGray),
      ),
      childrenPadding: const EdgeInsets.only(left: 12, right: 8, bottom: 8),
      children: [
        card,
        ...step.subSteps.map(
          (sub) => StepCard(
            step: sub,
            indent: indent + 12,
            isActive: false,
          ),
        ),
      ],
    );
  }
}

class _StepSection extends StatelessWidget {
  final String label;
  final Widget child;

  const _StepSection({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.neutralGray,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
