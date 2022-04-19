// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:web_gl';

import 'package:DartLox/types.dart';
import 'package:DartLox/error.dart';
import 'package:DartLox/expressions.dart' as Expr;
import 'package:DartLox/statements.dart' as Stmt;

class Parser {
  List<Token> _tokens = [];

  int _current = 0;
  int _loopDepth = 0;
  Stmt.Stmt? _prevStmt = null;
  bool _isRepl;

  Parser(this._tokens, [this._isRepl = false]);

  List<Stmt.Stmt> parse() {
    List<Stmt.Stmt> statements = [];
    
    while (!_isAtEnd()) {
      _prevStmt = _declaration();
      statements.add(_prevStmt!);
    }

    return statements;
  }

  Stmt.Stmt _declaration() {
    try {
      if (_match([TokenType.FUN])) {
        return _function('function');
      }
      if (_match([TokenType.VAR])) {
        return _varDeclaration();
      }

      return _statement();
    } on Error catch (e) {
      _synchronize();
      return Stmt.Expression(Expr.Literal(null));
    }
  }

  Stmt.Stmt _statement() {
    if (_match([TokenType.FOR]))
      return _forStmt();
    if (_match([TokenType.IF]))
      return _ifStmt();
    if (_match([TokenType.LEFT_BRACE]))
      return _block();
    if (_match([TokenType.PRINT]))
      return _printStmt();
    if (_match([TokenType.RETURN]))
      return _returnStmt();
    if (_match([TokenType.WHILE]))
      return _whileStmt();

    return _expressionStmt();
  }

  Stmt.Stmt expressionStmt() {
    Expr.Expr expr = _expression();

    if (_isRepl && _peek().type == TokenType.SEMICOLON)
      return Stmt.Expression(expr);

    _consume(TokenType.SEMICOLON, ErrorType.EXPECTED_SEMICOLON);
    return Stmt.Expression(expr);
  }

  Token _consume(TokenType type, ErrorType errType) {
    if (type == TokenType.SEMICOLON) _isRepl = false;
    if (_check(type)) return _advance();

    throw parseError(_peek(), errType);
  }

  bool _match(List<TokenType> types) {
    for (var type in types) {
      if (_check(type)) {
        _advance();
        return true;
      }
    }

    return false;
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  Token _previous() {
    return _tokens[_current - 1];
  }

  Token _peek() {
    return _tokens[_current];
  }

  bool _isAtEnd() {
    return _peek().type == TokenType.EOF;
  }
}