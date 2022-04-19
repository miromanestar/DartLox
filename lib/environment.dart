// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:DartLox/types.dart';
import 'package:DartLox/error.dart';

class Environment {
  final Map<String, Object?> _values = {};
  final Environment? enclosing;

  Environment([this.enclosing]);

  Object? define(String name, Object? value) => 
    _values[name] = value;

  Object? get(Token name) {
    if (_values.containsKey(name.lexeme))
      return _values[name.lexeme];

    if (enclosing != null)
      return enclosing?.get(name);

    throw runtimeError(name, ErrorType.UNDEFINED_VARIABLE);
  }

  void assign(Token name, Object? value) {
    if (_values.containsKey(name.lexeme))
      _values[name.lexeme] = value;
    else if (enclosing != null)
      enclosing?.assign(name, value);
    else
      throw runtimeError(name, ErrorType.UNDEFINED_VARIABLE);
  }
}