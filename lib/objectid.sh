## # `objectid`
##
## Get the Object ID of the specified variable.
##
## Returns 1 if the variable does not exist or is not a reference type.
##
## | | Parameter |
## |-|-----------|
## | `$1` | Variable name |
## | `$2` | (Optional) name of BASH variable to store Object ID in |
##
objectid() {
  local __T_objectId_variableName="$1"; shift
  if reflection variables isReferenceType "$__T_objectId_variableName"
  then
    reflection variables getValue "$__T_objectId_variableName" "$@"
  else
    return 1
  fi
}