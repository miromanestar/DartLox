import 'dart:io';

var dependencies = [
  "import 'package:DartLox/types.dart';",
];

const expTypes = [
  'Assign     : Token name, Expr value',
  'Binary     : Expr left, Token oper, Expr right',
  'Call       : Expr callee, Token paren, List<Expr> arguments',
  'Grouping   : Expr expression',
  'Literal    : Object? value',
  'Logical    : Expr left, Token oper, Expr right',
  'Unary      : Token oper, Expr right',
  'Variable   : Token name',
];

const stmtTypes = [
  'Block      : List<Stmt> statements',
  'Expression : Expr expression',
  'Function   : Token name, List<Token> params, List<Stmt> body',
  'If         : Expr condition, Stmt thenBranch, Stmt elseBranch',
  'Print      : Expr expression',
  'Return     : Token keyword, Expr value',
  'Var        : Token name, Expr initializer',
  'While      : Expr condition, Stmt body',
];

String defineType(String baseName, String type) {
  var name = type.split(' ')[0];
  var fields = type.split(': ')[1].split(', ')
    .map((field) => field.split(' '));

  return '''
class $name extends $baseName {
  ${ fields.map((field) => 'final ${ field[0] } ${ field[1] };').join('\n  ') }

  $name(${ fields.map((field) => 'this.${field[1]}').join(', ') });

  @override
  R accept<R>(Visitor<R> visitor) => visitor.visit$name$baseName(this);
}\n
''';
}

String defineAst(String path, String baseName, List<String> types) {
  if (baseName == 'Stmt') {
    dependencies.add("import 'package:DartLox/expressions.dart';");
  }

  String output = dependencies.map((dep) => '$dep\n').join() + '\n';

  //Generate the visitor class
  output += '''
abstract class $baseName {
  R accept<R>(Visitor<R> visitor);
}\n
''';

  //Generate the base abstract class
  output += 'abstract class Visitor<R> {\n';
  output += types.map((type) {
    var name = type.split(' ')[0];
    return '  R visit$name$baseName($name visitor);\n';
  }).join();
  output += '}\n\n';

  //Generate the visitor classes
  output += types.map((type) => defineType(baseName, type)).join();

  return output;
}

void main() {
  String path = './lib';

  String expressions = defineAst(path, 'Expr', expTypes);
  String statements = defineAst(path, 'Stmt', stmtTypes);

  File('$path/expressions.dart').writeAsStringSync(expressions);
  File('$path/statements.dart').writeAsStringSync(statements);
}
