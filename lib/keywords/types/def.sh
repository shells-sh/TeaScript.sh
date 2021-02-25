def() {
  local __T_typeName
  local __T_methodName
  # local __T_comment

  if [[ "$1" = *"."* ]]
  then
    __T_typeName="${1%%.*}"
    __T_methodName="${1#*.}"
    shift
  elif [ -n "$T_DO" ]
  then
    __T_typeName="$T_DO"
    __T_methodName="$1"
    shift
  fi

  local __T_safeTypeName
  reflection safeName "$__T_typeName" __T_safeTypeName
  reflection types methods define "$__T_safeTypeName" "$__T_methodName"

  # Clean up and rethink, but make it work for now:
  local __T_safeMethodName
  reflection safeName "$__T_methodName" __T_safeMethodName
  T_METHOD_DEF="$__T_safeTypeName $__T_safeMethodName"
}