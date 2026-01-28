// Fichier: lib/logic/lexer.dart

/// Les types de mots que notre langage comprend
enum TokenType { 
  Number, Variable, Plus, Minus, Multiply, Divide, Power, 
  Sqrt, // <--- NOUVEAU
  Equal, LParen, RParen, EOF 
}

/// Un "mot" (Token) avec son type et sa valeur
class Token {
  final TokenType type;
  final String value;
  Token(this.type, this.value);
  
  @override
  String toString() => 'Token($type, "$value")';
}

/// La machine à découper
class Lexer {
  final String text;
  int _pos = 0;

  Lexer(this.text);

  List<Token> scanTokens() {
    List<Token> tokens = [];
    while (_pos < text.length) {
      String char = text[_pos];

      // 1. Ignorer les espaces
      if (char == ' ') {
        _pos++;
        continue;
      }

      // 2. Repérer les Nombres (ex: 12 ou 3.5)
      if (_isDigit(char)) {
        tokens.add(_readNumber());
        continue;
      }

      // 3. Repérer les Variables (x, y) OU les Fonctions (sqrt)
      if (_isAlpha(char)) {
        int start = _pos;
        while (_pos < text.length && _isAlpha(text[_pos])) {
          _pos++;
        }
        String word = text.substring(start, _pos);
        
        if (word == "sqrt") {
          tokens.add(Token(TokenType.Sqrt, "sqrt"));
        } else {
          tokens.add(Token(TokenType.Variable, word));
        }
        continue;
      }

      // 4. Repérer les Opérateurs
      switch (char) {
        case '+': tokens.add(Token(TokenType.Plus, "+")); break;
        case '-': tokens.add(Token(TokenType.Minus, "-")); break;
        case '*': tokens.add(Token(TokenType.Multiply, "*")); break;
        case '/': tokens.add(Token(TokenType.Divide, "/")); break;
        case '^': tokens.add(Token(TokenType.Power, "^")); break;
        case '=': tokens.add(Token(TokenType.Equal, "=")); break;
        case '(': tokens.add(Token(TokenType.LParen, "(")); break;
        case ')': tokens.add(Token(TokenType.RParen, ")")); break;
        default: 
          // On ignore les caractères inconnus pour l'instant
          break;
      }
      _pos++;
    }
    tokens.add(Token(TokenType.EOF, ""));
    return tokens;
  }

  // --- Helpers ---

  bool _isDigit(String char) => RegExp(r'[0-9]').hasMatch(char);
  bool _isAlpha(String char) => RegExp(r'[a-zA-Z]').hasMatch(char);

  Token _readNumber() {
    int start = _pos;
    // Avancer tant que ce sont des chiffres ou un point
    while (_pos < text.length && (RegExp(r'[0-9\.]').hasMatch(text[_pos]))) {
      _pos++;
    }
    return Token(TokenType.Number, text.substring(start, _pos));
  }
}
