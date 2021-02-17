reflection() {
  local OBJECT_BASH_VAR_PREFIX="T_OBJECT_"
  local VARIABLE_BASH_VAR_PREFIX="T_VAR_"
  local TYPE_BASH_VAR_PREFIX="T_OBJECT_TYPE_"

  local reflectionCommand="$1"; shift
  case "$reflectionCommand" in
    objects)
      local objectsCommand="$1"; shift
      case "$objectsCommand" in
        list)
          ( set -o posix ; set ) | grep "^$OBJECT_BASH_VAR_PREFIX"
          ;;
        create)
          local typeName="$1"; shift
          local referenceId="$( reflection objects generateId )"
          local bashVariableName="${OBJECT_BASH_VAR_PREFIX}${referenceId}"
          # In BASH 4.3+ use declare -g and typeset -n for safety (although eval might be faster than typeset, benchmark)
          eval "$bashVariableName=(\"$typeName\" \"\")"
          printf "$referenceId"
          ;;
        dispose)
          local referenceId="$1"; shift
          local bashVariableName="${OBJECT_BASH_VAR_PREFIX}${referenceId}"
          unset "$bashVariableName"
          ;;
        show)
          local referenceId="$1"; shift
          local bashVariableName="${OBJECT_BASH_VAR_PREFIX}${referenceId}"
          declare -p "$bashVariableName" | sed 's/^declare -a //'
          ;;
        generateId)
          cat /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
          ;;
        getField)
          local referenceId="$1"; shift
          local bashVariableName="${OBJECT_BASH_VAR_PREFIX}${referenceId}"
          local fieldName="$1"; shift
          # In BASH 4.3+ use typeset -n for safety (although eval might be faster than typeset, benchmark)
          local fieldList
          eval "fieldList=\"\${$bashVariableName[1]}\""
          if [[ "$fieldList" = *";$fieldName:"* ]]
          then
            local fieldIndex="${fieldList#*;$fieldName:}"
            local fieldIndex="${fieldIndex%%;*}"
            eval "printf '%s' \"\${$bashVariableName[$fieldIndex]}\""
          else
            return 1
          fi
          ;;
        setField)
          local referenceId="$1"; shift
          local bashVariableName="${OBJECT_BASH_VAR_PREFIX}${referenceId}"
          local fieldName="$1"; shift
          local fieldValue="$1"; shift
          # In BASH 4.3+ use typeset -n for safety (although eval might be faster than typeset, benchmark)
          local fieldList
          eval "fieldList=\"\${$bashVariableName[1]}\""
          if [[ "$fieldList" = *";$fieldName:"* ]]
          then          
            local fieldIndex="${fieldList#*;$fieldName:}"
            local fieldIndex="${fieldIndex%%;*}"
            eval "$bashVariableName[$fieldIndex]=\"$fieldValue\""
          else
            eval "$bashVariableName[1]=\"${fieldList};${fieldName}:\${#$bashVariableName[@]}\";"
            eval "$bashVariableName+=(\"$fieldValue\")"
          fi
          ;;
      esac
      ;;
    utils)
      :
      ;;
  esac
}