import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/latex_input_formatter.dart';
import '../../../../core/widgets/latex_view.dart';
import 'math_key.dart';

class MathKeyboardSheet extends StatelessWidget {
  final ValueChanged<KeyboardInsert> onInsert;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onClose;
  final ValueListenable<TextEditingValue> previewListenable;

  const MathKeyboardSheet({
    super.key,
    required this.onInsert,
    required this.onBackspace,
    required this.onClear,
    required this.onClose,
    required this.previewListenable,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text('Clavier Mathématique', style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryBlue.withOpacity(0.12)),
                ),
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: previewListenable,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) {
                      return const Text(
                        'Apercu LaTeX',
                        style: TextStyle(color: AppColors.neutralGray),
                      );
                    }
                    return LatexView(latex: latexFromRaw(value.text));
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            const TabBar(
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.neutralGray,
              indicatorColor: AppColors.primaryBlue,
              tabs: [
                Tab(text: 'Nombres'),
                Tab(text: 'Fonctions'),
                Tab(text: 'Lettres'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildGrid([
                    '7', '8', '9', '+',
                    '4', '5', '6', '-',
                    '1', '2', '3', '×',
                    '0', '.', '=', '/',
                  ]),
                  _buildGrid([
                    '(', ')', '^', 'sqrt',
                    'sin', 'cos', 'tan', 'pi',
                    'log', 'ln', 'abs', 'frac',
                    'x^2', 'x^3', '1/x', '±',
                  ]),
                  _buildGrid([
                    'x', 'y', 'z', 'a',
                    'b', 'c', 'd', 'e',
                    'f', 'g', 'h', 'k',
                    'm', 'n', 'p', 'q',
                  ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onClear,
                      child: const Text('Effacer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onBackspace,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tertiaryOrange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retour'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        itemCount: keys.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final key = keys[index];
          return MathKey(
            label: key,
            onTap: () => onInsert(_mapKey(key)),
            background: _isOperator(key) ? AppColors.primaryBlue.withOpacity(0.08) : null,
          );
        },
      ),
    );
  }

  bool _isOperator(String key) {
    return ['+', '-', '×', '/', '^', '='].contains(key);
  }

  KeyboardInsert _mapKey(String key) {
    switch (key) {
      case '×':
        return const KeyboardInsert(text: '*');
      case 'sqrt':
        return const KeyboardInsert(text: 'sqrt()', selectionBackOffset: 1);
      case 'sin':
        return const KeyboardInsert(text: 'sin()', selectionBackOffset: 1);
      case 'cos':
        return const KeyboardInsert(text: 'cos()', selectionBackOffset: 1);
      case 'tan':
        return const KeyboardInsert(text: 'tan()', selectionBackOffset: 1);
      case 'log':
        return const KeyboardInsert(text: 'log()', selectionBackOffset: 1);
      case 'ln':
        return const KeyboardInsert(text: 'ln()', selectionBackOffset: 1);
      case 'pi':
        return const KeyboardInsert(text: 'pi');
      case 'frac':
        return const KeyboardInsert(text: '()/()', selectionBackOffset: 4);
      case 'abs':
        return const KeyboardInsert(text: 'abs()', selectionBackOffset: 1);
      case 'x^2':
        return const KeyboardInsert(text: '^2');
      case 'x^3':
        return const KeyboardInsert(text: '^3');
      case '1/x':
        return const KeyboardInsert(text: '^-1');
      case '±':
        return const KeyboardInsert(text: '-');
      default:
        return KeyboardInsert(text: key);
    }
  }
}

class KeyboardInsert {
  final String text;
  final int? selectionBackOffset;

  const KeyboardInsert({required this.text, this.selectionBackOffset});
}
