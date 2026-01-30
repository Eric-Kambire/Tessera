import 'package:injectable/injectable.dart';

@LazySingleton()
class StepDescriptionMapper {
  final Map<String, String> _map = const {
    'SIMPLIFY_ARITHMETIC': 'Simplifier l\'arithmetique.',
    'NO_CHANGE': 'Aucune transformation possible.',
    'SIMPLIFY_DOUBLE_UNARY_MINUS': 'Simplifier les signes consecutifs.',
    'UNARY_MINUS_TO_NEGATIVE_ONE': 'Rendre le coefficient negatif explicite.',
    'ADD_COEFFICIENT_OF_ONE': 'Rendre le coefficient implicite explicite.',
    'REMOVE_ADDITION_OF_ZERO': 'Supprimer l\'addition de zero.',
    'REMOVE_MULTIPLICATION_BY_ONE': 'Supprimer la multiplication par un.',
    'REMOVE_MULTIPLICATION_BY_NEGATIVE_ONE': 'Supprimer la multiplication par moins un.',
    'REMOVE_DIVISION_BY_ONE': 'Supprimer la division par un.',
    'REMOVE_EXPONENT_BY_ONE': 'Supprimer l\'exposant un.',
    'REMOVE_EXPONENT_BASE_ONE': 'Simplifier la base unitaire.',
    'REDUCE_EXPONENT_BY_ZERO': 'Appliquer la regle de l\'exposant zero.',
    'REDUCE_ZERO_DIVIDED_BY_ANYTHING': 'Simplifier le zero au numerateur.',
    'REDUCE_MULTIPLICATION_BY_ZERO': 'Simplifier la multiplication par zero.',
    'COLLECT_LIKE_TERMS': 'Regrouper les termes semblables.',
    'ADD_POLYNOMIAL_TERMS': 'Additionner les coefficients.',
    'MULTIPLY_POLYNOMIAL_TERMS': 'Multiplier les termes polynomiaux.',
    'REARRANGE_COEFF': 'Reorganiser le coefficient.',
    'GROUP_COEFFICIENTS': 'Regrouper les coefficients.',
    'ADD_FRACTIONS': 'Additionner les fractions.',
    'COMMON_DENOMINATOR': 'Mettre au meme denominateur.',
    'MULTIPLY_DENOMINATORS': 'Multiplier les denominateurs.',
    'MULTIPLY_NUMERATORS': 'Multiplier les numerateurs.',
    'DIVIDE_FRACTION_FOR_ADDITION': 'Decomposer la fraction pour addition.',
    'SIMPLIFY_FRACTION': 'Simplifier la fraction.',
    'MULTIPLY_FRACTIONS': 'Multiplier les fractions.',
    'ADD_CONSTANT_AND_FRACTION': 'Convertir la constante en fraction.',
    'SIMPLIFY_LEFT_SIDE': 'Simplifier le membre de gauche.',
    'SIMPLIFY_RIGHT_SIDE': 'Simplifier le membre de droite.',
    'ADD_TO_BOTH_SIDES': 'Ajouter la meme quantite des deux cotes.',
    'SUBTRACT_FROM_BOTH_SIDES': 'Soustraire la meme quantite des deux cotes.',
    'MULTIPLY_BOTH_SIDES': 'Multiplier les deux cotes par le meme nombre.',
    'DIVIDE_FROM_BOTH_SIDES': 'Diviser les deux cotes par le meme nombre.',
    'SWAP_SIDES': 'Inverser les deux membres.',
    'STATEMENT_IS_TRUE': 'Verifier que l\'egalite est toujours vraie.',
    'STATEMENT_IS_FALSE': 'Verifier que l\'egalite est impossible.',
    'DISTRIBUTE': 'Appliquer la distributivite.',
    'DISTRIBUTE_NEGATIVE_ONE': 'Distribuer le signe negatif.',
    'FACTOR_POLYNOMIAL': 'Factoriser le polynome.',
    'FACTOR_SYMBOL': 'Mettre en facteur la variable.',
    'FACTOR_DIFFERENCE_OF_SQUARES': 'Factoriser la difference de carres.',
    'FACTOR_PERFECT_SQUARE': 'Factoriser le carre parfait.',
  };

  String map(String key) {
    final sentence = _map[key] ?? 'Appliquer une transformation.';
    if (!sentence.endsWith('.')) {
      return '$sentence.';
    }
    return sentence;
  }
}
