import 'package:DartLox/types.dart';
import 'package:DartLox/error.dart';

const _keywords = {
  'and':    TokenType.AND,
  'else':   TokenType.ELSE,
  'false':  TokenType.FALSE,
  'for':    TokenType.FOR,
  'fun':    TokenType.FUN,
  'if':     TokenType.IF,
  'nil':    TokenType.NIL,
  'or':     TokenType.OR,
  'print':  TokenType.PRINT,
  'return': TokenType.RETURN,
  'super':  TokenType.SUPER,
  'true':   TokenType.TRUE,
  'var':    TokenType.VAR,
  'while':  TokenType.WHILE,
};

class Scanner {
  final String source;
  final List<Token> tokens = [];

  int start = 0;
  int current = 0;
  int line = 1;

  Scanner(this.source);

  List<Token> scanTokens() {
    while (!_isAtEnd()) {
      start = current;
      _scanToken();
    }

    tokens.add(Token(TokenType.EOF, '', null, line));
    return tokens;
  }

  void _scanToken() {
    String c = _advance();

    switch (c) {
      case '(':
        _addToken(TokenType.LEFT_PAREN);
        break;
      case ')':
        _addToken(TokenType.RIGHT_PAREN);
        break;
      case '{':
        _addToken(TokenType.LEFT_BRACE);
        break;
      case '}':
        _addToken(TokenType.RIGHT_BRACE);
        break;
      case ',':
        _addToken(TokenType.COMMA);
        break;
      case '.':
        _addToken(TokenType.DOT);
        break;
      case '-':
        _addToken(TokenType.MINUS);
        break;
      case '+':
        _addToken(TokenType.PLUS);
        break;
      case ';':
        _addToken(TokenType.SEMICOLON);
        break;
      case '*':
        _addToken(TokenType.STAR);
        break;

      //Two character tokens
      case '!':
        _addToken(match('=') ? TokenType.BANG_EQUAL : TokenType.BANG);
        break;
      case '=':
        _addToken(match('=') ? TokenType.EQUAL_EQUAL : TokenType.EQUAL);
        break;
      case '>':
        _addToken(match('=') ? TokenType.GREATER_EQUAL : TokenType.GREATER);
        break;
      case '<':
        _addToken(match('=') ? TokenType.LESS_EQUAL : TokenType.LESS);
        break;
      case '/':
        if (match('/')) {
          //A comment goes until the end of the line.
          while (_peek() != '\n' && !_isAtEnd()) {
            _advance();
          }
        } else {
          _addToken(TokenType.SLASH);
        }
        break;

      //Ignore whitepsace
      case ' ':
        break;
      case '\r':
        break;
      case '\t':
        break;

      //Special cases
      case '\n':
        line++;
        break;
      case '"':
        _string();
        break;
      default:
        if (_isDigit(c)) {
          _number();
        } else if (_isAlpha(c)) {
          _identifier();
        } else {
          error(line, ErrorType.UNEXPECTED_CHARACTER);
        }
    }
  }

  void _addToken(TokenType type, [Object? literal]) {
    String text = source.substring(start, current);
    tokens.add(Token(type, text, literal, line));
  }

  bool match(String expected) {
    if (_isAtEnd() || source[current] != expected) {
      return false;
    }

    current++;
    return true;
  }

  void _identifier() {
    while (_isAlphaNumeric(_peek())) {
      _advance();
    }

    String text = source.substring(start, current);
    TokenType type = _keywords[text] ?? TokenType.IDENTIFIER;
    _addToken(type);
  }

  void _number() {
    while (_isDigit(_peek())) {
      _advance();
    }

    //Look for a fractional part.
    if (_peek() == '.' && _isDigit(_peekNext())) {
      _advance();

      while (_isDigit(_peek())) {
        _advance();
      }
    }

    _addToken(TokenType.NUMBER, num.parse(source.substring(start, current)));
  }

  void _string() {
    while (_peek() != '"' && !_isAtEnd()) {
      if (_peek() == '\n') {
        line++;
      }

      _advance();
    }

    if (_isAtEnd()) {
      error(line, ErrorType.UNTERMINATED_STRING);
      return;
    }

    _advance();

    String value = source.substring(start + 1, current - 1);
    _addToken(TokenType.STRING, value);
  }

  bool _isAlphaNumeric(String c) => _isAlpha(c) || _isDigit(c);

  bool _isAlpha(String c) {
    var code = c.toLowerCase().codeUnitAt(0);

    //97 = a, 122 = z, 95 = _
    return (code >= 97 && code <= 122) || (code == 95);
  }

  bool _isDigit(String c) {
    var code = c.codeUnitAt(0);

    //48 = 0, 57 = 9
    return code >= 48 && code <= 57;
  }

  String _advance() {
    current++;
    return source[current - 1];
  }

  String _peek() {
    if (_isAtEnd()) return '\x00';
    return source[current];
  }

  String _peekNext() {
    if (current + 1 >= source.length) return '\x00';
    return source[current + 1];
  }

  bool _isAtEnd() => current >= source.length;
}
