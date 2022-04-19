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
  ErrorType.EXPECTED_SEMICOLON: "Expected ';' after expression.",
  ErrorType.UNEXPECTED_CHARACTER: "Unexpected character",
  ErrorType.UNTERMINATED_STRING: "Unterminated string.",
  ErrorType.UNEXPECTED_EOF: ""
};

enum ErrorType {

  //Scanner errors
  UNEXPECTED_CHARACTER,
  UNTERMINATED_STRING,

  //Parser errors
  EXPECTED_SEMICOLON,
  UNEXPECTED_EOF
}

class ParseError extends Error { }