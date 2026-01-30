String latexFromRaw(String raw) {
  if (raw.isEmpty) return '';

  var text = raw;
  final fractionRegex = RegExp(r'\(([^()]+)\)\s*/\s*\(([^()]+)\)');
  while (fractionRegex.hasMatch(text)) {
    text = text.replaceAllMapped(fractionRegex, (m) {
      return r'\frac{' + (m[1] ?? '') + '}{' + (m[2] ?? '') + '}';
    });
  }

  final buffer = StringBuffer();
  final stack = <String>[];
  for (var i = 0; i < text.length; i++) {
    if (text.startsWith('sqrt(', i)) {
      buffer.write(r'\sqrt{');
      stack.add('sqrt');
      i += 4;
      continue;
    }
    if (text.startsWith('sin(', i)) {
      buffer.write(r'\sin(');
      stack.add('func');
      i += 3;
      continue;
    }
    if (text.startsWith('cos(', i)) {
      buffer.write(r'\cos(');
      stack.add('func');
      i += 3;
      continue;
    }
    if (text.startsWith('tan(', i)) {
      buffer.write(r'\tan(');
      stack.add('func');
      i += 3;
      continue;
    }
    if (text.startsWith('log(', i)) {
      buffer.write(r'\log(');
      stack.add('func');
      i += 3;
      continue;
    }
    if (text.startsWith('ln(', i)) {
      buffer.write(r'\ln(');
      stack.add('func');
      i += 2;
      continue;
    }
    if (text.startsWith('abs(', i)) {
      buffer.write(r'\left|');
      stack.add('abs');
      i += 3;
      continue;
    }

    final ch = text[i];
    if (ch == '^') {
      if (i + 1 < text.length) {
        final next = text[i + 1];
        if (next == '(') {
          buffer.write('^');
          buffer.write('{');
          stack.add('pow');
          i += 1;
          continue;
        }
        if (RegExp(r'[A-Za-z0-9]').hasMatch(next)) {
          buffer.write('^{');
          buffer.write(next);
          buffer.write('}');
          i += 1;
          continue;
        }
      }
    }

    if (ch == ')' && stack.isNotEmpty) {
      final mode = stack.removeLast();
      if (mode == 'abs') {
        buffer.write(r'\right|');
      } else if (mode == 'sqrt' || mode == 'pow') {
        buffer.write('}');
      } else {
        buffer.write(')');
      }
      continue;
    }

    if (ch == '*') {
      buffer.write(r'\cdot ');
      continue;
    }
    if (ch == 'p' && text.startsWith('pi', i)) {
      buffer.write(r'\pi');
      i += 1;
      continue;
    }

    buffer.write(ch);
  }

  while (stack.isNotEmpty) {
    final mode = stack.removeLast();
    if (mode == 'abs') {
      buffer.write(r'\right|');
    } else if (mode == 'sqrt' || mode == 'pow') {
      buffer.write('}');
    } else {
      buffer.write(')');
    }
  }
  return buffer.toString();
}
