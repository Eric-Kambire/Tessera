import 'package:flutter/material.dart';
import 'widgets/math_keyboard_sheet.dart';

void main() {
  runApp(const ClavierApp());
}

class ClavierApp extends StatelessWidget {
  const ClavierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tessera Keyboard Demo',
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        body: const Center(
          child: Text("Tap button to open keyboard"),
        ),
        floatingActionButton: Builder(
          builder: (ctx) => FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: ctx,
                isScrollControlled: true, // Allow full height control
                backgroundColor: Colors.transparent,
                builder: (context) => MathKeyboardSheet(
                  onExpressionChanged: (val) {
                    print("Expression: $val");
                  },
                  onClose: () => Navigator.pop(context),
                ),
              );
            },
            child: const Icon(Icons.keyboard),
          ),
        ),
      ),
    );
  }
}
