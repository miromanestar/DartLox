// ignore_for_file: constant_identifier_names

import 'package:DartLox/interpreter.dart';
import 'package:DartLox/statements.dart' as Stmt;
import 'environment.dart';

abstract class Callable {
  int arity();
  Object? call(Interpreter interpreter, List<Object?> arguments);
  
  @override
  String toString();
}

class LFunction extends Callable {
  final Stmt.LFunction _declaration;

  LFunction(this._declaration);

  @override
  int arity() => _declaration.params.length;

  @override
  String toString() => '<fn ${_declaration.name.lexeme}>';

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    final environment = Environment(interpreter.environment);

    for (int i = 0; i < _declaration.params.length; i++) {
      environment.define(_declaration.params[i].lexeme, arguments[i]);
    }

    interpreter.executeBlock(_declaration.body, environment);
    return null;
  }
}

class Clock extends Callable {
  @override
  int arity() => 0;
  
  @override
  String toString() => "<native fn 'clock'>";

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) =>
    DateTime.now().millisecondsSinceEpoch;
}

class Token {
  final TokenType type;
  final String lexeme;
  final Object? literal;
  final int line;

  Token(this.type, this.lexeme, this.literal, this.line);

  @override
  String toString() => '$type $lexeme $literal';
}

enum TokenType {
  //One character tokens
  LEFT_PAREN,
  RIGHT_PAREN,
  LEFT_BRACE,
  RIGHT_BRACE,
  COMMA,
  DOT,
  MINUS,
  PLUS,
  SEMICOLON,
  SLASH,
  STAR,
  QUESTION,
  COLON,

  //One/two character tokens
  BANG,
  BANG_EQUAL,
  EQUAL,
  EQUAL_EQUAL,
  GREATER,
  GREATER_EQUAL,
  LESS,
  LESS_EQUAL,

  //Literals
  IDENTIFIER,
  STRING,
  NUMBER,

  //Keywords
  AND,
  ELSE,
  FALSE,
  FUN,
  FOR,
  IF,
  NIL,
  OR,
  PRINT,
  RETURN,
  SUPER,
  TRUE,
  VAR,
  WHILE,

  //Misc
  EOF
}
