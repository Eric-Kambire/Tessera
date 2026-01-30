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
      final group = _readGroup(text, i + 5);
      buffer.write(r'\sqrt{');
      buffer.write(group.content.isEmpty ? r'\Box' : latexFromRaw(group.content));
      buffer.write('}');
      i = group.end;
      continue;
    }
    if (text.startsWith('cbrt(', i)) {
      final group = _readGroup(text, i + 5);
      buffer.write(r'\sqrt[3]{');
      buffer.write(group.content.isEmpty ? r'\Box' : latexFromRaw(group.content));
      buffer.write('}');
      i = group.end;
      continue;
    }
    if (text.startsWith('sin(', i)) {
      final group = _readGroup(text, i + 4);
      buffer.write(r'\sin(');
      buffer.write(group.content.isEmpty ? r'\Box' : latexFromRaw(group.content));
      buffer.write(')');
      i = group.end;
      continue;
    }
    if (text.startsWith('cos(', i)) {
      final group = _readGroup(text, i + 4);
      buffer.write(r'\cos(');
      buffer.write(group.content.isEmpty ? r'\Box' : latexFromRaw(group.content));
      buffer.write(')');
      i = group.end;
      continue;
    }
    if (text.startsWith('tan(', i)) {
      final group = _readGroup(text, i + 4);
      buffer.write(r'\tan(');
      buffer.write(group.content.isEmpty ? r'\Box' : latexFromRaw(group.content));
      buffer.write(')');
      i = group.end;
      continue;
    }
    if (text.startsWith('log(', i)) {
      final group = _readGroup(text, i + 4);
      buffer.write(r'\log(');
      buffer.write(group.content.isEmpty ? r'\Box' : latexFromRaw(group.content));
      buffer.write(')');
      i = group.end;
      continue;
    }
    if (text.startsWith('ln(', i)) {
      final group = _readGroup(text, i + 3);
      buffer.write(r'\ln(');
      buffer.write(group.content.isEmpty ? r'\Box' : latexFromRaw(group.content));
      buffer.write(')');
      i = group.end;
      continue;
    }
    if (text.startsWith('abs(', i)) {
      final group = _readGroup(text, i + 4);
      buffer.write(r'\left|');
      buffer.write(group.content.isEmpty ? r'\Box' : latexFromRaw(group.content));
      buffer.write(r'\right|');
      i = group.end;
      continue;
    }
    if (text.startsWith('lim(', i)) {
      final group = _readGroup(text, i + 4);
      buffer.write(r'\lim(');
      buffer.write(group.content.isEmpty ? r'\Box' : latexFromRaw(group.content));
      buffer.write(')');
      i = group.end;
      continue;
    }
    if (text.startsWith('int(', i)) {
      final group = _readGroup(text, i + 4);
      buffer.write(r'\int(');
      buffer.write(group.content.isEmpty ? r'\Box' : latexFromRaw(group.content));
      buffer.write(')');
      i = group.end;
      continue;
    }
    if (text.startsWith('frac(', i)) {
      final group = _readGroup(text, i + 5);
      final parts = _splitTopLevel(group.content);
      final num = parts.isNotEmpty ? parts[0] : '';
      final den = parts.length > 1 ? parts[1] : '';
      buffer.write(r'\frac{');
      buffer.write(num.isEmpty ? r'\Box' : latexFromRaw(num));
      buffer.write('}{');
      buffer.write(den.isEmpty ? r'\Box' : latexFromRaw(den));
      buffer.write('}');
      i = group.end;
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
      if (mode == 'pow') {
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
    if (ch == 'i' && text.startsWith('inf', i)) {
      buffer.write(r'\infty');
      i += 2;
      continue;
    }

    buffer.write(ch);
  }

  while (stack.isNotEmpty) {
    final mode = stack.removeLast();
    if (mode == 'pow') {
      buffer.write('}');
    } else {
      buffer.write(')');
    }
  }
  return buffer.toString();
}

_Group _readGroup(String text, int start) {
  var depth = 0;
  final buffer = StringBuffer();
  var i = start;
  for (; i < text.length; i++) {
    final ch = text[i];
    if (ch == '(') {
      depth++;
      if (depth > 0) buffer.write(ch);
      continue;
    }
    if (ch == ')') {
      if (depth == 0) break;
      depth--;
      buffer.write(ch);
      continue;
    }
    buffer.write(ch);
  }
  return _Group(buffer.toString(), i);
}

List<String> _splitTopLevel(String input) {
  final parts = <String>[];
  var depth = 0;
  final current = StringBuffer();
  for (var i = 0; i < input.length; i++) {
    final ch = input[i];
    if (ch == '(') depth++;
    if (ch == ')') depth--;
    if (ch == ',' && depth == 0) {
      parts.add(current.toString());
      current.clear();
    } else {
      current.write(ch);
    }
  }
  parts.add(current.toString());
  return parts;
}

class _Group {
  final String content;
  final int end;

  const _Group(this.content, this.end);
}
