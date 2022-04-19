import 'package:DartLox/environment.dart';
import 'package:DartLox/types.dart';
import 'package:DartLox/error.dart';
import 'package:DartLox/expressions.dart' as Expr;
import 'package:DartLox/statements.dart' as Stmt;

class Interpreter implements Expr.Visitor, Stmt.Visitor {
  final Environment _globals = Environment();
  final Environment environment = _globals;

  Interpreter() {
    _globals.define('clock', Clock());
  }

  void interpret(List<Stmt.Stmt> statements, [bool isRepl = false]) {
    try {
      for (var stmt in statements) {
        _execute(stmt);
      }
    }
  }
}