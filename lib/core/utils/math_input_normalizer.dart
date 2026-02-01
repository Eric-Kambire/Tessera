String normalizeForEngine(String input) {
  var text = input.trim();

  if (text.isEmpty) return text;

  text = text
      .replaceAll('×', '*')
      .replaceAll('÷', '/')
      .replaceAll('−', '-')
      .replaceAll('π', 'pi')
      .replaceAll('√', 'sqrt')
      .replaceAll('∛', 'cbrt');

  text = _normalizeFractions(text);
  text = _normalizePercents(text);

  return text;
}

String _normalizeFractions(String input) {
  var text = input;
  var start = text.indexOf('frac(');
  while (start != -1) {
    final group = _readGroup(text, start + 5);
    final parts = _splitTopLevel(group.content);
    if (parts.length >= 2) {
      final replacement = '(${parts[0]})/(${parts[1]})';
      text = text.replaceRange(start, group.end + 1, replacement);
      start = text.indexOf('frac(');
    } else {
      start = text.indexOf('frac(', start + 5);
    }
  }
  return text;
}

String _normalizePercents(String input) {
  return input.replaceAllMapped(RegExp(r'(\d+(?:\.\d+)?)%'), (m) {
    final value = m[1] ?? '';
    return '($value/100)';
  });
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
      continue;
    }
    current.write(ch);
  }
  parts.add(current.toString());
  return parts;
}

class _Group {
  final String content;
  final int end;

  _Group(this.content, this.end);
}
