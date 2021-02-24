field() {
  local __T_typeName
  local __T_fieldName
  local __T_fieldType
  local __T_defaultValue
  local __T_comment

  if [ -n "$T_DO" ]
  then
    __T_typeName="$T_DO"
    __T_fieldType="$1"
    shift
    if [ $# -eq 0 ] || [ "$1" = "=" ] || [ "$1" = ":" ]
    then
      __T_fieldName="$__T_fieldType"
      __T_fieldType=string
    else
      __T_fieldName="$1"
      shift
    fi
  elif [[ "$1" = *"."* ]]
  then
    __T_fieldType=string
    __T_typeName="${1%%.*}"
    __T_fieldName="${1#*.}"
    shift
  elif [[ "$2" = *"."* ]]
  then
    __T_fieldType="$1"
    __T_typeName="${2%%.*}"
    __T_fieldName="${2#*.}"
    shift; shift;
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
  elif [ $# -gt 0 ]
  then
  __T_comment=B
    echo "Unexpected field arguments: $*"
    return 1
  fi

  if [ -n "$T_VISIBILITY" ]
  then
    local __T_visibility="$T_VISIBILITY"
  else
    local __T_visibility=p # private by default
  fi

  if [ -n "$T_SCOPE" ]
  then
    local __T_scope="$T_SCOPE"
  else
    local __T_scope=i # instance by default
  fi

  reflection types fields define "$( reflection safeName "$__T_typeName" )" "$__T_fieldName" "$__T_fieldType" "$__T_scope" "$__T_visibility" "$__T_defaultValue" "$__T_comment"
}