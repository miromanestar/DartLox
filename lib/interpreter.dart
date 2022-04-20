// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:DartLox/environment.dart';
import 'package:DartLox/types.dart';
import 'package:DartLox/error.dart';
import 'package:DartLox/expressions.dart' as Expr;
import 'package:DartLox/statements.dart' as Stmt;

class Interpreter implements Expr.Visitor, Stmt.Visitor {
  final Environment _globals = Environment();
  late Environment environment;

  Interpreter() {
    _globals.define('clock', Clock());
    _globals.define('input', Input());
    _globals.define('interpolate', Interpolate());
    environment = _globals;
  }

  void interpret(List<Stmt.Stmt> statements, [bool isRepl = false]) {
    try {
      if (isRepl && statements[0] is Stmt.Expression && statements.length == 1) {
        Stmt.Expression expr = statements[0] as Stmt.Expression;
        print(_stringify(_evaluate(expr.expression)));
        return;
      }

      for (var stmt in statements)
        _execute(stmt);
    } on RuntimeError catch (err) {
      runtimeError(err);
    }
  }

  void executeBlock(List<Stmt.Stmt> statements, Environment env) {
    final previous = environment;

    try {
      environment = env;
      for (final stmt in statements)
        _execute(stmt);
    } finally {
      environment = previous;
    }
  }

  @override
  Object? visitAssignExpr(Expr.Assign expr) {
    final value = _evaluate(expr.value);
    environment.assign(expr.name, value);
    return value;
  }

  @override
  Object? visitVariableExpr(Expr.Variable expr) =>
    environment.get(expr.name);

  @override
  Object? visitLiteralExpr(Expr.Literal expr) => expr.value;

  @override
  Object? visitLogicalExpr(Expr.Logical expr) {
    final left = _evaluate(expr.left);

    if (expr.oper.type == TokenType.OR) {
      if (_isTruthy(left)) return left;
    } else {
      if (!_isTruthy(left)) return left;
    }

    return _evaluate(expr.right);
  }

  @override
  Object? visitGroupingExpr(Expr.Grouping expr) => _evaluate(expr.expression);

  @override
  Object? visitUnaryExpr(Expr.Unary expr) {
    final right = _evaluate(expr.right);

    switch (expr.oper.type) {
      case TokenType.MINUS:
        _checkNumberOperand(expr.oper, right);
        return -(right as num);
      case TokenType.BANG:
        return !_isTruthy(right);
      default:
        return throw Error();
    }
  }

  @override
  Object? visitBinaryExpr(Expr.Binary expr) {
    final left = _evaluate(expr.left);
    final right = _evaluate(expr.right);

    switch (expr.oper.type) {
      case TokenType.MINUS:
        _checkNumberOperand(expr.oper, right);
        return (left as num) - (right as num);
      case TokenType.PLUS:
        if (left is num && right is num)
          return left + right;
        if (left is String && right is String)
          return _stringify(left) + _stringify(right);
        throw RuntimeError(expr.oper, ErrorType.OPERANDS_MUST_MATCH, '${expr.oper.lexeme} $left $right');
      case TokenType.SLASH:
        _checkNumberOperands(expr.oper, left, right);
        return (left as num) / (right as num);
      case TokenType.STAR:
        _checkNumberOperands(expr.oper, left, right);
        return (left as num) * (right as num);
      case TokenType.GREATER:
        _stringOrNumber(expr.oper, left, right);
        return (left as num) > (right as num);
      case TokenType.GREATER_EQUAL:
        _stringOrNumber(expr.oper, left, right);
        return (left as num) >= (right as num);
      case TokenType.LESS:
        _stringOrNumber(expr.oper, left, right);
        return (left as num) < (right as num);
      case TokenType.LESS_EQUAL:
        _stringOrNumber(expr.oper, left, right);
        return (left as num) <= (right as num);
      case TokenType.BANG_EQUAL:
        return !_isEqual(left, right);
      case TokenType.EQUAL_EQUAL:
        return _isEqual(left, right);
      default: throw Error();
    }
  }

  @override
  Object? visitCallExpr(Expr.Call expr) {
    final callee = _evaluate(expr.callee);

    if (callee is! Callable)
      throw RuntimeError(expr.paren, ErrorType.CANNOT_CALL, '${expr.paren.lexeme} $callee');

    final arguments = expr.arguments.map((arg) => _evaluate(arg)).toList();
    final Callable fun = callee;

    if (fun.arity() != -1 && fun.arity() != arguments.length)
      throw RuntimeError(expr.paren, ErrorType.ARGUMENT_COUNT, '${expr.paren.lexeme} $callee');

    return fun.call(this, arguments);
  }

  @override
  void visitBlockStmt(Stmt.Block stmt) =>
    executeBlock(stmt.statements, Environment(environment));

  @override
  void visitExpressionStmt(Stmt.Expression stmt) =>
    _evaluate(stmt.expression);

  @override
  void visitLFunctionStmt(Stmt.LFunction stmt) {
    final LFunction fun = LFunction(stmt);
    environment.define(stmt.name.lexeme, fun);
  }

  @override
  void visitIfStmt(Stmt.If stmt) {
    if (_isTruthy(_evaluate(stmt.condition)))
      _execute(stmt.thenBranch);
    else if (stmt.elseBranch != null)
      _execute(stmt.elseBranch);
  }

  @override
  void visitPrintStmt(Stmt.Print stmt) {
    final value = _stringify(_evaluate(stmt.expression));
    print(value);
  }

  @override
  void visitReturnStmt(Stmt.Return stmt) {
    final value = _evaluate(stmt.value);
    throw ReturnException(value);
  }

  @override
  void visitVarStmt(Stmt.Var stmt) {
    final value = stmt.initializer != null ? _evaluate(stmt.initializer) : null;
    environment.define(stmt.name.lexeme, value);
  }

  @override
  void visitWhileStmt(Stmt.While stmt) {
      while (_isTruthy(_evaluate(stmt.condition))) {
        _execute(stmt.body);

        // if (stmt.isForLoop) {
        //   final block = stmt.body as Stmt.Block;
        //   final expr = block.statements[1] as Stmt.Expression;
        //   _execute(expr);
        // }
      }
  }

  Object? _evaluate(Expr.Expr expr) => expr.accept(this);

  Object? _execute(Stmt.Stmt stmt) => stmt.accept(this);

  bool _isTruthy(Object? value) {
    if (value == null) return false;
    if (value is bool) return value;
    return true;
  }

  bool _isEqual(Object? a, Object? b) {
    if (a == null && b == null) return true;
    if (a == null) return false;
    return a == b;
  }

  String _stringify(Object? value) {
    if (value == null) return 'nil';
    if (value is num) {
      final text = value.toString();
      if (text.endsWith('.0')) 
        return text.substring(0, text.length - 2);
      return text;
    }

    return value.toString();
  }

  void _checkNumberOperand(Token oper, Object? value) {
    if (value is! num)
      throw RuntimeError(oper, ErrorType.OPERAND_NUMBER, '${oper.lexeme} $oper');
  }

  void _checkNumberOperands(Token oper, Object? left, Object? right) {
    if (left is! num || right is! num)
      throw RuntimeError(oper, ErrorType.OPERANDS_NUMBER, '${oper.lexeme} $left $right');
  }

  void _stringOrNumber(Token oper, Object? left, Object? right) {
    if (left is num && right is num)
      return;
    if (left is String && right is String)
      return;

    throw RuntimeError(oper, ErrorType.OPERANDS_MUST_MATCH, '${oper.lexeme} $left $right');
  }
}