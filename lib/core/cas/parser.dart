import 'dart:math' as math;
import 'expr.dart';
import 'statement.dart';

class ParseResult {
  final Expr expr;
  final String rest;

  const ParseResult(this.expr, this.rest);
}

class CasParser {
  Expr parse(String input) {
    final tokens = _tokenize(input);
    final output = <Expr>[];
    final ops = <String>[];

    void applyOp(String op) {
      if (op == 'u-') {
        final a = output.removeLast();
        output.add(Neg(a));
        return;
      }
      final b = output.removeLast();
      final a = output.removeLast();
      output.add(_makeBinary(op, a, b));
    }

    String? prev;
    for (var i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      if (_isNumber(token)) {
        output.add(Num(double.parse(token)));
        prev = 'num';
        continue;
      }
      if (_isIdentifier(token)) {
        if (token == 'sqrt' ||
            token == 'sin' ||
            token == 'cos' ||
            token == 'tan' ||
            token == 'log' ||
            token == 'ln') {
          ops.add(token);
          prev = 'func';
          continue;
        }
        if (token == 'pi') {
          output.add(Const('pi', math.pi));
          prev = 'num';
          continue;
        }
        if (token == 'e') {
          output.add(Const('e', math.e));
          prev = 'num';
          continue;
        }
        output.add(Var(token));
        prev = 'var';
        continue;
      }
      if (token == '(') {
        ops.add(token);
        prev = '(';
        continue;
      }
      if (token == ')') {
        while (ops.isNotEmpty && ops.last != '(') {
          final op = ops.removeLast();
          if (op == 'sqrt' ||
              op == 'sin' ||
              op == 'cos' ||
              op == 'tan' ||
              op == 'log' ||
              op == 'ln') {
            final a = output.removeLast();
            output.add(_makeFunc(op, a));
          } else {
            applyOp(op);
          }
        }
        if (ops.isNotEmpty && ops.last == '(') ops.removeLast();
        if (ops.isNotEmpty &&
            (ops.last == 'sqrt' ||
                ops.last == 'sin' ||
                ops.last == 'cos' ||
                ops.last == 'tan' ||
                ops.last == 'log' ||
                ops.last == 'ln')) {
          final func = ops.removeLast();
          final a = output.removeLast();
          output.add(_makeFunc(func, a));
        }
        prev = ')';
        continue;
      }

      var op = token;
      if (op == '-' && (prev == null || prev == '(' || _isOperator(prev))) {
        op = 'u-';
      }

      while (ops.isNotEmpty && _shouldPop(ops.last, op)) {
        final top = ops.last;
        if (top == '(') break;
        ops.removeLast();
        if (top == 'sqrt' ||
            top == 'sin' ||
            top == 'cos' ||
            top == 'tan' ||
            top == 'log' ||
            top == 'ln') {
          final a = output.removeLast();
          output.add(_makeFunc(top, a));
        } else {
          applyOp(top);
        }
      }
      ops.add(op);
      prev = op;
    }

    while (ops.isNotEmpty) {
      final op = ops.removeLast();
      if (op == '(') continue;
      if (op == 'sqrt' ||
          op == 'sin' ||
          op == 'cos' ||
          op == 'tan' ||
          op == 'log' ||
          op == 'ln') {
        final a = output.removeLast();
        output.add(_makeFunc(op, a));
      } else {
        applyOp(op);
      }
    }

    if (output.length != 1) {
      throw FormatException('Invalid expression');
    }
    return output.first;
  }

  Statement parseStatement(String input) {
    final normalized = input.replaceAll(' ', '');
    final opInfo = _findTopLevelRelation(normalized);
    if (opInfo == null) {
      throw FormatException('No relation operator');
    }
    final left = normalized.substring(0, opInfo.index);
    final right = normalized.substring(opInfo.index + opInfo.op.length);
    final leftExpr = parse(left);
    final rightExpr = parse(right);
    if (opInfo.op == '=') {
      return Equation(leftExpr, rightExpr);
    }
    return Inequality(leftExpr, rightExpr, opInfo.relOp);
  }
}

