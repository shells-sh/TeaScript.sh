typeof() {
  local __T_firstArg="$1"; shift
  reflection variables getType "$__T_firstArg" "$@" || reflection types getDescriptor "$(reflection reflectionType "$__T_firstArg")" "$@"
}