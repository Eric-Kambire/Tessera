// Fichier: lib/main.dart

import 'package:flutter/material.dart';
import 'logic/ast_models.dart';
import 'logic/solver_engine.dart';
import 'logic/solution_models.dart';
import 'logic/parser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Math Solver Craftsman',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        cardColor: const Color(0xFF252526),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E1E1E)),
      ),
      home: const SolverScreen(),
    );
  }
}

class SolverScreen extends StatefulWidget {
  const SolverScreen({super.key});

  @override
  State<SolverScreen> createState() => _SolverScreenState();
}

class _SolverScreenState extends State<SolverScreen> {
  final TextEditingController _controller = TextEditingController();
  Solution? _solution;
  String? _errorMessage;

  void _solveEquation() {
    final String rawText = _controller.text;
    if (rawText.isEmpty) return;

    // On cache le clavier pour mieux voir le résultat
    FocusScope.of(context).unfocus();

    try {
      final Expr equation = Parser.parse(rawText);
      final result = SolverEngine.solve(equation);

      setState(() {
        _solution = result;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur : Vérifiez votre syntaxe";
        _solution = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Solver IDO")),
      body: Column(
        children: [
          // --- ZONE DU HAUT (Fixe) ---
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF2D2D30), // Fond légèrement plus clair pour distinguer
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: "Entrez votre équation",
                    hintText: "Ex: 4 + 5 * 3",
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    errorText: _errorMessage,
                  ),
                  style: const TextStyle(fontSize: 20),
                  onSubmitted: (_) => _solveEquation(), // Lance le calcul avec "Entrée"
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _solveEquation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text("RÉSOUDRE", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),

          // --- ZONE DU BAS (Déroulante) ---
          Expanded(
            child: _solution == null
                ? const Center(child: Text("En attente de calcul...", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    // Astuce : On dit qu'il y a (nombre d'étapes + 1) éléments
                    // Le "+1" est pour la boîte rouge finale
                    itemCount: _solution!.steps.length + 1,
                    itemBuilder: (context, index) {
                      
                      // CAS 1 : C'est la boîte rouge finale (le dernier élément)
                      if (index == _solution!.steps.length) {
                        return Container(
                          margin: const EdgeInsets.only(top: 20, bottom: 40), // Marge en bas pour bien scroller
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.redAccent, width: 2),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.redAccent.withOpacity(0.1),
                          ),
                          child: Column(
                            children: [
                              const Text("SOLUTION FINALE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Text(
                                _solution!.finalResult.toLatex(),
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      }

                      // CAS 2 : C'est une étape normale
                      final step = _solution!.steps[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.description,
                                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                step.output.toLatex(),
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