Expr _makeBinary(String op, Expr a, Expr b) {
  switch (op) {
    case '+':
      return Add(a, b);
    case '-':
      return Sub(a, b);
    case '*':
      return Mul(a, b);
    case '/':
      return Div(a, b);
    case '^':
      return Pow(a, b);
    default:
      throw FormatException('Unknown op $op');
  }
}

Expr _makeFunc(String func, Expr arg) {
  return Func(func, arg);
}

int _precedence(String op) {
  switch (op) {
    case 'u-':
      return 4;
    case '^':
      return 3;
    case '*':
    case '/':
      return 2;
    case '+':
    case '-':
      return 1;
  }
  return 0;
}

bool _shouldPop(String top, String current) {
  if (top == '(') return false;
  final pTop = _precedence(top);
  final pCur = _precedence(current);
  if (current == '^') {
    return pTop > pCur;
  }
  return pTop >= pCur;
}

bool _isNumber(String token) => RegExp(r'^\d+(\.\d+)?$').hasMatch(token);

bool _isIdentifier(String token) => RegExp(r'^[a-zA-Z]+$').hasMatch(token);

bool _isOperator(String token) => const ['+', '-', '*', '/', '^', 'u-'].contains(token);

List<String> _tokenize(String input) {
  final text = input.replaceAll(' ', '');
  final tokens = <String>[];
  final buffer = StringBuffer();

  void flush() {
    if (buffer.isNotEmpty) {
      tokens.add(buffer.toString());
      buffer.clear();
    }
  }

  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    if (_isDigit(ch) || ch == '.') {
      buffer.write(ch);
      continue;
    }
    flush();
    if (_isLetter(ch)) {
      final start = i;
      var j = i;
      while (j < text.length && _isLetter(text[j])) {
        j++;
      }
      tokens.add(text.substring(start, j));
      i = j - 1;
      continue;
    }
    tokens.add(ch);
  }
  flush();
  return _insertImplicitMultiplication(tokens);
}

bool _isDigit(String ch) => ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
bool _isLetter(String ch) =>
    (ch.codeUnitAt(0) >= 65 && ch.codeUnitAt(0) <= 90) ||
    (ch.codeUnitAt(0) >= 97 && ch.codeUnitAt(0) <= 122);

List<String> _insertImplicitMultiplication(List<String> tokens) {
  if (tokens.isEmpty) return tokens;
  final result = <String>[];
  for (var i = 0; i < tokens.length; i++) {
    result.add(tokens[i]);
    if (i == tokens.length - 1) break;
    final left = tokens[i];
    final right = tokens[i + 1];
    if (_needsImplicitMul(left, right)) {
      result.add('*');
    }
  }
  return result;
}

bool _needsImplicitMul(String left, String right) {
  if (left == 'sqrt' ||
      left == 'sin' ||
      left == 'cos' ||
      left == 'tan' ||
      left == 'log' ||
      left == 'ln') {
    return false;
  }
  final leftType = _tokenType(left);
  final rightType = _tokenType(right);
  if (leftType == _TokType.number || leftType == _TokType.ident || left == ')') {
    if (rightType == _TokType.number || rightType == _TokType.ident || right == '(') {
      return true;
    }
  }
  return false;
}

_TokType _tokenType(String token) {
  if (_isNumber(token)) return _TokType.number;
  if (_isIdentifier(token)) return _TokType.ident;
  return _TokType.other;
}

enum _TokType { number, ident, other }

class _RelInfo {
  final String op;
  final RelOp relOp;
  final int index;

  const _RelInfo(this.op, this.relOp, this.index);
}

_RelInfo? _findTopLevelRelation(String input) {
  var depth = 0;
  for (var i = 0; i < input.length; i++) {
    final ch = input[i];
    if (ch == '(') depth++;
    if (ch == ')') depth--;
    if (depth != 0) continue;

    if (i + 1 < input.length) {
      final two = input.substring(i, i + 2);
      if (two == '<=') return _RelInfo(two, RelOp.le, i);
      if (two == '>=') return _RelInfo(two, RelOp.ge, i);
    }
    if (ch == '<') return _RelInfo(ch, RelOp.lt, i);
    if (ch == '>') return _RelInfo(ch, RelOp.gt, i);
    if (ch == '=') return _RelInfo(ch, RelOp.eq, i);
  }
  return null;
}
