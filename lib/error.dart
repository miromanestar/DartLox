import 'package:DartLox/types.dart';

// ignore_for_file: constant_identifier_names

bool hadError = false;
bool hadRuntimeError = false;

void _logReport (int line, String location, ErrorType type) {
  print('[line $line] Error ${_map[type]}: $location');
  hadError = true;
}

void error(int line, ErrorType type) {
  _logReport(line, '', type);
}

ParseError parseError(Token token, ErrorType type) {
  if (token.type == TokenType.EOF) {
    _logReport(token.line, 'at end ', ErrorType.UNEXPECTED_EOF);
  } else {
    _logReport(token.line, 'at ', type);
  }

  return ParseError();
}

const _map = {
  //Parser errors
  ErrorType.EXPECTED_BLOCK_RIGHT_BRACE: "Expected '}' after block.",
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
  ErrorType.UNEXPECTED_CHARACTER: "Unexpected character",
  ErrorType.UNTERMINATED_STRING: "Unterminated string.",
  ErrorType.UNEXPECTED_EOF: ""
};

enum ErrorType {

  //Scanner errors
  UNEXPECTED_CHARACTER,
  UNTERMINATED_STRING,

  //Parser errors
  EXPECTED_BLOCK_RIGHT_BRACE,
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
  UNEXPECTED_EOF
}

class ParseError extends Error { }