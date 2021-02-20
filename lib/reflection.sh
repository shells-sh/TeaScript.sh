## # `$ reflection`
##
## 🍵 TeaScript Reflection API
##
## TeaScript `reflection` provides a read-only interface for introspecting
## on TeaScript types and variables as well as a write interface for defining
## or making changes to types.
##
## ## Reference
##
## - [`reflection objects`](#reflection-objects)
## - [`reflection types`](#reflection-types)
## - [`reflection variables`](#reflection-variables)
##
## ```sh
## class Dog implements IAnimal do <<- _
##   Represents a dog
##   _
##
##   field name: String
##   field age: Integer
## end
##
## reflection types getTypeInterface Dog
## # => "IAnimal"
##
## reflection types getTypeComment Dog
## # => "Represents a dog"
##
## reflection types getFieldNames Dog
## # => "name age"
##
## reflection types getFieldType Dog age
## # => "Integer"
## ```
##
## > ℹ️ Note: `reflection` performs no argument assertions or validation  
## > e.g. you can create a variable of a type that does not exist using `reflection variables`.
## >
## > Higher-level functions such as `var` and `class` and `def` perform these assertions and type-checking.
##
## ## 💻 Developer Notes
##
## > _Inline all the things!_
##
## 🌶️ **Reminder:** most of this file is in the _very hot path_ of TeaScript!
##
## Do not attempt to "DRY" this code or refactor it to use meaningful variable names.
## 
## This code should be "wet" with as much inline code as possible.
## 
## **Never** attempt to refactor code into utility methods and, for example, then call `reflection utils something` within you code. Just - NO.
##
## To the extent possible, **never** start any subshells or run other programs. This means NO `grep` or `sed` or `awk`. Use built-in BASH string manipulation when possible.
##
## Try not to allocate new native BASH variables. Instead, reuse variables as much as possible (_and limit use of variables, in general - prefer literal strings_).
##
## Do not loop over values. Usually, if you are writing a loop, you are adding an `O(N)`` or worse, do not do it.
## Notable exception for [`addMethod`]() which takes a dynamic number of arguments for defining any number of parameters.
## In general, keep everything `O(1)` as much as possible. User-friendly functions which are not on the hot path are allowed
## to break these rules.
##
## ### `eval`
##
## To start with, various functions make use of `eval`. In fact, most do.
##
## This is to support Mac's built-in version of BASH, which is BASH `3.2.57` and will always be this version due to `GPL` licensing.
##
## After `reflection.sh` is mostly "complete" (_i.e. once `var` and `expression` and `class` and `def` are fully up-and-running_)
## we will add Docker tests for both BASH `3.2.57` as well as the latest versions of BASH 5 which is distributed
## with Linux and used on Windows as well and create 2 versions of `reflection.sh`, one targetting BASH 4.3+ which removes all use of `eval`.
##
## > ℹ️ `eval` is used for defining single-dimensional array variables with dynamic names
## > and modifying or reading from those arrays. In BASH 4.3+ these operations are doable by making
## > use of `declare -g` and `typeset -n`.
## >
## > When we create the `eval`less version of `reflection.sh`, we will do benchmarking to see if the `eval`less
## > version is _faster_ on BASH 5 or if it's actually slower than `eval`.
## > It might turn out that `typeset -n` is prohibitively slow and the copy of `reflection.sh`
## > might just use `declare -g` but otherwise be identical. We will see! Can't wait to try and to benchmark :)
##
## ### `p` private -_vs_- `P` public
##
## Some of this code uses user-unfriendly archaic looking characters to represent various bits of type metadata.
##
## This contains a lookup table for all characters.
##
## > Note: most of the read-only reflection functions such as `reflection types getFieldVisibility` return friendly names such as `public` or `private`.
## >
## > These functions are not used in any path of the core TeaScript engine and perform name conversions.
## >
## > Other functions such as `reflection types define` expect these characters to be provided as arguments and _do not support_ friendly names such as `public` (use `P` instead).
## >
## > All functions used by the core TeaScript engine are marked with the hot pepper noting the hot path 🌶️ (TODO!)
##
## | Character | Meaning |
## |-----------|---------|
## | `a` | `abstract` |
## | `c` | `class` |
## | `i` | `interface` |
## | `n` | Named reference, e.g. marking a variable as being a reference to another variable |
## | `p` | `private` |
## | `P` | `public` |
## | `r` | Reference, e.g. marking a type as being a reference type or a variable as containing a reference |
## | `s` | `struct` |
## | `S` | `static` |
## | `v` | Value, e.g. marking a type as being a value type or a variable as containing a value |
##
reflection() {
  case "$1" in
    ## ## `reflection invocations`
    ##
    ## This might be what we call to invoke methods and see if they're available etc (?)
    ##
    ## Might also have a `reflection expressions` for validating and evaluating expressions :)
    ##
    invocations)
      # TODO REMOVE THESE VARS
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
    ## Manages the TeaScript **Heap** where objects are allocated.
    ##
    ##
    ##
    ##
    ##
    ##
    objects)
      # TODO REMOVE THIS VAR
      local BASH_VAR_PREFIX_OBJECT="T_OBJECT_"
      # TODO REMOVE THIS VAR
      local objectsCommand="$1"; shift
      case "$objectsCommand" in
        ## ### `reflection objects create`
        ##
        create)
          local typeName="$1"; shift
          # TODO inline the random subshell here!
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
          # TODO MOVE THIS INTO THE define FUNCTION or create or whatever - or allocate
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
        ## > 🚨 Expensive. Reminder: do not use this in the hot path. This is for users.
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
        ## > 🚨 Expensive. Reminder: do not use this in the hot path. This is for users.
        ##
        show)
          local objectId="$1"; shift
          local bashVariableName="${BASH_VAR_PREFIX_OBJECT}${objectId}"
          declare -p "$bashVariableName" | sed 's/^declare -a //'
          ;;
      esac
      ;;

    ## ## `reflection types`
    ##
    ## `TODO` - space optimizations, which'll make it all harder to read, use COMMENTS 
    ## - addField p s v main string[] args "" <-- public static void
    ##   - CALLER needs to use this arcane language so that `reflection` doesn't need any conditionals
    ##   - `reflection` should do conversions only when responding to `getXY` and should check against them when `isPublic` etc
    ## - combine 'class' (c, i, s, e int stru enum) and value/object (v/o) and if it has literal support (y/n or l/n) <-- don't look at methods, would have to get method def to check if its static
    ##
    ## local INDEX_OF_TYPE_OF_TYPE=0
    ## local INDEX_OF_STORAGE_TYPE=1
    ## local INDEX_OF_TYPE_COMMENT=2
    ## local INDEX_OF_BASECLASS=3
    ## local INDEX_OF_INTERFACE=4
    ## local INDEX_OF_FIELD_LOOKUP=5
    ## local INDEX_OF_METHOD_LOOKUP=6
    ## local BASH_VAR_PREFIX_TYPE="T_TYPE_"
    ##
    types)
      # TODO - reflection types methods getReturnType Dog bark
      # TODO - reflection types fields add Dog ...
      # or
      # TODO - reflection methods getReturnType Dog bark
      # TODO - reflection fields add Dog ...

      # REMOVE ALL THESE LOCALS AND USE INTEGERS IN CODE - don't want any variables being created for reflection calls please :)
      # ^--- remove this too
      local typesCommand="$1"; shift
      case "$typesCommand" in
        ## ### `reflection types addField`
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        addField)
          local typeName="$1"; shift
          local bashVariableName="T_TYPE_${typeName}"
          local fieldScope="$1"; shift
          local fieldVisibility="$1"; shift
          local fieldName="$1"; shift
          local fieldType="$1"; shift
          local fieldDefaultValue="$1"; shift
          local fieldComment="$1"; shift
          local fieldDefinition="$fieldScope!$fieldVisibility|$fieldName<$fieldType>$fieldDefaultValue&$fieldComment"
          local fieldList
          eval "fieldList=\"\${$bashVariableName[5]}\""
          fieldList="${fieldList};${fieldName}:\${#$bashVariableName[@]}"
          eval "$bashVariableName[5]=\"$fieldList\""
          eval "$bashVariableName+=(\"$fieldDefinition\")"
          ;;

        ## ### `reflection types addMethod`
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        addMethod)
          local typeName="$1"; shift
          local bashVariableName="T_TYPE_${typeName}"
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
          eval "methodList=\"\${$bashVariableName[6]}\""
          methodList="${methodList};${methodName}:\${#$bashVariableName[@]}"
          eval "$bashVariableName[6]=\"$methodList\""
          eval "$bashVariableName+=(\"$methodDefinition\")"
          ;;

        ## ### `reflection types define`
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        define)
          local typeOfType="$1"; shift
          local typeName="$1"; shift
          local bashVariableName="T_TYPE_${typeName}"
          local storageType="$1"; shift
          local comment="$1"; shift
          local baseClassName="$1"; shift
          local interfaceName="$1"; shift
          eval "$bashVariableName=(\"$typeOfType\" \"$storageType\" \"$comment\" \"$baseClassName\" \"$interfaceName\" \"\" \"\")"
          ;;
        ## ### `reflection types undefine`
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        undefine)
          local typeName="$1"; shift
          local bashVariableName="T_TYPE_${typeName}"
          unset "$bashVariableName"
          ;;

        ## ### `reflection types getFieldComment`
        ##
        ## Get the comment of a field, if present.
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | `getFieldComment` |
        ## | `$4` | Type name, e.g. `Dog` |
        ## | `$5` | Field name, e.g. `name` |
        ##
        getFieldComment)
          local localTempVariable
          eval "localTempVariable=\"\${T_TYPE_$1[5]}\""
          if [[ "$localTempVariable" = *";$2:"* ]]
          then
            localTempVariable="${localTempVariable#*;$2:}"
            localTempVariable="${localTempVariable%%;*}"
            eval "localTempVariable=\"\${T_TYPE_$1[$localTempVariable]}\""
            # Return the field comment from the field definition:
            printf "${localTempVariable##*&}"
          else
            return 1
          fi
          ;;

        ## ### `reflection types getFieldDefaultValue`
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | `getFieldDefaultValue` |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        getFieldDefaultValue)
          local localTempVariable
          eval "localTempVariable=\"\${T_TYPE_$1[5]}\""
          if [[ "$localTempVariable" = *";$2:"* ]]
          then
            localTempVariable="${localTempVariable#*;$2:}"
            localTempVariable="${localTempVariable%%;*}"
            eval "localTempVariable=\"\${T_TYPE_$1[$localTempVariable]}\""
            # Return the field default value from the field definition
            localTempVariable="${localTempVariable##*>}"
            printf "${localTempVariable%%&*}"
          else
            return 1
          fi
          ;;

        ## ### `reflection types getFieldScope`
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | `getFieldScope` |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        getFieldScope)
          local localTempVariable
          eval "localTempVariable=\"\${T_TYPE_$1[5]}\""
          if [[ "$localTempVariable" = *";$2:"* ]]
          then
            localTempVariable="${localTempVariable#*;$2:}"
            localTempVariable="${localTempVariable%%;*}"
            eval "localTempVariable=\"\${T_TYPE_$1[$localTempVariable]}\""
            # Return the field scope from the field definition:
            printf "${localTempVariable%%!*}"
          else
            return 1
          fi
          ;;

        ## ### `reflection types getFieldType`
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | `getFieldType` |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        getFieldType)
          ## UPDATE ME
          local typeName="$1"; shift
          local bashVariableName="T_TYPE_${typeName}"
          local fieldName="$1"; shift
          local fieldList
          eval "fieldList=\"\${$bashVariableName[5]}\""
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
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | `getFieldVisibility` |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        getFieldVisibility)
          ## UPDATE ME
          local typeName="$1"; shift
          local bashVariableName="T_TYPE_${typeName}"
          local fieldName="$1"; shift
          local fieldList
          eval "fieldList=\"\${$bashVariableName[5]}\""
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
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | `getMethodComment` |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        getMethodComment)
          ## UPDATE ME
          local typeName="$1"; shift
          local bashVariableName="T_TYPE_${typeName}"
          local methodName="$1"; shift
          local methodList
          eval "methodList=\"\${$bashVariableName[6]}\""
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
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | `getMethodParamNames` |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        getMethodParamNames)
          ## UPDATE ME
          local typeName="$1"; shift
          local bashVariableName="T_TYPE_${typeName}"
          local methodName="$1"; shift
          local methodList
          eval "methodList=\"\${$bashVariableName[6]}\""
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
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | `getMethodParamDefaultValue` |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        getMethodParamDefaultValue)
          ## UPDATE ME
          local typeName="$1"; shift
          local bashVariableName="T_TYPE_${typeName}"
          local methodName="$1"; shift
          local paramName="$1"; shift
          local methodList
          eval "methodList=\"\${$bashVariableName[6]}\""
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
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | `getMethodParamType` |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        getMethodParamType)
          ## UPDATE ME
          local typeName="$1"; shift
          local bashVariableName="T_TYPE_${typeName}"
          local methodName="$1"; shift
          local paramName="$1"; shift
          local methodList
          eval "methodList=\"\${$bashVariableName[6]}\""
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
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | `getMethodReturnType` |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        getMethodReturnType)
          ## UPDATE ME
          local typeName="$1"; shift
          local bashVariableName="T_TYPE_${typeName}"
          local methodName="$1"; shift
          local methodList
          eval "methodList=\"\${$bashVariableName[6]}\""
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
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | `getMethodScope` |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        getMethodScope)
          ## UPDATE ME
          local typeName="$1"; shift
          local bashVariableName="T_TYPE_${typeName}"
          local methodName="$1"; shift
          local methodList
          eval "methodList=\"\${$bashVariableName[6]}\""
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
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | `getMethodVisibility` |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        getMethodVisibility)
          ## UPDATE ME
          local typeName="$1"; shift
          local bashVariableName="T_TYPE_${typeName}"
          local methodName="$1"; shift
          local methodList
          eval "methodList=\"\${$bashVariableName[6]}\""
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
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | `getTypeBaseClass` |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        getTypeBaseClass)
          ## UPDATE ME
          local typeName="$1"; shift
          local bashVariableName="T_TYPE_${typeName}"
          eval "printf '%s' \"\${$bashVariableName[3]}\""
          ;;

        ## ### `reflection types getTypeComment`
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | `getTypeComment` |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        getTypeComment)
          ## UPDATE ME
          local typeName="$1"; shift
          local bashVariableName="T_TYPE_${typeName}"
          eval "printf '%s' \"\${$bashVariableName[2]}\""
          ;;

        ## ### `reflection types getTypeOfType`
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | `getTypeOfType` |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        getTypeOfType)
          ## UPDATE ME
          local typeName="$1"; shift
          local bashVariableName="T_TYPE_${typeName}"
          eval "printf '%s' \"\${$bashVariableName[0]}\""
          ;;

        ## ### `reflection types getTypeInterface`
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | `getTypeInterface` |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        getTypeInterface)
          ## UPDATE ME
          local typeName="$1"; shift
          local bashVariableName="T_TYPE_${typeName}"
          eval "printf '%s' \"\${$bashVariableName[4]}\""
          ;;

        ## ### `reflection types getTypeStorageType`
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | `getTypeStorageType` |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        getTypeStorageType)
          ## UPDATE ME
          local typeName="$1"; shift
          local bashVariableName="T_TYPE_${typeName}"
          eval "printf '%s' \"\${$bashVariableName[1]}\""
          ;;

        ## ### `reflection types list`
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        list)
          ( set -o posix ; set ) | grep "^$BASH_VAR_PREFIX_TYPE"
          ;;

        ## ### `reflection types show`
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `types` |
        ## | `$3` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ## | `$x` | ... |
        ##
        show)
          ## UPDATE ME
          local typeName="$1"; shift
          local bashVariableName="T_TYPE_${typeName}"
          declare -p "$bashVariableName" | sed 's/^declare -a //'
          ;;

        *)
          echo "Unknown 'reflection types' command: $2"
          return 1
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
    ## Manages the TeaScript **Stack** where in-scope variables are allocated.
    ##
    variables)
      case "$2" in

        ## ### `reflection variables exists`
        ##
        ## Returns 1 if variable with provided name does not exist else returns 0.
        ##
        ## > | | Parameter |
        ## > |-|-----------|
        ## > | `$1` | `variables` |
        ## > | `$2` | `getType` |
        ## > | `$3` | Variable name |
        ##
        exists)
          eval "[ -n \"\${T_VAR_$3+x}\" ]"
          return $?
          ;;

        ## ### `reflection variables getValueTypeCode`
        ##
        ## Get the type of this variable, e.g. object reference, literal value, or named reference.
        ##
        ## ℹ️ Note: this returns the code for the value type, e.g. `r` or `v` or `n`.  
        ##
        ## See [`getValueType`](#reflection-variables-getValueType) to get friendly name.
        ##
        ## > | | Parameter |
        ## > |-|-----------|
        ## > | `$1` | `variables` |
        ## > | `$2` | `getValueTypeCode` |
        ## > | `$3` | Variable name |
        ##
        getValueTypeCode)
          eval "printf '%s' \"\${T_VAR_$3[0]%;*}\""
          ;;

        ## ### `reflection variables getType`
        ##
        ## Get the type stored in the variable, e.g. `String` or `Integer`.
        ##
        ## For named references this value is blank.
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$1` | `variables` |
        ## | `$2` | `getType` |
        ## | `$3` | Variable name |
        ##
        getType)
          eval "printf '%s' \"\${T_VAR_$3[0]#*;}\""
          ;;

        ## ### `reflection variables getValue`
        ##
        ## Get the value stored in this variable, e.g. a literal text value or an Object ID
        ## for reference or a field index is the variable stores as `struct`.
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$1` | `variables` |
        ## | `$2` | `getValue` |
        ## | `$3` | Variable name |
        ##
        getValue)
          eval "printf '%s' \"\${T_VAR_$3[1]}\""
          ;;

        ## ### `reflection variables getValueType`
        ##
        ## Get the type of this variable, e.g. object reference, literal value, or named reference.
        ##
        ## Specifically returns one of these values: `nameref`, `byref`, or `byval`.
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$1` | `variables` |
        ## | `$2` | `getValueType` |
        ## | `$3` | Variable name |
        ##
        getValueType)
          local valueTypeCode
          eval "printf -v valueTypeCode '%s' \"\${T_VAR_$3[0]%;*}\""
          case "$valueTypeCode" in
            n) printf nameref ;;
            r) printf byref ;;
            v) printf byval ;;
            *) printf "$valueTypeCode" ;;
          esac
          ;;

        ## ### `reflection variables list`
        ##
        ## Returns a list of all defined variables including their type and value, one per line.
        ##
        ## - For `struct` types, the value will appear empty. Use [`variables show`](#reflection-variables-show) to view details.
        ## - For named reference variables, the type will be empty. Named references do not copy the type of their target (_target may change_).
        ##
        ## > 🚨 Expensive. Reminder: do not use this in the hot path. This is for users.
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `variables` |
        ##
        list)
          local variableName
          for variableName in $(( set -o posix ; set ) | grep "^T_VAR_" | sed 's/=.*//' | sed 's/^T_VAR_//' )
          do
            echo "$variableName\t$( reflection variables getValueType "$variableName" )\t$( reflection variables getType "$variableName" )\t$( reflection variables getValue "$variableName" )"
          done
          ;;

        ## ### `reflection variables set`
        ##
        ## Set / allocate a new variable.
        ##
        ## ```sh
        ## # Define a variable which stores the literal text value in the variable (no object heap allocation)
        ## reflection variables set myString v String "This is the literal value"
        ##
        ## # Define a variable which references an object on the heap by its ID
        ## reflection variables set myObject r Dog "<object ID referencing the Dog object>"
        ##
        ## # Define a special named reference which is an alias / pointer to another variable by its name
        ## reflection variables set myVariableAlias n "" myString
        ## ```
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$1` | `variables` |
        ## | `$2` | `set` |
        ## | `$3` | Variable name |
        ## | `$4` | Type of variable (object `r`eference, literal `v`alue, or `n`amed reference) |
        ## | `$5` | Variable type (e.g. String or Integer) |
        ## | `$6` | Variable value (object ID, literal text value, or name of another variable) |
        ##
        set)
          eval "T_VAR_$3=(\"$4;$5\" \"$6\")"
          ;;

        ## ### `reflection variables show`
        ##
        ## > 🚨 Expensive. Reminder: do not use this in the hot path. This is for users.
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `variables` |
        ## | `$3` | Variable name |
        ##
        show)
          if ! reflection variables exists "$3"
          then
            return 1
          else
            echo "Name: $3"
            echo "Value Type: $( reflection variables getValueType "$3" )"
            echo "Type: $( reflection variables getType "$3" )"
            echo "Value: $( reflection variables getValue "$3" )"
          fi
          ;;

        ## ### `reflection variables unset`
        ##
        ## Unset the given variable by name.
        ##
        ## Returns 1 if variable with provided name does not exist else returns 0.
        ##
        ## | | Parameter |
        ## |-|-----------|
        ## | `$2` | `variables` |
        ## | `$3` | Variable name |
        ##
        unset)
          unset "T_VAR_$3"
          ;;

        *)
          echo "Unknown 'reflection variables' command: $2"
          return 1
          ;;
      esac
      ;;

    *)
      echo "Unknown 'reflection' command: $1"
      return 1
      ;;
  esac
}