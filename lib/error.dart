import 'package:DartLox/types.dart';

// ignore_for_file: constant_identifier_names

bool hadError = false;
bool hadRuntimeError = false;

void _logReport (int line, String location, ErrorType type) {
  print('[line $line] Error $location: ${_map[type]}');
  hadError = true;
}

void error(int line, ErrorType type) {
  _logReport(line, '', type);
}

void runtimeError(RuntimeError err) {
  Token token = err.token;
  print("[Runtime][line ${token.line}] ${_map[err.type]} '${token.lexeme}'");
  hadRuntimeError = true;
}

ParseError parseError(Token token, ErrorType type) {
  if (token.type == TokenType.EOF) {
    _logReport(token.line, 'at end ', ErrorType.UNEXPECTED_EOF);
  } else {
    _logReport(token.line, 'at ${token.lexeme}', type);
  }

  return ParseError();
}

const _map = {
  //Runtime errors
  ErrorType.ARGUMENT_COUNT: "Argument count mismatch.",
  ErrorType.CANNOT_CALL: "Can only call functions.",
  ErrorType.OPERAND_NUMBER: "Operand must be a number.",
  ErrorType.OPERANDS_NUMBER: "Operands must be numbers.",
  ErrorType.OPERANDS_MUST_MATCH: "Operands must be two numbers or two strings",
  ErrorType.UNDEFINED_VARIABLE: "Undefined variable",

  //Parser errors
  ErrorType.ARGUMENT_LIMIT: "Cannot have more than 255 arguments",
  ErrorType.INVALID_EXPRESSION: "Expect expression",
  ErrorType.EXPECTED_ARGS_LEFT_PAREN: "",
  ErrorType.EXPECTED_ARGS_RIGHT_PAREN: "Expected ')' after parameter list.",
  ErrorType.EXPECTED_BLOCK_RIGHT_BRACE: "Expected '}' after block.",
  ErrorType.EXPECTED_EXPR_RIGHT_PAREN: "Expected ')' after expression.",
  ErrorType.EXPECTED_FOR_LEFT_PAREN: "Expected '(' after 'for'.",
  ErrorType.EXPECTED_FOR_RIGHT_PAREN: "Expected ')' after 'for' condition.",
  ErrorType.EXPECTED_FUNCTION_LEFT_BRACE: "Expected '{' after function declaration.",
  ErrorType.EXPECTED_FUNCTION_RIGHT_BRACE: "Expected '}' after function body.",
  ErrorType.EXPECTED_FUNCTION_LEFT_PAREN: "Expected '(' after function name.",
  ErrorType.EXPECTED_FUNCTION_RIGHT_PAREN: "Expected ')' after function parameters.",
  ErrorType.EXPECTED_FUNCTION_NAME: "Expected function name.",
  ErrorType.EXPECTED_IF_LEFT_PAREN: "Expected '(' after 'if'.",
  ErrorType.EXPECTED_IF_RIGHT_PAREN: "Expected ')' after 'if' condition.",
  ErrorType.EXPECTED_LOOP_SEMICOLON: "Expected ';' after loop condition.",
  ErrorType.EXPECTED_NAME: "Expected variable name.",
  ErrorType.EXPECTED_PARAMETER_NAME: "Expected parameter name.",
  ErrorType.EXPECTED_RETURN_SEMICOLON: "Expected ';' after return value.",
  ErrorType.EXPECTED_VALUE_SEMICOLON: "Expected ';' after value.",
  ErrorType.EXPECTED_VARIABLE_SEMICOLON: "Expected ';' after variable declaration.",
  ErrorType.EXPECTED_SEMICOLON: "Expected ';' after expression.",
  ErrorType.EXPECTED_WHILE_LEFT_PAREN: "Expected '(' after 'while'.",
  ErrorType.EXPECTED_WHILE_RIGHT_PAREN: "Expected ')' after 'while' condition.",
  ErrorType.INVALID_ASSIGNMENT: "Invalid assignment target.",
  ErrorType.PARAMETER_LIMIT: "Cannot have more than 255 parameters.",
  
  //Scanner errors
  ErrorType.UNEXPECTED_CHARACTER: "Unexpected character.",
  ErrorType.UNTERMINATED_STRING: "Unterminated string.",

    ErrorType.UNEXPECTED_EOF: "Unexpected end of input."
};

enum ErrorType {

  //Scanner errors
  UNEXPECTED_CHARACTER,
  UNTERMINATED_STRING,

  //Parser errors
  ARGUMENT_LIMIT,
  INVALID_EXPRESSION,
  EXPECTED_ARGS_LEFT_PAREN,
  EXPECTED_ARGS_RIGHT_PAREN,
  EXPECTED_BLOCK_RIGHT_BRACE,
  EXPECTED_EXPR_RIGHT_PAREN,
  EXPECTED_FOR_LEFT_PAREN,
  EXPECTED_FOR_RIGHT_PAREN,
  EXPECTED_FUNCTION_LEFT_BRACE,
  EXPECTED_FUNCTION_RIGHT_BRACE,
  EXPECTED_FUNCTION_LEFT_PAREN,
  EXPECTED_FUNCTION_RIGHT_PAREN,
  EXPECTED_FUNCTION_NAME,
  EXPECTED_IF_LEFT_PAREN,
  EXPECTED_IF_RIGHT_PAREN,
  EXPECTED_LOOP_SEMICOLON,
  EXPECTED_NAME,
  EXPECTED_PARAMETER_NAME,
  EXPECTED_RETURN_SEMICOLON,
  EXPECTED_VALUE_SEMICOLON,
  EXPECTED_VARIABLE_SEMICOLON,
  EXPECTED_SEMICOLON,
  EXPECTED_WHILE_LEFT_PAREN,
  EXPECTED_WHILE_RIGHT_PAREN,
  INVALID_ASSIGNMENT,
  PARAMETER_LIMIT,
  UNEXPECTED_EOF,

  //Runtime errors
  ARGUMENT_COUNT,
  CANNOT_CALL,
  OPERAND_NUMBER,
  OPERANDS_NUMBER,
  OPERANDS_MUST_MATCH,
  UNDEFINED_VARIABLE
}

class ParseError extends Error { }
class RuntimeError extends Error { 
  final Token token;
  final ErrorType type;
  final String? message;

  RuntimeError(this.token, this.type, [this.message]);
}

class ReturnException extends Error {
  final Object? value;

  ReturnException(this.value);
}