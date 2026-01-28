// Fichier: lib/logic/parser.dart

import 'ast_models.dart';
import 'lexer.dart';

class Parser {
  final List<Token> _tokens;
  int _current = 0;

  Parser(this._tokens);

  static Expr parse(String input) {
    final lexer = Lexer(input);
    final tokens = lexer.scanTokens();
    final parser = Parser(tokens);
    return parser._parseExpression();
  }

  Expr _parseExpression() {
    Expr left = _parseTermeAddition();
    if (_match([TokenType.Equal])) {
      Expr right = _parseTermeAddition();
      return Equation(left, right);
    }
    return left;
  }

  Expr _parseTermeAddition() {
    Expr left = _parseFacteurMultiplication();
    while (_match([TokenType.Plus, TokenType.Minus])) {
      Token operator = _previous();
      Expr right = _parseFacteurMultiplication();
      if (operator.type == TokenType.Plus) {
        left = Add(left, right);
      } else {
        left = Sub(left, right);
      }
    }
    return left;
  }

  // Niveau 2 : Multiplications, Divisions ET Multiplication Implicite
  Expr _parseFacteurMultiplication() {
    Expr left = _parsePuissance();

    while (true) {
      if (_match([TokenType.Multiply, TokenType.Divide])) {
        // Cas 1 : Multiplication explicite (2 * 3)
        Token operator = _previous();
        Expr right = _parsePuissance();
        if (operator.type == TokenType.Multiply) {
          left = Mult(left, right);
        } else {
          left = Div(left, right);
        }
      } 
      // Cas 2 : Multiplication IMPLICITE (2x, 2(x+1), (a)(b), 2sqrt(x))
      // On détecte si le prochain token est un début d'expression valide
      else if (_check(TokenType.Variable) || 
               _check(TokenType.Number) || 
               _check(TokenType.LParen) || 
               _check(TokenType.Sqrt)) {
        
        Expr right = _parsePuissance();
        left = Mult(left, right); // On crée la multiplication magique
      } 
      else {
        break; // Plus rien à multiplier
      }
    }
    return left;
  }

  Expr _parsePuissance() {
    Expr left = _parseUnary();
    while (_match([TokenType.Power])) {
      Expr right = _parseUnary();
      left = Power(left, right);
    }
    return left;
  }

  Expr _parseUnary() {
    if (_match([TokenType.Minus])) {
      Expr right = _parseUnary();
      return UnaryMinus(right);
    }
    return _parseCall();
  }

  Expr _parseCall() {
    if (_match([TokenType.Sqrt])) {
      _consume(TokenType.LParen, "Attendu '(' après sqrt");
      Expr expr = _parseExpression();
      _consume(TokenType.RParen, "Attendu ')' après l'expression");
      return Sqrt(expr);
    }
    return _parsePrimaire();
  }

  Expr _parsePrimaire() {
    if (_match([TokenType.Number])) {
      return Number(double.parse(_previous().value));
    }
    if (_match([TokenType.Variable])) {
      return Variable(_previous().value);
    }
    if (_match([TokenType.LParen])) {
      Expr expr = _parseExpression();
      _consume(TokenType.RParen, "Attendu ')' après l'expression");
      return expr;
    }
    throw Exception("Impossible de lire l'expression à l'index $_current");
  }

  bool _match(List<TokenType> types) {
    for (var type in types) {
      if (_check(type)) {
        _advance();
        return true;
      }
    }
    return false;
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _tokens[_current].type == type;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _tokens[_current - 1];
  }

  bool _isAtEnd() => _tokens[_current].type == TokenType.EOF;

  Token _previous() => _tokens[_current - 1];

  void _consume(TokenType type, String message) {
    if (_check(type)) {
      _advance();
      return;
    }
    throw Exception(message);
  }
}
