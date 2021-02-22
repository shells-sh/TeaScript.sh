## # `expression`
##
## Prints out an analysis of the provided expression, e.g. `x + 5`
##
## Used for debugging, not used by TeaScript.
##
## TeaScript uses `evaluate` to evaluate expressions using the same logic of expression.
## 
## > > | | Parameter |
## > > |-|-----------|
## > > | `$@` | The expression, e.g. `new Dog` or `x + 5` |
##
expression() {
  [ -n "$T_HINT_TYPE" ] && echo "Type hint: $T_HINT_TYPE"

  # When the return type of the expression is determined, set this.
  local returnType="Undetermined return type"

  #
  # local ...

  printf "Return type: $returnType"
}