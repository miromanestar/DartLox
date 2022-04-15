// ignore_for_file: constant_identifier_names

bool hadError = false;
bool hadRuntimeError = false;

void error(int line, ErrorType type) {
  print('[line $line] Error: ${_map[type]}');
}

const _map = {
  ErrorType.UNEXPECTED_CHARACTER: 'Unexpected character',
  ErrorType.UNTERMINATED_STRING: 'Unterminated string.',
};

enum ErrorType {

  //Scanner errors
  UNEXPECTED_CHARACTER,
  UNTERMINATED_STRING,
}
