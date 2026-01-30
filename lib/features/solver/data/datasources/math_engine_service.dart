import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class MathEngineService {
  JavascriptRuntime? _runtime;
  bool _initialized = false;

  Future<JavascriptRuntime> _ensureRuntime() async {
    final runtime = _runtime ?? getJavascriptRuntime();
    _runtime = runtime;

    if (!_initialized) {
      final script = await rootBundle.loadString('assets/js/math-engine.bundle.js');
      runtime.evaluate(script);
      _initialized = true;
    }
    return runtime;
  }

  Future<String> solveLatex(String latex) async {
    final runtime = await _ensureRuntime();
    final safe = _escapeJsString(latex);
    final result = runtime.evaluate("solveEquation('$safe')");
    return result.stringResult;
  }

  String _escapeJsString(String input) {
    return input
        .replaceAll('\\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll('\n', r'\n');
  }
}
