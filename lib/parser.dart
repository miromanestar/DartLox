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
        return _function();
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

  Expr.Expr _expression() => _assignment();

  Stmt.Stmt _varDeclaration() {
    Token name = _consume(TokenType.IDENTIFIER, ErrorType.EXPECTED_NAME);

    Expr.Expr initializer = Expr.Literal(null);
    if (_match([TokenType.EQUAL])) {
      initializer = _expression();
    }

    _consume(TokenType.SEMICOLON, ErrorType.EXPECTED_VARIABLE_SEMICOLON);
    return Stmt.Var(name, initializer);
  }

  Stmt.LFunction _function() {
    Token name = _consume(TokenType.IDENTIFIER, ErrorType.EXPECTED_FUNCTION_NAME);
    _consume(TokenType.LEFT_PAREN, ErrorType.EXPECTED_FUNCTION_LEFT_PAREN);

    List<Token> parameters = [];
    if (!_check(TokenType.RIGHT_PAREN)) {
      do {
        if (parameters.length >= 255) {
          parseError(_peek(), ErrorType.PARAMETER_LIMIT);
        }

        parameters.add(_consume(TokenType.IDENTIFIER, ErrorType.EXPECTED_PARAMETER_NAME));
      } while (_match([TokenType.COMMA]));
    }

    _consume(TokenType.RIGHT_PAREN, ErrorType.EXPECTED_FUNCTION_RIGHT_PAREN);
    _consume(TokenType.LEFT_BRACE, ErrorType.EXPECTED_FUNCTION_LEFT_BRACE);

    List<Stmt.Stmt> body = _block();

    return Stmt.LFunction(name, parameters, body);
  }

  Stmt.Stmt _statement() {
    if (_match([TokenType.FOR]))
      return _forStmt();
    if (_match([TokenType.IF]))
      return _ifStmt();
    if (_match([TokenType.LEFT_BRACE]))
      return Stmt.Block(_block());
    if (_match([TokenType.PRINT]))
      return _printStmt();
    if (_match([TokenType.RETURN]))
      return _returnStmt();
    if (_match([TokenType.WHILE]))
      return _whileStmt();

    return _expressionStmt();
  }

  Stmt.Stmt _expressionStmt() {
    Expr.Expr expr = _expression();

    if (_isRepl && _peek().type == TokenType.SEMICOLON)
      return Stmt.Expression(expr);

    _consume(TokenType.SEMICOLON, ErrorType.EXPECTED_SEMICOLON);
    return Stmt.Expression(expr);
  }

  Stmt.Stmt _forStmt() {
    _consume(TokenType.LEFT_PAREN, ErrorType.EXPECTED_FOR_LEFT_PAREN);
    
    Stmt.Stmt? initializer;
    if (_match([TokenType.SEMICOLON]))
      initializer = null;
    if (_match([TokenType.VAR]))
      initializer = _varDeclaration();
    else
      initializer = _expressionStmt();

    Expr.Expr? condition;
    if (!_check(TokenType.SEMICOLON))
      condition = _expression();
    _consume(TokenType.SEMICOLON, ErrorType.EXPECTED_LOOP_SEMICOLON);

    Expr.Expr? increment;
    if (!_check(TokenType.RIGHT_PAREN))
      increment = _expression();
    _consume(TokenType.RIGHT_PAREN, ErrorType.EXPECTED_FOR_RIGHT_PAREN);

    try {
      _loopDepth++;
      Stmt.Stmt body = _statement();
      
      if (increment != null)
        body = Stmt.Block([body, Stmt.Expression(increment)]);

      condition ??= Expr.Literal(true);

      body = Stmt.While(condition, body, true);

      if (initializer != null)
        body = Stmt.Block([initializer, body]);

      return body;
    } finally {
      _loopDepth--;
    }
  }

  Stmt.Stmt _ifStmt() {
    _consume(TokenType.LEFT_PAREN, ErrorType.EXPECTED_IF_LEFT_PAREN);
    Expr.Expr condition = _expression();
    _consume(TokenType.RIGHT_PAREN, ErrorType.EXPECTED_IF_RIGHT_PAREN);

    Stmt.Stmt thenBranch = _statement();
    Stmt.Stmt elseBranch = Stmt.Expression(Expr.Literal(null));
    if (_match([TokenType.ELSE]))
      elseBranch = _statement();
    
    return Stmt.If(condition, thenBranch, elseBranch);
  }

  Stmt.Stmt _printStmt() {
    Expr.Expr value = _expression();
    _consume(TokenType.SEMICOLON, ErrorType.EXPECTED_VALUE_SEMICOLON);
    return Stmt.Print(value);
  }

  Stmt.Stmt _returnStmt() {
    Token keyword = _previous();
    
    Expr.Expr value = Expr.Literal(null);
    
    if (!_check(TokenType.SEMICOLON))
      value = _expression();
    
    _consume(TokenType.SEMICOLON, ErrorType.EXPECTED_RETURN_SEMICOLON);
    return Stmt.Return(keyword, value);
  }

  Stmt.Stmt _whileStmt() {
    _consume(TokenType.LEFT_PAREN, ErrorType.EXPECTED_WHILE_LEFT_PAREN);
    Expr.Expr condition = _expression();
    _consume(TokenType.RIGHT_PAREN, ErrorType.EXPECTED_WHILE_RIGHT_PAREN);

    try {
      _loopDepth++;
      Stmt.Stmt body = _statement();
      return Stmt.While(condition, body, false);
    } finally {
      _loopDepth--;
    }
  }

  List<Stmt.Stmt> _block() {
    List<Stmt.Stmt> statements = [];
    while (!_check(TokenType.RIGHT_BRACE) && !_isAtEnd()) {
      statements.add(_declaration());
    }

    _consume(TokenType.RIGHT_BRACE, ErrorType.EXPECTED_BLOCK_RIGHT_BRACE);
    return statements;
  }

  Expr.Expr _assignment() {
    Expr.Expr expr = _or();

    if (_match([TokenType.EQUAL])) {
      Token equals = _previous();
      Expr.Expr value = _assignment();

      if (expr is Expr.Variable) {
        Token name = expr.name;
        return Expr.Assign(name, value);
      }

      throw parseError(equals, ErrorType.INVALID_ASSIGNMENT);
    }

    return expr;
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