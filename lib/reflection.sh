## # `reflection`
##
## 
##
reflection() {
  local reflectionCommand="$1"; shift
  case "$reflectionCommand" in

    ## ## `reflection objects`
    ##
    objects)
      local BASH_VAR_PREFIX_OBJECT="T_OBJECT_"
      local objectsCommand="$1"; shift
      case "$objectsCommand" in
        ## ### `reflection objects create`
        ##
        create)
          local typeName="$1"; shift
          local referenceId="$( reflection objects generateId )"
          local bashVariableName="${BASH_VAR_PREFIX_OBJECT}${referenceId}"
          # In BASH 4.3+ use declare -g and typeset -n for safety (although eval might be faster than typeset, benchmark)
          eval "$bashVariableName=(\"$typeName\" \"\")"
          printf "$referenceId"
          ;;
        ## ### `reflection objects dispose`
        ##
        dispose)
          local referenceId="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_OBJECT}${referenceId}"
          unset "$bashVariableName"
          ;;
        ## ### `reflection objects generateId`
        ##
        generateId)
          cat /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
          ;;
        ## ### `reflection objects getField`
        ##
        getField)
          local referenceId="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_OBJECT}${referenceId}"
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
        ## ### `reflection objects list`
        ##
        list)
          ( set -o posix ; set ) | grep "^$BASH_VAR_PREFIX_OBJECT"
          ;;
        ## ### `reflection objects setField`
        ##
        setField)
          local referenceId="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_OBJECT}${referenceId}"
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
        ## ### `reflection objects show`
        ##
        show)
          local referenceId="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_OBJECT}${referenceId}"
          declare -p "$bashVariableName" | sed 's/^declare -a //'
          ;;
      esac
      ;;

    ## ## `reflection types XXX`
    ##
    types)
      local BASH_VAR_PREFIX_TYPE="T_TYPE_"
      local INDEX_OF_TYPE_NAME=0
      local INDEX_OF_TYPE_OF_TYPE=1
      local INDEX_OF_TYPE_COMMENT=2
      local INDEX_OF_BASECLASS=3
      local INDEX_OF_INTERFACE=4
      local INDEX_OF_FIELD_LOOKUP=5
      local INDEX_OF_METHOD_LOOKUP=6
      local typesCommand="$1"; shift
      case "$typesCommand" in
        ## ### `reflection types addField`
        ##
        addField)
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          local fieldName="$1"; shift
          local fieldType="$1"; shift
          local fieldDefaultValue="$1"; shift
          local fieldDefinition="$fieldName<$fieldType>$fieldDefaultValue"
          local fieldList
          eval "fieldList=\"\${$bashVariableName[$INDEX_OF_FIELD_LOOKUP]}\""
          fieldList="${fieldList};${fieldName}:\${#$bashVariableName[@]}"
          eval "$bashVariableName[$INDEX_OF_FIELD_LOOKUP]=\"$fieldList\""
          eval "$bashVariableName+=(\"$fieldDefinition\")"
          ;;
        ## ### `reflection types define`
        ##
        define)
          local typeOfType="$1"; shift
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          eval "$bashVariableName=(\"$typeName\" \"$typeOfType\" \"\" \"\" \"\" \"\" \"\")"
          ;;
        ## ### `reflection types delete`
        ##
        delete)
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          unset "$bashVariableName"
          ;;
        ## ### `reflection types getFieldType`
        ##
        getFieldType)
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          local fieldName="$1"; shift
          local fieldList
          eval "fieldList=\"\${$bashVariableName[$INDEX_OF_FIELD_LOOKUP]}\""
          if [[ "$fieldList" = *";$fieldName:"* ]]
          then
            local fieldIndex="${fieldList#*;$fieldName:}"
            local fieldIndex="${fieldIndex%%;*}"
            local fieldDefinition
            eval "fieldDefinition=\"\${$bashVariableName[$fieldIndex]}\""
            #
            local fieldType="${fieldDefinition#*<}"
            fieldType="${fieldType%%>*}"
            printf "$fieldType"
          else
            return 1
          fi
          ;;
        ## ### `reflection types list`
        ##
        list)
          ( set -o posix ; set ) | grep "^$BASH_VAR_PREFIX_TYPE"
          ;;
        ## ### `reflection types show`
        ##
        show)
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          declare -p "$bashVariableName" | sed 's/^declare -a //'
          ;;
      esac
      ;;

    ## ## `reflection variables`
    ##
    variables)
      local BASH_VAR_PREFIX_VARIABLE="T_VAR_"
      local variablesCommand="$1"; shift
      case "$variablesCommand" in
        *)
          :
          ;;
      esac
      ;;
  esac
}