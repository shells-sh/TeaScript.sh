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

  local returnType=void
  local instantiatingClass=false
  local invokingMethod=false

  declare -a currentExpression=()
  declare -a currentParameters=()

  while [ $# -gt 0 ]
  do
    local currentToken="$1"; shift
    echo "Evaluating token: $currentToken"

    if [ "$currentToken" = new ]
    then
      # Class constructor
      # - is the next token the type?
      # - or is the next token a param:
      # - or is the next token a method invocation?
      # - or is the next token an operator?
      if [ $# -gt 0 ]
      then      
        if [[ "$1" = *":" ]]
        then
          [ -n "$T_HINT_TYPE" ] && { echo "class constructor: $T_HINT_TYPE"; returnType="$T_HINT_TYPE"; }
          : # parameter to constructor - gather them now, here :)
        elif [[ "$1" = "."* ]]
        then
          : # method invocation, finished with class parameters
        elif [ "$1" = "Somehow Match for all operators to see of the next is an operator" ]
        then
          :
          echo "do operators..."
        else
          if reflection types exists "$1"
          then
            echo "Evaluating $1: type found"
            echo "class constructor: $1"
            returnType="$1"
            shift
          else
            : #?            
            echo "Evaluating $1: not a type"
          fi
        fi
      elif [ -z "$T_HINT_TYPE" ]
      then
        echo "class constructur: <could not determine type>"
      else
        echo "class constructor: $T_HINT_TYPE"
      fi
    fi


    # Starts with a class constructor

  done

  echo "Return type: $returnType"
}