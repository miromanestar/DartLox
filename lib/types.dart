// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:DartLox/error.dart';
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

    try {
      interpreter.executeBlock(_declaration.body, environment);
    } on ReturnException catch (err) {
      return err.value;
    }

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

class Input extends Callable {
  @override
  int arity() => 0;

  @override
  String toString() => "<native fn 'input'>";

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) =>
    stdin.readLineSync();
}

class Interpolate extends Callable {
  @override
  int arity() => -1;

  @override
  String toString() => "<native fn 'interpolate'>";

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    String str = arguments[0] as String;

    for (int i = 1; i < arguments.length; i++) {
      str = str.replaceFirst('\$s', arguments[i].toString());
    }

    return str;
  }
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
