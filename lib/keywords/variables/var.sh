## # `var`
##
## Sets a variable equal to the result of an expression.
##
## Used implicit typing, e.g. with `var x = 5` the `x` variable is set to an `int` type
## without using explicit typing using the alternate syntax: `int x = 5`
## 
## > > | | Parameter |
## > > |-|-----------|
## > > | `$1` | Variable name |
## > > | `$2` | `=` |
## > > | `$@` | Right hand side expression which is evaluated via `evaluate` |
##
var() {
  # Raise an exception if no provided arguments

  # Raise an exception if no "="
  
  # Raise an exception if no right hand side

  # Raise an exception if variable with same name already exists

  # Evaluate right hand side!
  local __T_variableName="$1"; shift
  shift; # "="

  local __T_expressionReturnTypeDescriptorCode
  # ...
}