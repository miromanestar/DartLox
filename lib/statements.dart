import 'package:DartLox/types.dart';
import 'package:DartLox/expressions.dart';

abstract class Stmt {
  R accept<R>(Visitor<R> visitor);
}

abstract class Visitor<R> {
  R visitBlockStmt(Block visitor);
  R visitExpressionStmt(Expression visitor);
  R visitFunctionStmt(Function visitor);
  R visitIfStmt(If visitor);
  R visitPrintStmt(Print visitor);
  R visitReturnStmt(Return visitor);
  R visitVarStmt(Var visitor);
  R visitWhileStmt(While visitor);
}

class Block extends Stmt {
  final List<Stmt> statements;

  Block(this.statements);

  @override
  R accept<R>(Visitor<R> visitor) => visitor.visitBlockStmt(this);
}

class Expression extends Stmt {
  final Expr expression;

  Expression(this.expression);

  @override
  R accept<R>(Visitor<R> visitor) => visitor.visitExpressionStmt(this);
}

class Function extends Stmt {
  final Token name;
  final List<Token> params;
  final List<Stmt> body;

  Function(this.name, this.params, this.body);

  @override
  R accept<R>(Visitor<R> visitor) => visitor.visitFunctionStmt(this);
}

class If extends Stmt {
  final Expr condition;
  final Stmt thenBranch;
  final Stmt elseBranch;

  If(this.condition, this.thenBranch, this.elseBranch);

  @override
  R accept<R>(Visitor<R> visitor) => visitor.visitIfStmt(this);
}

class Print extends Stmt {
  final Expr expression;

  Print(this.expression);

  @override
  R accept<R>(Visitor<R> visitor) => visitor.visitPrintStmt(this);
}

class Return extends Stmt {
  final Token keyword;
  final Expr value;

  Return(this.keyword, this.value);

  @override
  R accept<R>(Visitor<R> visitor) => visitor.visitReturnStmt(this);
}

class Var extends Stmt {
  final Token name;
  final Expr initializer;

  Var(this.name, this.initializer);

  @override
  R accept<R>(Visitor<R> visitor) => visitor.visitVarStmt(this);
}

class While extends Stmt {
  final Expr condition;
  final Stmt body;

  While(this.condition, this.body);

  @override
  R accept<R>(Visitor<R> visitor) => visitor.visitWhileStmt(this);
}

