## # `param`
##
## Defines a method parameter
##
## ```sh
## class DogCollection
##
##   def add
##   param Dog dog : The dog to add to the collection
##   Dog.add() {
##     :
##   }
##
## end
## ```
##
param() {
  [ -z "$T_METHOD_DEF" ] && { echo "'param' called without 'def' to add parameter to" >&2; return 1; }

  local __T_paramType="$1"; shift
  local __T_paramName="$1"; shift
  local __T_paramModifier=val
  local __T_paramDefaultValue
  local __T_paramComment
  if [ $# -gt 0 ] && ! [ "$1" = "=" ] && ! [ "$1" = ":" ]
  then
    __T_paramModifier="$__T_paramName"
    __T_paramName="$1"
    shift
  fi
  if [ "$1" = "=" ]
  then
    shift
    __T_defaultValue="$1"
    shift
  fi
  if [ "$1" = ":" ]
  then
    shift
    __T_comment="$*"
    __T_comment="${__T_comment#"${__T_comment%%[![:space:]]*}"}" # trim spaces
    __T_comment="${__T_comment%"${__T_comment##*[![:space:]]}"}" # trim spaces
    if shopt -q extglob
    then
      __T_comment="${__T_comment//$'\n'+([[:space:]])/$'\n'}"
    else
      shopt -s extglob
      __T_comment="${__T_comment//$'\n'+([[:space:]])/$'\n'}"
      shopt -u extglob
    fi
  fi

  local __T_paramModifierCode
  reflection getCode "$__T_paramModifier" __T_paramModifierCode

  reflection types methods params define $T_METHOD_DEF "$__T_paramName" "$__T_paramType" "$__T_paramModifierCode" "$__T_defaultValue" "$__T_comment"
}