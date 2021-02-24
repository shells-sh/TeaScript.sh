field() {
  if [[ "$1" = *"."* ]]
  then
    local __T_typeName="${1%%.*}"
    local __T_fieldName="${1#*.}"
    shift
  else
    if [ -n "$T_DO" ]
    then
      local __T_typeName="$T_DO"
      local __T_fieldName="$1"
      shift
    else
      echo "What type should I use for field $1?"
      return 1
    fi
  fi

  if [ "$1" = "=" ] || [ $# -eq 0 ]
  then
    local __T_fieldType=string
  else
    local __T_fieldType="$1"
    shift
  fi

  local __T_defaultValue=""
  if [ "$1" = "=" ]
  then
    shift
    __T_defaultValue="$1"
    shift
  fi

  if [ $# -gt 0 ]
  then
    echo "Unexpected field arguments: $*"
    return 1
  fi

  if [ -n "$T_VISIBILITY" ]
  then
    local __T_visibility="$T_VISIBILITY"
  else
    local __T_visibility=P # public by default
  fi

  if [ -n "$T_SCOPE" ]
  then
    local __T_scope="$T_SCOPE"
  else
    local __T_scope=i # instance by default
  fi

  # TODO update so that comments can have indentation, this strips all indentation
  if [ "$T_COMMENTS" = enabled ] && read -t 0 -N 0
  then
    local __T_comment="$(</dev/stdin)"
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
  else
    local __T_comment=""
  fi

  reflection types fields define "$( reflection safeName "$__T_typeName" )" "$__T_fieldName" "$__T_fieldType" "$__T_scope" "$__T_visibility" "$__T_defaultValue" "$__T_comment"
}