sealed class KeyAction {
  const KeyAction();
}

class InsertSymbol extends KeyAction {
  final String symbol;
  const InsertSymbol(this.symbol);
}

class InsertTemplate extends KeyAction {
  final String template;
  final int cursorOffset; // How many chars back to move the cursor (e.g., inside parens)
  
  const InsertTemplate(this.template, {this.cursorOffset = 1});
}

class InsertCode extends KeyAction {
  final String code;
  const InsertCode(this.code);
}

class MoveCursor extends KeyAction {
  final int offset; // -1 for left, +1 for right
  const MoveCursor(this.offset);
}

class DeleteChar extends KeyAction {
  const DeleteChar();
}

class ClearExpression extends KeyAction {
  const ClearExpression();
}

class EvaluateExpression extends KeyAction {
  const EvaluateExpression();
}

class OpenModal extends KeyAction {
  final String modalType; // 'matrix', 'determinant'
  const OpenModal(this.modalType);
}

class SwitchMode extends KeyAction {
  // Implicit action usually handled by UI, but can be explicit key
  const SwitchMode();
}

class NewLine extends KeyAction {
  const NewLine();
}

class Undo extends KeyAction {
  const Undo();
}
