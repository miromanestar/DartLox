import 'package:DartLox/types.dart';

abstract class Expr {
  R accept<R>(Visitor<R> visitor);
}

abstract class Visitor<R> {
  R visitAssignExpr(Assign visitor);
  R visitBinaryExpr(Binary visitor);
  R visitCallExpr(Call visitor);
  R visitGroupingExpr(Grouping visitor);
  R visitLiteralExpr(Literal visitor);
  R visitLogicalExpr(Logical visitor);
  R visitUnaryExpr(Unary visitor);
  R visitVariableExpr(Variable visitor);
}

class Assign extends Expr {
  final Token name;
  final Expr value;

  Assign(this.name, this.value);

  @override
  R accept<R>(Visitor<R> visitor) => visitor.visitAssignExpr(this);
}

class Binary extends Expr {
  final Expr left;
  final Token oper;
  final Expr right;

  Binary(this.left, this.oper, this.right);

  @override
  R accept<R>(Visitor<R> visitor) => visitor.visitBinaryExpr(this);
}

class Call extends Expr {
  final Expr callee;
  final Token paren;
  final List<Expr> arguments;

  Call(this.callee, this.paren, this.arguments);

  @override
  R accept<R>(Visitor<R> visitor) => visitor.visitCallExpr(this);
}

class Grouping extends Expr {
  final Expr expression;

  Grouping(this.expression);

  @override
  R accept<R>(Visitor<R> visitor) => visitor.visitGroupingExpr(this);
}

class Literal extends Expr {
  final Object? value;

  Literal(this.value);

  @override
  R accept<R>(Visitor<R> visitor) => visitor.visitLiteralExpr(this);
}

class Logical extends Expr {
  final Expr left;
  final Token oper;
  final Expr right;

  Logical(this.left, this.oper, this.right);

  @override
  R accept<R>(Visitor<R> visitor) => visitor.visitLogicalExpr(this);
}

class Unary extends Expr {
  final Token oper;
  final Expr right;

  Unary(this.oper, this.right);

  @override
  R accept<R>(Visitor<R> visitor) => visitor.visitUnaryExpr(this);
}

class Variable extends Expr {
  final Token name;

  Variable(this.name);

  @override
  R accept<R>(Visitor<R> visitor) => visitor.visitVariableExpr(this);
}

