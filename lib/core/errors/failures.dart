abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ParsingFailure extends Failure {
  const ParsingFailure(String message) : super(message);
}

class NotSolvableFailure extends Failure {
  const NotSolvableFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
