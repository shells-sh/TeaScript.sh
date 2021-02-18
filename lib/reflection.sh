## # `reflection`
##
## 
##
reflection() {
  local reflectionCommand="$1"; shift
  case "$reflectionCommand" in

    ## ## `reflection invocations`
    ##
    ## This might be what we call to invoke methods and see if they're available etc (?)
    ##
    ## Might also have a `reflection expressions` for validating and evaluating expressions :)
    ##
    invocations)
      local BASH_VAR_PREFIX_VARIABLE="T_VAR_"
      local invocationsCommand="$1"; shift
      case "$invocationsCommand" in
        *)
          :
          ;;
      esac
      ;;

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
          local objectId="$( reflection objects generateId )"
          local bashVariableName="${BASH_VAR_PREFIX_OBJECT}${objectId}"
          # In BASH 4.3+ use declare -g and typeset -n for safety (although eval might be faster than typeset, benchmark)
          eval "$bashVariableName=(\"$typeName\" \"\")"
          printf "$objectId"
          ;;
        ## ### `reflection objects dispose`
        ##
        dispose)
          local objectId="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_OBJECT}${objectId}"
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
          local objectId="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_OBJECT}${objectId}"
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
          local objectId="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_OBJECT}${objectId}"
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
          local objectId="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_OBJECT}${objectId}"
          declare -p "$bashVariableName" | sed 's/^declare -a //'
          ;;
      esac
      ;;

    ## ## `reflection types XXX`
    ##
    types)
      local BASH_VAR_PREFIX_TYPE="T_TYPE_"
      local INDEX_OF_TYPE_OF_TYPE=0
      local INDEX_OF_TYPE_COMMENT=1
      local INDEX_OF_BASECLASS=2
      local INDEX_OF_INTERFACE=3
      local INDEX_OF_FIELD_LOOKUP=4
      local INDEX_OF_METHOD_LOOKUP=5
      local typesCommand="$1"; shift
      case "$typesCommand" in
        ## ### `reflection types addField`
        ##
        addField)
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          local fieldScope="$1"; shift
          local fieldVisibility="$1"; shift
          local fieldName="$1"; shift
          local fieldType="$1"; shift
          local fieldDefaultValue="$1"; shift
          local fieldComment="$1"; shift
          local fieldDefinition="$fieldScope!$fieldVisibility|$fieldName<$fieldType>$fieldDefaultValue&$fieldComment"
          local fieldList
          eval "fieldList=\"\${$bashVariableName[$INDEX_OF_FIELD_LOOKUP]}\""
          fieldList="${fieldList};${fieldName}:\${#$bashVariableName[@]}"
          eval "$bashVariableName[$INDEX_OF_FIELD_LOOKUP]=\"$fieldList\""
          eval "$bashVariableName+=(\"$fieldDefinition\")"
          ;;
        ## ### `reflection types addMethod`
        ##
        addMethod)
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          local methodScope="$1"; shift
          local methodVisibility="$1"; shift
          local methodName="$1"; shift
          local methodReturnType="$1"; shift
          local methodComment="$1"; shift
          local methodDefinition="$methodScope!$methodVisibility|$methodName<$methodReturnType>$methodComment"
          while [ $# -gt 0 ]
          do
            local paramName="$1"; shift
            local paramType="$1"; shift
            local paramDefaultValue="$1"; shift
            local paramDefinition="$paramName:$paramType;$paramDefaultValue"
            methodDefinition="${methodDefinition}&${paramDefinition}"
          done
          local methodList
          eval "methodList=\"\${$bashVariableName[$INDEX_OF_METHOD_LOOKUP]}\""
          methodList="${methodList};${methodName}:\${#$bashVariableName[@]}"
          eval "$bashVariableName[$INDEX_OF_METHOD_LOOKUP]=\"$methodList\""
          eval "$bashVariableName+=(\"$methodDefinition\")"
          ;;
        ## ### `reflection types define`
        ##
        define)
          local typeOfType="$1"; shift
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          local comment="$1"; shift
          local baseClassName="$1"; shift
          local interfaceName="$1"; shift
          eval "$bashVariableName=(\"$typeOfType\" \"$comment\" \"$baseClassName\" \"$interfaceName\" \"\" \"\")"
          ;;
        ## ### `reflection types undefine`
        ##
        undefine)
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          unset "$bashVariableName"
          ;;
        ## ### `reflection types getFieldComment`
        ##
        getFieldComment)
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
            # Get the field comment from the field definition
            local fieldComment="${fieldDefinition##*&}"
            printf "$fieldComment"
          else
            return 1
          fi
          ;;
        ## ### `reflection types getFieldDefaultValue`
        ##
        getFieldDefaultValue)
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
            # Get the field default value from the field definition
            local fieldDefaultValue="${fieldDefinition##*>}"
            fieldDefaultValue="${fieldDefaultValue%%&*}"
            printf "$fieldDefaultValue"
          else
            return 1
          fi
          ;;
        ## ### `reflection types getFieldScope`
        ##
        getFieldScope)
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
            # Get the field scope from the field definition
            local fieldScope="${fieldDefinition%%!*}"
            printf "$fieldScope"
          else
            return 1
          fi
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
            # Get the field type from the field definition
            local fieldType="${fieldDefinition#*<}"
            fieldType="${fieldType%%>*}"
            printf "$fieldType"
          else
            return 1
          fi
          ;;
        ## ### `reflection types getFieldVisibility`
        ##
        getFieldVisibility)
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
            # Get the field visibility from the field definition
            local fieldVisibility="${fieldDefinition%%|*}"
            fieldVisibility="${fieldVisibility##*!}"
            printf "$fieldVisibility"
          else
            return 1
          fi
          ;;
        ## ### `reflection types getMethodComment`
        ##
        getMethodComment)
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          local methodName="$1"; shift
          local methodList
          eval "methodList=\"\${$bashVariableName[$INDEX_OF_METHOD_LOOKUP]}\""
          if [[ "$methodList" = *";$methodName:"* ]]
          then
            local methodIndex="${methodList#*;$methodName:}"
            local methodIndex="${methodIndex%%;*}"
            local methodDefinition
            eval "methodDefinition=\"\${$bashVariableName[$methodIndex]}\""
            # Get the method comment from the method definition
            local methodComment="${methodDefinition##*>}"
            methodComment="${methodComment%%&*}"
            printf "$methodComment"
          else
            return 1
          fi
          ;;
        ## ### `reflection types getMethodParamNames`
        ##
        getMethodParamNames)
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          local methodName="$1"; shift
          local methodList
          eval "methodList=\"\${$bashVariableName[$INDEX_OF_METHOD_LOOKUP]}\""
          if [[ "$methodList" = *";$methodName:"* ]]
          then
            local methodIndex="${methodList#*;$methodName:}"
            local methodIndex="${methodIndex%%;*}"
            local methodDefinition
            eval "methodDefinition=\"\${$bashVariableName[$methodIndex]}\""
            # Get the method param names from the method definition
            if [[ "$methodDefinition" = *"&"* ]]
            then
              local methodParamNames=""
              local methodParamDefinitions="${methodDefinition#*&}"
              while [[ "$methodParamDefinitions" = *":"* ]]
              do
                methodParamDefinitions="${methodParamDefinitions%:*}"
                methodParamNames="${methodParamDefinitions##*&} ${methodParamNames}"
              done
              printf "${methodParamNames% }"
            else
              return 1
            fi
          else
            return 1
          fi
          ;;
        ## ### `reflection types getMethodParamDefaultValue`
        ##
        getMethodParamDefaultValue)
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          local methodName="$1"; shift
          local paramName="$1"; shift
          local methodList
          eval "methodList=\"\${$bashVariableName[$INDEX_OF_METHOD_LOOKUP]}\""
          if [[ "$methodList" = *";$methodName:"* ]]
          then
            local methodIndex="${methodList#*;$methodName:}"
            local methodIndex="${methodIndex%%;*}"
            local methodDefinition
            eval "methodDefinition=\"\${$bashVariableName[$methodIndex]}\""
            # Get the method param default value from the method definition
            if [[ "$methodDefinition" = *"&"* ]]
            then
              local paramDefaultValue="${methodDefinition##*&$paramName:}"
              paramDefaultValue="${paramDefaultValue#*;}"
              paramDefaultValue="${paramDefaultValue%%&*}"
              printf "$paramDefaultValue"
            else
              return 1
            fi
          else
            return 1
          fi
          ;;
        ## ### `reflection types getMethodParamType`
        ##
        getMethodParamType)
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          local methodName="$1"; shift
          local paramName="$1"; shift
          local methodList
          eval "methodList=\"\${$bashVariableName[$INDEX_OF_METHOD_LOOKUP]}\""
          if [[ "$methodList" = *";$methodName:"* ]]
          then
            local methodIndex="${methodList#*;$methodName:}"
            local methodIndex="${methodIndex%%;*}"
            local methodDefinition
            eval "methodDefinition=\"\${$bashVariableName[$methodIndex]}\""
            # Get the method param type from the method definition
            if [[ "$methodDefinition" = *"&"* ]]
            then
              local paramType="${methodDefinition##*&$paramName:}"
              paramType="${paramType%%;*}"
              printf "$paramType"
            else
              return 1
            fi
          else
            return 1
          fi
          ;;
        ## ### `reflection types getMethodReturnType`
        ##
        getMethodReturnType)
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          local methodName="$1"; shift
          local methodList
          eval "methodList=\"\${$bashVariableName[$INDEX_OF_METHOD_LOOKUP]}\""
          if [[ "$methodList" = *";$methodName:"* ]]
          then
            local methodIndex="${methodList#*;$methodName:}"
            local methodIndex="${methodIndex%%;*}"
            local methodDefinition
            eval "methodDefinition=\"\${$bashVariableName[$methodIndex]}\""
            # Get the method type from the method definition
            local methodType="${methodDefinition#*<}"
            methodType="${methodType%%>*}"
            printf "$methodType"
          else
            return 1
          fi
          ;;
        ## ### `reflection types getMethodScope`
        ##
        getMethodScope)
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          local methodName="$1"; shift
          local methodList
          eval "methodList=\"\${$bashVariableName[$INDEX_OF_METHOD_LOOKUP]}\""
          if [[ "$methodList" = *";$methodName:"* ]]
          then
            local methodIndex="${methodList#*;$methodName:}"
            local methodIndex="${methodIndex%%;*}"
            local methodDefinition
            eval "methodDefinition=\"\${$bashVariableName[$methodIndex]}\""
            # Get the method scope from the method definition
            local methodScope="${methodDefinition%%!*}"
            printf "$methodScope"
          else
            return 1
          fi
          ;;
        ## ### `reflection types getMethodVisibility`
        ##
        getMethodVisibility)
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          local methodName="$1"; shift
          local methodList
          eval "methodList=\"\${$bashVariableName[$INDEX_OF_METHOD_LOOKUP]}\""
          if [[ "$methodList" = *";$methodName:"* ]]
          then
            local methodIndex="${methodList#*;$methodName:}"
            local methodIndex="${methodIndex%%;*}"
            local methodDefinition
            eval "methodDefinition=\"\${$bashVariableName[$methodIndex]}\""
            # Get the method visibility from the method definition
            local methodVisibility="${methodDefinition%%|*}"
            methodVisibility="${methodVisibility##*!}"
            printf "$methodVisibility"
          else
            return 1
          fi
          ;;
        ## ### `reflection types getTypeBaseClass`
        ##
        getTypeBaseClass)
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          eval "printf '%s' \"\${$bashVariableName[$INDEX_OF_BASECLASS]}\""
          ;;
        ## ### `reflection types getTypeComment`
        ##
        getTypeComment)
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          eval "printf '%s' \"\${$bashVariableName[$INDEX_OF_TYPE_COMMENT]}\""
          ;;
        ## ### `reflection types getTypeOfType`
        ##
        getTypeOfType)
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          eval "printf '%s' \"\${$bashVariableName[$INDEX_OF_TYPE_OF_TYPE]}\""
          ;;
        ## ### `reflection types getTypeInterface`
        ##
        getTypeInterface)
          local typeName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_TYPE}${typeName}"
          eval "printf '%s' \"\${$bashVariableName[$INDEX_OF_INTERFACE]}\""
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

    ## ## `reflection snapshots`
    ##
    ## You can save the state of your TeaScript program to a snapshot and load it later.
    ##
    ## You can specify whether to snapshot just types or also variables etc.
    ##
    ## Can be serialized and reloaded for faster program boot time.
    ##
    ## Can reduce snapshot size as well with option to remove all type comments.
    ##
    snapshots)
      local BASH_VAR_PREFIX_VARIABLE="T_VAR_"
      local snapshotsCommand="$1"; shift
      case "$snapshotsCommand" in
        *)
          :
          ;;
      esac
      ;;

    ## ## `reflection variables`
    ##
    variables)
      local BASH_VAR_PREFIX_VARIABLE="T_VAR_"
      local INDEX_OF_VARIABLE_TYPE=0
      local INDEX_OF_VARIABLE_VALUE=1
      local INDEX_OF_VARIABLE_REFERENCE_ID=2
      local variablesCommand="$1"; shift
      case "$variablesCommand" in
        ## ### `reflection variables getObjectId`
        ##
        getObjectId)
          local variableName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_VARIABLE}${variableName}"
          eval "printf '%s' \"\${$bashVariableName[$INDEX_OF_VARIABLE_REFERENCE_ID]}\""
          ;;
        ## ### `reflection variables getType`
        ##
        getType)
          local variableName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_VARIABLE}${variableName}"
          eval "printf '%s' \"\${$bashVariableName[$INDEX_OF_VARIABLE_TYPE]}\""
          ;;
        ## ### `reflection variables getValue`
        ##
        getValue)
          local variableName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_VARIABLE}${variableName}"
          eval "printf '%s' \"\${$bashVariableName[$INDEX_OF_VARIABLE_VALUE]}\""
          ;;
        ## ### `reflection variables list`
        ##
        list)
          ( set -o posix ; set ) | grep "^$BASH_VAR_PREFIX_VARIABLE"
          ;;
        ## ### `reflection variables set`
        ##
        set)
          local variableName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_VARIABLE}${variableName}"
          local variableType="$1"; shift
          local variableValue="$1"; shift
          local variableObjectId="$1"; shift
          eval "$bashVariableName=(\"$variableType\" \"$variableValue\" \"$variableObjectId\")"
          ;;
        ## ### `reflection variables show`
        ##
        show)
          local variableName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_VARIABLE}${variableName}"
          declare -p "$bashVariableName" | sed 's/^declare -a //'
          ;;
        ## ### `reflection variables unset`
        ##
        unset)
          local variableName="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_VARIABLE}${variableName}"
          unset "$bashVariableName"
          ;;
      esac
      ;;
  esac
}