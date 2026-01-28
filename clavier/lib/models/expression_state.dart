class ExpressionState {
  final String text;
  final int cursorPosition;
  final String? errorMessage;
  final bool isRadianMode;

  const ExpressionState({
    this.text = '',
    this.cursorPosition = 0,
    this.errorMessage,
    this.isRadianMode = true,
  });

  ExpressionState copyWith({
    String? text,
    int? cursorPosition,
    String? errorMessage,
    bool? isRadianMode,
  }) {
    return ExpressionState(
      text: text ?? this.text,
      cursorPosition: cursorPosition ?? this.cursorPosition,
      errorMessage: errorMessage ?? this.errorMessage,
      isRadianMode: isRadianMode ?? this.isRadianMode,
    );
  }
}
