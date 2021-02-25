# Change T_DO into a stack. class do, class do for an inner class. p3.

# TODO split into multiple files and compile back into this file with the tree of case statements

# `T_ENV` not currently used.
# TODO. Note: rather than checking T_ENV in the code, we'll probably LOAD/source a *different* implementation of `reflection` when T_ENV=production (e.g. without comments and maybe no type checking assertions)
T_ENV=development

# Documented below in #reflection-objects-gc
T_GC_OBJECT_THRESHOLD=999
T_GC_OBJECT_THRESHOLD_COUNT=0

## ## `T_COMMENTS`
##
## When set to `enabled`, comments on defined types/fields/methods are stored in type declarations (`enabled` by default in development).
##
## This makes it easy to generate utilities to generate documentation as well as IDE server usage.
##
## > 💡 Hope to eventually make use of these comments in a TeaScript VSCode Language Server :)
##
## > ℹ️ Implementation Detail
## >
## > Comments are always stored in their own separate BASH variable index to isolate them and not impact the field/method/param
## > lookup time (like field/param default values). When `T_COMMENTS` is disabled, these indices are never allocated and the type objects are smaller sized.
##
T_COMMENTS=enabled

## # `reflection`
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
##   - [`reflection types fields`](#reflection-types-fields)
##   - [`reflection types methods`](#reflection-types-methods)
##     - [`reflection types methods params`](#reflection-types-methods-params)
## - [`reflection variables`](#reflection-variables)
##
## ```sh
## class Dog implements IAnimal do <<_
##   Represents a dog
## _
##
##   field name: String
##   field age: Integer
## end
##
## reflection types getInterface Dog
## # => "IAnimal"
##
## reflection types getComment Dog
## # => "Represents a dog"
##
## reflection types methods listNames Dog
## # => "name age"
##
## reflection types fields getType Dog age
## # => "Integer"
## ```
##
## > ℹ️ Note: `reflection` performs no argument assertions or validation  
## > e.g. you can create a variable of a type that does not exist using `reflection variables`.
## >
## > Higher-level functions such as `var` and `class` and `def` perform these assertions and type-checking.
##
## ### 🔍 `safeName`
##
## Whenever working with type names, you must convert your type name to a format compatible with `reflection` functions.
##
## This allows the core `reflection` code to remain efficient while also supporting type syntax such as generics, e.g. `MyMap[K,V]`
##
## ```sh
## reflection types listFieldNames $(reflection safeName MyCollection[T])
##
## # Alternatively, you can get the Reflection-safe name in a variable:
## local reflectionSafeTypeName
## reflection safeName MyCollection[T] reflectionSafeTypeName
##
## # Now call your reflection calls using the converted reflection-safe type variable:
## reflection types listFieldNames $reflectionSafeTypeName
## reflection types listMethodNames $reflectionSafeTypeName
## ```
##
## > ℹ️ Implementation Detail
## > 
## > This is only required for _generic type names_, e.g. `MyMap[K,V]`
## >
## > You can safely call `reflection` with direct type names when not providing generic names.
## >
## > For users, `safeName` is recommended so as to not create bugs when passing generic types.
##
## ### 📤 `out` BASH variables
##
## Every reflection `get[Something]` function supports providing one optional additional argument.
## 
## When emitted, the `get[Something]` funtion will print the return value to console, e.g. `getType` might print `Dog`
##
## When the additional argument is provided, the `get[Something]` function prints nothing and, instead, sets the value of the provided variable name to the return value.
##
## This allows for getting return values without executing subshells.
##
## Example:
##
## ```sh
## source teascript.sh
##
## var x = new Dog name: "Rover"
##
## reflection variables getType x
## # => prints "Dog"
##
## local variableType
## reflection variables getType x variableType
## # => prints nothing
##
## printf "$variableType"
## # => "Dog"
## ```
##
## Other functions such as `typeof` also follow this pattern
##
## ```sh
## var y = new Cat name: "Mittens"
##
## typeof y
## # => Cat
##
## local variableType
## typeof x variableType
## # => prints nothing
##
## printf "$variableType"
## # => "Cat"
## ```
##
## ### 💻 Developer Notes
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
## Try not to allocate new native BASH variables. Instead, reuse variables as much as possible (_and limit use of variables, in general - prefer literal strings_). All BASH locals should be prefixed `__T_`.
##
## Do not loop over values. Usually, if you are writing a loop, you are adding an `O(N)` or worse, do not do it.
## Notable exception for [`addMethod`]() which takes a dynamic number of arguments for defining any number of parameters.
## In general, keep everything `O(1)` as much as possible. User-friendly functions which are not on the hot path are allowed
## to break these rules.
##
## #### 👥 User Functions
##
## TeaScript is an interpreted language which runs on the BASH interpreter.
##
## This is going to be slow. There's no way around it. But we can do everything we can to keep all TeaScript operations as optimized as possible!
##
## > This means making every operation `O(1)` if possible, please avoid `O(N)` in every way possible!
##
## To make `reflection` more user-friendly, a number of functions are provided for use by end-users only.
##
## These functions are annotated with `👥 User Function` and should _never_ be called by TeaScript core code.
##
## #### ⌨️ Character Codes
##
## > e.g. `p` for private -_vs_- `P` for public
##
## This contains a lookup table for all characters.
##
## To convert programmatically:
##
## ```sh
## # Get code for a value
##
## reflection getCode class
## # => "c"
##
## local var
## reflection getCode class var
## # => ""
##
## printf "$var"
## # => "c"
##
## # Get value from a code
##
## reflection getCodeValue c
## # => "class"
##
## local var
## reflection getCodeValue c var
## # => ""
##
## printf "$var"
## # => "class"
## ```
##
## > Note: most of the read-only reflection functions such as `reflection types getFieldVisibility` return friendly names such as `public` or `private`.
## >
## > These functions are not used in any path of the core TeaScript engine and perform name conversions.
## >
## > Other functions such as `reflection types define` expect these characters to be provided as arguments and _do not support_ friendly names such as `public` (use `P` instead).
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
## #### 🐞 Error Overhead
##
## Please do not rely on errors, e.g. calling `getComment [type] [field]` when the type or field may not exist.
##
## Instead, check that type and field `exists` first.
##
## Note: every `reflection` function _does include the overhead of checking if the relevant type/field/method/param exists_.
##
## However, in error conditions when the type/field/method/param does not exist, we perform a `$(reflection types getName [type])` subshell to get the
## original name of the type or method for user friendliness. DO NOT RELY ON THIS IN HOT PATH CODE please :)
##
## > _Originally, we did not include the overhead of checking that types/fields/etc exist in each `reflection` method but it was not worth the sometimes hard to debug resulting bugs_
##
## #### TeaScript use of BASH arrays
##
## BASH 4.0 introduces associative arrays.
##
## Mac OS X uses a wicked old version of BASH: `3.2.57` (as mentioned above)
##
## TeaScript is built from the ground up to support `3.2.57` so that it works out-of-the-box on Mac OS X.
##
## However, even if TeaScript did make use of BASH associative arrays, they are still flat objects with a simple text value key/index and a simple text string value.
##
## BASH associative arrays wouldn't actually benefit the TeaScript implementation a whole lot.
##
## So we make the best use of BASH arrays by:
##
## - Storing various bits of metadata inside of single indices
## - Proving out own key --> index lookups
##
## See [`reflection objects`](#reflection-objects), [`types`](#reflection-types), and [`variables`](#reflection-variables) for descriptions of how we store each of these using BASH arrays.
##
## #### ⚠️ `eval`
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
reflection() {
  case "$1" in

    ## ## `reflection objects`
    ##
    ## Manages the TeaScript **Heap** where objects are allocated.
    ##
    ## Objects are `create`'d (_allocated_) and `dispose`'d of (_deallocated_).
    ##
    ## All created objects are provided a unique Object ID identifier for
    ## referencing the object, e.g. from a variable.
    ##
    ## You can think of objects as simple key/value stores.
    ##
    ## The object does *not* know the *types* of the keys/values, that information is stored on the type.
    ##
    ## Every object has:
    ## 
    ##   1. a unique object ID identifier (_see [Object IDs](#-Object-IDs) below for more info on how these are generated_)
    ##   2. a Type name, e.g. `String` or `Integer`
    ##   3. keys and values (these are stored as simple strings, each value in its own index of a single-dimensional BASH array)
    ##
    ## ### ➗ Object IDs
    ##
    ## Object IDs are generated via [`/dev/urandom`](https://en.wikipedia.org/wiki//dev/random).
    ##
    ## > _In Unix-like operating systems, /dev/random, /dev/urandom and /dev/arandom are special files that serve as pseudorandom number generators._  
    ## > ~ wikipedia
    ##
    ## The random portion of Object IDs is 32 characters long.
    ##
    ## The specific command TeaScript uses to generate object IDs is:
    ##
    ## ```sh
    ## cat /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
    ## ```
    ##
    ## ### 🗑️ Garbage Collection
    ##
    ## Unlike variables, which are managed on the stack within a given scope,
    ## objects are not automatically disposed of when a variable goes out of scope.
    ##
    ## To deallocate objects which are no longer being referenced,
    ## the garbage collector must be run which disposes of all objects
    ## which are no longer being references by: variables or other objects.
    ##
    ## You can run the garbage collector at any time via: `reflection objects gc run`
    ##
    ## To simply view objects which are no longer in use and would be reaped and disposed of
    ## by the garbage collector, you can run `reflection objects gc unused`
    ##
    ## ### 🎨 BASH Data Representation
    ##
    ## Objects are represented in BASH single-dimensional array structures (see [TeaScript use of BASH arrays](#TeaScript-use-of-BASH-arrays) above)
    ##
    ## TODO: details
    ##
    objects)
      case "$2" in

        ## ### `reflection objects create`
        ##
        ## Creates an object of a given type and allocates it on the heap.
        ##
        ## The object ID is provided to the caller by passing the name of a variable and this function
        ## will set the variable value to the object ID. This allows calling `reflection objects create`
        ## outside of a subshell.
        ##
        ## > ℹ️ At the time of writing, you cannot currently provide key/value fields to `reflection objects create`,
        ## > you must use `setField` for every individual field.
        ##
        ## #### 🗑️ Garbage Collection
        ##
        ## TeaScript automatically runs a garbage collector when a certain number of objects have been allocated.
        ##
        ## This can be configured by setting the `T_GC_OBJECT_THRESHOLD` variable to an integer value (default: `1000`).
        ##
        ## To disable automatic garbage collection, `unset T_GC_OBJECT_THRESHOLD`.
        ##
        ## Be sure to set or unset `T_GC_OBJECT_THRESHOLD` _after_ sourcing `teascript.sh`.
        ##
        ## You can run the garbage collector manually at any time by running: `reflection objects gc run`.
        ##
        ## See [`objects gc`](#reflection-objects-gc) for more details.
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `objects` |
        ## > > | `$2` | `create` |
        ## > > | `$3` | Type name, e.g. `String` or `Integer` |
        ## > > | `$4` | `out` variable name to persist the object ID |
        ##
        create)
          if [ -n "$T_GC_OBJECT_THRESHOLD" ]
          then
            : $(( T_GC_OBJECT_THRESHOLD_COUNT++ ))
            if [ $T_GC_OBJECT_THRESHOLD_COUNT -gt $T_GC_OBJECT_THRESHOLD ]
            then
              T_GC_OBJECT_THRESHOLD_COUNT=0
              reflection objects gc run
            fi
          fi
          local __T_objectId="$( cat /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 )"
          eval "printf -v \"$4\" "$__T_objectId""
          eval "T_OBJECT_$__T_objectId=(\"$3\" \"\")"
          ;;

        ## ### `reflection objects dispose`
        ##
        ## Deallocate the object.
        ##
        ## Note: this does no checking to see if the object leaves any orphans behind.
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `objects` |
        ## > > | `$2` | `dispose` |
        ## > > | `$3` | Object ID |
        ##
        dispose)
          unset "T_OBJECT_$3"
          ;;

        ## ### `reflection objects exists`
        ##
        ## Return 0 if an object with the provided ID exists / is currently allocated else returns 1.
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `objects` |
        ## > > | `$2` | `exists` |
        ## > > | `$3` | Object ID |
        ##
        exists)
          eval "[ -n \"\${T_OBJECT_$3+x}\" ]"
          ;;

        ## ### `reflection objects gc`
        ##
        ## Run the garbage collector (_reap all unused objects -or- simply list all unused object IDs_)
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `objects` |
        ## > > | `$2` | `gc` |
        ## > > | `$3` | `run` or `unused` |
        ##
        gc)
          case "$3" in
            run)
              local __T_objectId
              for __T_objectId in $(( set -o posix ; set ) | grep "^T_OBJECT_" | sed "s/^T_OBJECT_\([^=]*\)=.*/\1/")
              do
                # If a reference to the object ID shows up in any variables or objects, then it's used.
                # If it is not found in any variable or objects, then it's unused (print it).
                # Ignore the allocation of the T_OBJECT, itself, when calculating unused.
                #
                # TODO - should the result of 'set' be stored in memory in a variable OR 'set' run each time? It'll be LARGE in memory.
                #        benchmark this and look at memory size with a few thousand objects later on!
                if ! ( set -o posix ; set ) | grep "^T_OBJECT_\|^T_VAR_" | grep -v "T_OBJECT_$__T_objectId=" | grep "$__T_objectId" &> /dev/null
                then
                  unset "T_OBJECT_$__T_objectId"
                fi
              done
              ;;
            unused)
              local __T_objectId
              for __T_objectId in $(( set -o posix ; set ) | grep "^T_OBJECT_" | sed "s/^T_OBJECT_\([^=]*\)=.*/\1/")
              do
                # If a reference to the object ID shows up in any variables or objects, then it's used.
                # If it is not found in any variable or objects, then it's unused (print it).
                # Ignore the allocation of the T_OBJECT, itself, when calculating unused.
                if ! ( set -o posix ; set ) | grep "^T_OBJECT_\|^T_VAR_" | grep -v "T_OBJECT_$__T_objectId=" | grep "$__T_objectId" &> /dev/null
                then
                  echo "$__T_objectId"
                fi
              done
              ;;
          esac
          ;;

        ## ### `reflection objects getField`
        ##
        ## Get the value of the field in this given object.
        ##
        ## If the field does not exist, returns 1.
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `objects` |
        ## > > | `$2` | `getField` |
        ## > > | `$3` | Object ID |
        ## > > | `$4` | Field name |
        ##
        getField)
          local __T_tempVariable
          eval "__T_tempVariable=\"\${T_OBJECT_$3[1]}\""
          if [[ "$__T_tempVariable" = *";$4:"* ]]
          then
            __T_tempVariable="${__T_tempVariable#*;$4:}"
            __T_tempVariable="${__T_tempVariable%%;*}"
            eval "printf \"\${T_OBJECT_$3[$__T_tempVariable]}\""
          else
            return 1
          fi
          ;;

        ## ### `reflection objects list`
        ##
        ## > 👥 User Function
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `objects` |
        ## > > | `$2` | `list` |
        ##
        list)
          # TODO update to show the type and field names too (raw)
          ( set -o posix ; set ) | grep "^T_OBJECT_"
          ;;

        ## ### `reflection objects setField`
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `objects` |
        ## > > | `$2` | `setField` |
        ## > > | `$3` | Object ID |
        ## > > | `$4` | Field name |
        ## > > | `$5` | Field value |
        ##
        setField)
          local __T_tempVariable
          eval "__T_tempVariable=\"\${T_OBJECT_$3[1]}\""
          if [[ "$__T_tempVariable" = *";$4:"* ]]
          then          
            __T_tempVariable="${__T_tempVariable#*;$4:}"
            __T_tempVariable="${__T_tempVariable%%;*}"
            eval "T_OBJECT_$3[$__T_tempVariable]=\"$5\""
          else
            eval "T_OBJECT_$3[1]=\"$__T_tempVariable;$4:\${#T_OBJECT_$3[@]}\";"
            eval "T_OBJECT_$3+=(\"$5\")"
          fi
          ;;

        ## ### `reflection objects show`
        ##
        ## > 👥 User Function
        ##
        ## TODO - update to show pretty things :)
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `objects` |
        ## > > | `$2` | `show` |
        ## > > | `$3` | Object ID |
        ##
        show)
          declare -p "T_OBJECT_$3" | sed 's/^declare -a //'
          ;;
      esac
      ;;

    ## ## `reflection types`
    ##
    ## Manages the TeaScript types in the TeaScript type system.
    ##
    ## - [`reflection types define`](#reflection-types-define)
    ## - [`reflection types exists`](#reflection-types-exists)
    ## - [`reflection types fields *`](#reflection-types-fields)
    ## - [`reflection types getBaseClass`](#reflection-types-getBaseClass)
    ## - [`reflection types getComment`](#reflection-types-getComment)
    ## - [`reflection types getDescriptorCode`](#reflection-types-getDescriptorCode)
    ## - [`reflection types getDescriptor`](#reflection-types-getDescriptor)
    ## - [`reflection types getGenericTypes`](#reflection-types-getGenericTypes)
    ## - [`reflection types getInterfaces`](#reflection-types-getInterfaces)
    ## - [`reflection types methods *`](#reflection-types-methods)
    ## - [`reflection types undefine`](#reflection-types-undefine)
    ##
    ## Types are `define`'d and `undefine`'d.
    ##
    ## Types are used for describing the shape and behavior of objects and values.
    ##
    ## Every type has a "type", e.g. it is a `class` or a `struct` etc. We call these the 'descriptor' (_to reduce confusion, it's really the type type_).
    ##
    ## In addition to classes, value types such as literal primitives (`string`, `int`, et al)
    ## and `struct` are also described using TeaScript types.
    ##
    ## ### 🎨 BASH Data Representation
    ##
    ## Variables are represented in BASH single-dimensional array structures (see [TeaScript use of BASH arrays](#TeaScript-use-of-BASH-arrays) above)
    ##
    ## ```sh
    ## reflection types define Array [...]
    ## # => T_TYPE_Array
    ##
    ## reflection types define Array[T]
    ## # => T_TYPE_Array_GENERIC_T
    ##
    ## reflection types define Map[K,V]
    ## # => T_TYPE_Map_GENERIC_K_V
    ## ```
    ##
    ## > | `T_TYPE_` index | Description |
    ## > |-----------------|-------------|
    ## > | `0` | Descriptor name or code, e.g. `c` for `class`, `s` for `struct` et al (see [codes reference](#Character-Codes) above), followed b full type name, e.g. `Array` or `Array[T]`, followed by base class and interfaces, with comment if provided |
    ## > | `1` | Field lookup table, mapping field named to index value where field definition is stored |
    ## > | `2` | Method lookup table, mapping method name to index value where method definition is stored |
    ##
    ## ```sh
    ## T_TYPE_Array_GENERIC_T=([0]="Array[T];s|Object<IEnumerable,IComparable>This represents a typed array of a provided generic type.")
    ## ```
    ##
    types)
      case "$2" in

        ## ### `reflection types define`
        ##
        ## Define a new type, e.g. a `class` or a `struct`
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `types` |
        ## > > | `$2` | `define` |
        ## > > | `$3` | Full type name, including generics if any, e.g. `MyMap[K,V]`. All other reflection methods require a differently formatted type name for generic types. |
        ## > > | `$4` | Descriptor name or code, e.g. `c` for `class` or `s` for `struct`. For extensibility, this is stored/used raw if not a known built-in code, allowing definition of one's own descriptors. |
        ## > > | `$5` | Base class name (or empty string) |
        ## > > | `$6` | Interface names (comma-delimited without spaces) (or empty string) |
        ## > > | `$7` | Comment text, if any. Note: this is only persisted if `T_COMMENTS=enabled` (default value in development environment) |
        ##
        define)
          if [[ "$3" = *"["* ]]
          then
            local __T_tempVariable="T_TYPE_${3%%[*}_GENERIC_"
            local __T_genericTypeCount="${3//[^,]}"
            __T_tempVariable="$__T_tempVariable${#__T_genericTypeCount}"
          else
            local __T_tempVariable="T_TYPE_$3"
          fi
          if [ "$T_COMMENTS" = enabled ]
          then
            eval "$__T_tempVariable=(\"$3;$4|$5<$6>$7\" \"\" \"\")"
          else
            eval "$__T_tempVariable=(\"$3;$4|$5<$6>\" \"\" \"\")"
          fi
          ;;

        ## ### `reflection types exists`
        ##
        ## Return 0 if a type with the provided name exists else returns 1.
        ##
        ## Note: for generics, this should be the type name as it was originally defined.  
        ## e.g. if there is a defined `Collection[T]`, then `exists Collection[T]` will succeed
        ## but `exists Collection[K]` will fail.
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `types` |
        ## > > | `$2` | `exists` |
        ## > > | `$3` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
        ##
        exists)
          eval "[ -n \"\${T_TYPE_$3+x}\" ]"
          ;;

        ## ### `reflection types getBaseClass`
        ##
        ## Get the base or 'super' class of the provided type, if any.
        ##
        ## e.g. all `class` types inherit from `Object` by default
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `types` |
        ## > > | `$2` | `getBaseClass` |
        ## > > | `$3` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
        ## > > | `$4` | (Optional) name of BASH variable to set to the return value rather than printing return value |
        ##
        getBaseClass)
          local __T_tempVariable
          eval "__T_tempVariable=\"\${T_TYPE_$3[0]#*|}\""
          if [ $# -eq 3 ]
          then
            printf "${__T_tempVariable%%<*}"
          else
            printf -v "$4" "${__T_tempVariable%%<*}"
          fi
          ;;

        ## ### `reflection types getComment`
        ##
        ## Gets the comment text for the type, if any.
        ##
        ## Note: this is saved to reflection only if `T_COMMENTS=enabled` (default in development environment)
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `types` |
        ## > > | `$2` | `getBaseClass` |
        ## > > | `$3` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
        ## > > | `$4` | (Optional) name of BASH variable to set to the return value rather than printing return value |
        ##
        getComment)
          if [ $# -eq 3 ]
          then
            eval "printf \"\${T_TYPE_$3[0]#*>}\""
          else
            eval "printf -v \"$4\" \"\${T_TYPE_$3[0]#*>}\""
          fi
          ;;

        ## ### `reflection types getDescriptorCode`
        ##
        ## Get the short code of this type's "type" or "descriptor", e.g. `c` for `class` or `s` for `struct`
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `types` |
        ## > > | `$2` | `getDescriptorCode` |
        ## > > | `$3` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
        ## > > | `$4` | (Optional) name of BASH variable to set to the return value rather than printing return value |
        ##
        getDescriptorCode)
          local __T_tempVariable
          eval "__T_tempVariable=\"\${T_TYPE_$3[0]#*;}\""
          if [ $# -eq 3 ]
          then
            printf "${__T_tempVariable%%|*}"
          else
            printf -v "$4" "${__T_tempVariable%%|*}"
          fi
          ;;

        ## ### `reflection types getDescriptor`
        ##
        ## > 👥 User Function
        ##
        ## Get the full name of this type's "type" or "descriptor", e.g. `class` or `struct`
        ## 
        ## > Note: this is used by `typeof`. Please do not use `typeof` in core TeaScript code, it is for users.
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `types` |
        ## > > | `$2` | `getDescriptor` |
        ## > > | `$3` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
        ## > > | `$4` | (Optional) name of BASH variable to set to the return value rather than printing return value |
        ##
        getDescriptor)
          reflection types exists "$3" || return 1
          local __T_tempVariable
          eval "__T_tempVariable=\"\${T_TYPE_$3[0]#*;}\""
          if [ $# -eq 3 ]
          then
            reflection getCodeValue "${__T_tempVariable%%|*}"
          else
            printf -v "$4" "$( reflection getCodeValue "${__T_tempVariable%%|*}" )"
          fi
          ;;

        ## ### `reflection types getGenericParams`
        ##
        ## Get the names of the generic type parameters for a class, e.g. for `MyMap[K,V]` the generic type parameters are `K` and `V`
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `types` |
        ## > > | `$2` | `getGenericParams` |
        ## > > | `$3` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
        ## > > | `$4` | (Optional) name of BASH variable to set to the return value rather than printing return value |
        ##
        getGenericParams)
          local __T_tempVariable
          eval "__T_tempVariable=\"\${T_TYPE_$3[0]}\""
          __T_tempVariable="${__T_tempVariable%%;*}" # Get rid of everything but the type name
          [[ "$__T_tempVariable" = *"["* ]] || return 1 # If the type name doesn't contain '[' for generics, return 1 (no generic types)
          __T_tempVariable="${__T_tempVariable#*[}" # Get rid of everything but the generic definition
          __T_tempVariable="${__T_tempVariable%]}" # Get rid of the trailing ']'
          if [ $# -eq 3 ]
          then
            printf "${__T_tempVariable//,/ }" # Replace all , with " " to return a value such as "K V" for MyMap[K,V]
          else
            printf -v "$4" "${__T_tempVariable//,/ }" # Replace all , with " " to return a value such as "K V" for MyMap[K,V]
          fi
          ;;

        ## ### `reflection types getInterfaces`
        ##
        ## Return a space-delimited list of all the interfaces this type implements.
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `types` |
        ## > > | `$2` | `getInterfaces` |
        ## > > | `$3` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
        ## > > | `$4` | (Optional) name of BASH variable to set to the return value rather than printing return value |
        ##
        getInterfaces)
          local __T_tempVariable
          eval "__T_tempVariable=\"\${T_TYPE_$3[0]#*<}\""
          __T_tempVariable="${__T_tempVariable%%>*}"
          if [ $# -eq 3 ]
          then
            printf "${__T_tempVariable/,/ }"
          else
            printf -v "$4" "${__T_tempVariable/,/ }"
          fi
          ;;

        ## ### `reflection types getTypeName`
        ##
        ## Given the Reflection-safe name, return the original full type name including generic type parameters.
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `types` |
        ## > > | `$2` | `getTypeName` |
        ## > > | `$3` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
        ## > > | `$4` | (Optional) name of BASH variable to set to the return value rather than printing return value |
        ##
        getTypeName)
          if [ $# -eq 3 ]
          then
            eval "printf \"\${T_TYPE_$3[0]%%;*}\""
          else
            eval "printf -v \"$\4\" \"\${T_TYPE_$3[0]%%;*}\""
          fi
          ;;

        ## ### `reflection types undefine`
        ##
        ## Undefine type with provided name.
        ##
        ## Note: like all other `reflection` functions (_excluding [types define](#reflection-types-define)_), this required a `safeName` converted type name.
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `types` |
        ## > > | `$2` | `undefine` |
        ## > > | `$3` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
        ##
        undefine)
          unset "T_TYPE_$3"
          ;;

        ## ## `reflection types fields`
        ##
        ## `TODO` talk about fields!
        ##
        ## - [`reflection types fields define`](#reflection-types-fields-define)
        ## - [`reflection types fields exists`](#reflection-types-fields-exists)
        ## - [`reflection types fields getComment`](#reflection-types-fields-getComment)
        ## - [`reflection types fields getDefaultValue`](#reflection-types-fields-getDefaultValue)
        ## - [`reflection types fields getScope`](#reflection-types-fields-getScope)
        ## - [`reflection types fields getScopeCode`](#reflection-types-fields-getScopeCode)
        ## - [`reflection types fields getType`](#reflection-types-fields-getType)
        ## - [`reflection types fields getVisibility`](#reflection-types-fields-getVisibility)
        ## - [`reflection types fields getVisibilityCode`](#reflection-types-fields-getVisibilityCode)
        ## - [`reflection types fields list`](#reflection-types-fields-list)
        ## - [`reflection types fields listNames`](#reflection-types-fields-listNames)
        ## - [`reflection types fields undefine`](#reflection-types-fields-undefine)
        ##
        fields)
          case "$3" in

            ## ### `reflection types fields define`
            ##
            ## Define a field on this type.
            ##
            ## Fields must be of a certain type.
            ##
            ## Fields can have optional default values.
            ##
            ## `TODO` add code example
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `fields` |
            ## > > | `$3` | `define` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Field name, e.g. `name` |
            ## > > | `$6` | Full type name for this field, including generics if any, e.g. `MyMap[K,V]`. All other reflection methods require a differently formatted type name for generic types. |
            ## > > | `$7` | Scope code, e.g. `s` for `static` or `i` for `instance` |
            ## > > | `$8` | Visibility code, e.g. `p` for `private` or `P` for `public` |
            ## > > | `$9` | Default value, e.g. `"Hello, world!"` |
            ## > > | `$10` | Comment text, if any. Note: this is only persisted if `T_COMMENTS=enabled` (default value in development environment) |
            ##
            define)
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[1]}\""
              eval "T_TYPE_$4[1]=\"\${T_TYPE_$4[1]};$5:\${#T_TYPE_$4[@]}\""
              if [ "$T_COMMENTS" = enabled ]
              then
                eval "T_TYPE_$4+=(\"$7!$8|$5<$6>$9&${10}\")"
              else
                eval "T_TYPE_$4+=(\"$7!$8|$5<$6>$9&\")"
              fi
              ;;

            ## ### `reflection types fields exists`
            ##
            ## Returns 0 if field with provided name exists on this type else returns 1.
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `fields` |
            ## > > | `$3` | `exists` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Field name |
            ##
            exists)
              eval "[[ \"\${T_TYPE_$4[1]}\" = *\";$5:\"* ]]"
              ;;

            ## ### `reflection types fields getComment`
            ##
            ## Returns the field comment, if any.
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `fields` |
            ## > > | `$3` | `getComment` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Field name |
            ## > > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |
            ##
            getComment)
              eval "[ -n \"\${T_TYPE_$4+x}\" ]" || { echo "Type '$4' not found" >&2; return 1; }
              eval "[[ \"\${T_TYPE_$4[1]}\" = *\";$5:\"* ]]" || { echo "Field '$5' not found on type $(reflection types getTypeName "$4")" >&2; return 1; }
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[1]}\""
              __T_tempVariable="${__T_tempVariable#*;$5:}" # Get rid of the left side, leaving just the field index (possibly followed by a ;)
              __T_tempVariable="${__T_tempVariable%%;*}" # This gets the array index of the field definition
              if [ $# -eq 5 ]
              then
                eval "printf \"\${T_TYPE_$4[$__T_tempVariable]#*&}\"" # This gets the field definition + removes everything to the left of the comment
              else
                eval "printf -v \"$6\" \"\${T_TYPE_$4[$__T_tempVariable]#*&}\"" # This gets the field definition + removes everything to the left of the comment
              fi
              ;;

            ## ### `reflection types fields getDefaultValue`
            ##
            ## Returns the default value for this field, if any.
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `fields` |
            ## > > | `$3` | `getDefaultValue` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Field name |
            ## > > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |
            ##
            getDefaultValue)
              eval "[ -n \"\${T_TYPE_$4+x}\" ]" || { echo "Type '$4' not found" >&2; return 1; }
              eval "[[ \"\${T_TYPE_$4[1]}\" = *\";$5:\"* ]]" || { echo "Field '$5' not found on type $(reflection types getTypeName "$4")" >&2; return 1; }
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[1]}\""
              __T_tempVariable="${__T_tempVariable#*;$5:}" # Get rid of the left side, leaving just the field index (possibly followed by a ;)
              __T_tempVariable="${__T_tempVariable%%;*}" # This gets the array index of the field definition
              eval "__T_tempVariable=\"\${T_TYPE_$4[$__T_tempVariable]#*>}\"" # This gets the field definition + removes everything to the left of the default value
              if [ $# -eq 5 ]
              then
                printf "${__T_tempVariable%%&*}"
              else
                printf -v "$6" "${__T_tempVariable%%&*}"
              fi
              ;;

            ## ### `reflection types fields getScope`
            ##
            ## > 👥 User Function
            ##
            ## Returns this this field's scope, e.g. `static` or `instance`
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `fields` |
            ## > > | `$3` | `getScope` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Field name |
            ## > > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |
            ##
            getScope)
              eval "[ -n \"\${T_TYPE_$4+x}\" ]" || { echo "Type '$4' not found" >&2; return 1; }
              eval "[[ \"\${T_TYPE_$4[1]}\" = *\";$5:\"* ]]" || { echo "Field '$5' not found on type $(reflection types getTypeName "$4")" >&2; return 1; }
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[1]}\""
              __T_tempVariable="${__T_tempVariable#*;$5:}" # Get rid of the left side, leaving just the field index (possibly followed by a ;)
              __T_tempVariable="${__T_tempVariable%%;*}" # This gets the array index of the field definition
              eval "__T_tempVariable=\"\${T_TYPE_$4[$__T_tempVariable]%%!*}\"" # This gets the field definition + removes everything to the right of the scope code
              if [ $# -eq 5 ]
              then
                reflection getCodeValue "${__T_tempVariable}"
              else
                printf -v "$6" "$(reflection getCodeValue "${__T_tempVariable}")"
              fi
              ;;

            ## ### `reflection types fields getScopeCode`
            ##
            ## Returns the short code for this field's scope, e.g. `S` for `static` and `i` for instance
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `fields` |
            ## > > | `$3` | `getScopeCode` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Field name |
            ## > > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |
            ##
            getScopeCode)
              eval "[ -n \"\${T_TYPE_$4+x}\" ]" || { echo "Type '$4' not found" >&2; return 1; }
              eval "[[ \"\${T_TYPE_$4[1]}\" = *\";$5:\"* ]]" || { echo "Field '$5' not found on type $(reflection types getTypeName "$4")" >&2; return 1; }
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[1]}\""
              __T_tempVariable="${__T_tempVariable#*;$5:}" # Get rid of the left side, leaving just the field index (possibly followed by a ;)
              __T_tempVariable="${__T_tempVariable%%;*}" # This gets the array index of the field definition
              if [ $# -eq 5 ]
              then
                eval "printf \"\${T_TYPE_$4[$__T_tempVariable]%%!*}\"" # This gets the field definition + removes everything to the right of the scope code
              else
                eval "printf -v \"$6\" \"\${T_TYPE_$4[$__T_tempVariable]%%!*}\"" # This gets the field definition + removes everything to the right of the scope code
              fi
              ;;

            ## ### `reflection types fields getType`
            ##
            ## Returns the full type name of this field.
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `fields` |
            ## > > | `$3` | `getType` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Field name |
            ## > > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |
            ##
            getType)
              eval "[ -n \"\${T_TYPE_$4+x}\" ]" || { echo "Type '$4' not found" >&2; return 1; }
              eval "[[ \"\${T_TYPE_$4[1]}\" = *\";$5:\"* ]]" || { echo "Field '$5' not found on type $(reflection types getTypeName "$4")" >&2; return 1; }
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[1]}\""
              __T_tempVariable="${__T_tempVariable#*;$5:}" # Get rid of the left side, leaving just the field index (possibly followed by a ;)
              __T_tempVariable="${__T_tempVariable%%;*}" # This gets the array index of the field definition
              eval "__T_tempVariable=\"\${T_TYPE_$4[$__T_tempVariable]#*<}\"" # This gets the field definition + removes everything to the left of the type name
              if [ $# -eq 5 ]
              then
                printf "${__T_tempVariable%%>*}"
              else
                printf -v "$6" "${__T_tempVariable%%>*}"
              fi
              ;;

            ## ### `reflection types fields getVisibility`
            ##
            ## > 👥 User Function
            ##
            ## Get this fields's visibility, e.g. `public` or `private`
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `fields` |
            ## > > | `$3` | `getVisibility` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Field name |
            ## > > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |
            ##
            getVisibility)
              eval "[ -n \"\${T_TYPE_$4+x}\" ]" || { echo "Type '$4' not found" >&2; return 1; }
              eval "[[ \"\${T_TYPE_$4[1]}\" = *\";$5:\"* ]]" || { echo "Field '$5' not found on type $(reflection types getTypeName "$4")" >&2; return 1; }
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[1]}\""
              __T_tempVariable="${__T_tempVariable#*;$5:}" # Get rid of the left side, leaving just the field index (possibly followed by a ;)
              __T_tempVariable="${__T_tempVariable%%;*}" # This gets the array index of the field definition
              eval "__T_tempVariable=\"\${T_TYPE_$4[$__T_tempVariable]#*!}\"" # This gets the field definition + removes everything to the left of the visibility code
              if [ $# -eq 5 ]
              then
                reflection getCodeValue "${__T_tempVariable%%|*}"
              else
                printf -v "$6" "$(reflection getCodeValue "${__T_tempVariable%%|*}")"
              fi
              ;;

            ## ### `reflection types fields getVisibilityCode`
            ##
            ## Returns the short code for this field's visibility, e.g. `P` for `public` and `p` for `private`
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `fields` |
            ## > > | `$3` | `getVisibilityCode` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Field name |
            ## > > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |
            ##
            getVisibilityCode)
              eval "[ -n \"\${T_TYPE_$4+x}\" ]" || { echo "Type '$4' not found" >&2; return 1; }
              eval "[[ \"\${T_TYPE_$4[1]}\" = *\";$5:\"* ]]" || { echo "Field '$5' not found on type $(reflection types getTypeName "$4")" >&2; return 1; }
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[1]}\""
              __T_tempVariable="${__T_tempVariable#*;$5:}" # Get rid of the left side, leaving just the field index (possibly followed by a ;)
              __T_tempVariable="${__T_tempVariable%%;*}" # This gets the array index of the field definition
              eval "__T_tempVariable=\"\${T_TYPE_$4[$__T_tempVariable]#*!}\"" # This gets the field definition + removes everything to the left of the visibility code
              if [ $# -eq 5 ]
              then
                printf "${__T_tempVariable%%|*}"
              else
                printf -v "$6" "${__T_tempVariable%%|*}"
              fi
              ;;

            ## ### `reflection types fields list`
            ##
            ## > 👥 User Function
            ##
            ## Print a list of each of this type's fields with details including the scope, visibility, default value, and comment.
            ##
            ## Prints one field per line
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `fields` |
            ## > > | `$3` | `list` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ##
            list)
              local __T_fieldName
              for __T_fieldName in $(reflection types fields listNames $4)
              do
                echo "$(reflection types fields getVisibility $4 $__T_fieldName)\t$(reflection types fields getScope $4 $__T_fieldName)\t$(reflection types fields getType $4 $__T_fieldName)\t$__T_fieldName\t$(reflection types fields getDefaultValue $4 $__T_fieldName)\t$(reflection types fields getComment $4 $__T_fieldName)"
              done
              ;;

            ## ### `reflection types fields listNames`
            ##
            ## Returns a space-delimited list of field names for this type
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `fields` |
            ## > > | `$3` | `listNames` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | (Optional) name of BASH variable to set to the return value rather than printing return value |
            ##
            listNames)
              eval "[ -n \"\${T_TYPE_$4+x}\" ]" || { echo "Type '$4' not found" >&2; return 1; }
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[1]}\""
              if shopt -q extglob
              then
                __T_tempVariable="${__T_tempVariable//:+([0-9])}"
              else
                shopt -s extglob
                __T_tempVariable="${__T_tempVariable//:+([0-9])}"
                shopt -u extglob
              fi
              __T_tempVariable="${__T_tempVariable//;/ }"
              if [ $# -eq 4 ]
              then
                printf "${__T_tempVariable# }"
              else
                printf -v "$5" "${__T_tempVariable# }"
              fi
              ;;

            ## ### `reflection types fields undefine`
            ##
            ## Remove the given field from the type definition.
            ##
            ## > ℹ️ Implementation Detail
            ## >
            ## > The underlying BASH variable which stores this type definition will keep
            ## > an empty array index value where this field definition previously was,
            ## > so this does not reduce the size of the type definition BASH variable.
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `fields` |
            ## > > | `$3` | `undefine` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Field name |
            ##
            undefine)
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[1]}\""
              __T_tempVariable="${__T_tempVariable#*;$5:}" # Get rid of the left side, leaving just the field index (possibly followed by a ;)
              __T_tempVariable="${__T_tempVariable%%;*}" # This gets the array index of the field definition
              eval "T_TYPE_$4[$__T_tempVariable]=\"\"" # Clear the field definition (leaving the array index, `undefine` does not rearrange the array)
              if shopt -q extglob
              then
                eval "T_TYPE_$4[1]=\"\${T_TYPE_$4[1]/;$5:+([0-9])}\"" # Remove the field name from the field index lookup
              else
                shopt -s extglob
                eval "T_TYPE_$4[1]=\"\${T_TYPE_$4[1]/;$5:+([0-9])}\"" # Remove the field name from the field index lookup
                shopt -u extglob
              fi
              ;;

            *)
              echo "Unknown 'reflection types fields' command: $3"
              ;;
          esac
          ;;

        ## ## `reflection types methods`
        ##
        ## `TODO` talk about methods!
        ##
        ## - [`reflection types methods define`](#reflection-types-methods-define)
        ## - [`reflection types methods exists`](#reflection-types-methods-exists)
        ## - [`reflection types methods getComment`](#reflection-types-methods-getComment)
        ## - [`reflection types methods getMethodName`](#reflection-types-methods-getMethodName)
        ## - [`reflection types methods getReturnType`](#reflection-types-methods-getReturnType)
        ## - [`reflection types methods getScope`](#reflection-types-methods-getScope)
        ## - [`reflection types methods getScopeCode`](#reflection-types-methods-getScopeCode)
        ## - [`reflection types methods getVisibility`](#reflection-types-methods-getVisibility)
        ## - [`reflection types methods getVisibilityCode`](#reflection-types-methods-getVisibilityCode)
        ## - [`reflection types methods params *`](#reflection-types-methods-params)
        ## - [`reflection types methods undefine`](#reflection-types-methods-undefine)
        ##
        ## > ℹ️ Implementation Detail
        ##
        ## Method definitions are encoded into a single BASH index with the method comment, parameter comments, and parameter default values all stored in separate indices.
        ##
        ## Unique characters (which are invalid in method and parameter names) are used as separators to improve lookup performance.
        ##
        ## Encoding:
        ##
        ## | | Description |
        ## |-|-------------|
        ## | | Method name, including any generics, e.g. `add[T]` |
        ## | `^` | |
        ## | | Scope code, e.g. `S` for `static` or `i` for instance |
        ## | <code>&#124;</code> | |
        ## | | Visibility code, e.g. `P` for `public` or `p` for `private` |
        ## | `<` | |
        ## | | Reflection-safe name for method return value type (use [`safeName`](#reflection-safeName) to acquire)<br><br>_Note: this is defined using [`returns`](#returns) after the initial [`def`](#def) has been defined_ |
        ## | `>` | |
        ## | | Name of function to call when invoking this method |
        ## | `#` | |
        ## | | Index to access this method's comment, if present |
        ## | `&` | _This begins a parameter definition, every parameter definition starts with `&` - this section can be repeated_ <br><br> _Note: these are defined using [`param`](#param) after the initial [`def`](#def) has been defined_ |
        ## | | Method parameter name |
        ## | `:` | |
        ## | | Reflection-safe name for paramter type (use [`safeName`](#reflection-safeName) to acquire) |
        ## | `;` | |
        ## | | Parameter modifier, e.g. `o` for an `out` parameter or `r` for a `ref` parameter or `v` for `val` |
        ## | `+` | |
        ## | |  Index to access this parameter's default value, if any |
        ## | `~` | |
        ## | | Index to access this paramter's comment, if any |
        ## | `&` | |
        ## | | ... _any number of additional parameters may be defined._ |
        ##
        ## See `types methods params define` for adding new parameters to an existing method.
        ##
        ## The `types methods define` function has been updated to no longer supporting adding parameters as part of the `methods define` call.
        ##
        methods)
          case "$3" in

            ## ### `reflection types methods define`
            ##
            ## `TODO` add code example
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `methods` |
            ## > > | `$3` | `define` |
            ## > > | `$4` | Reflection-safe name to add method to (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Method name, e.g. `name` or `add[T]` for a generic method |
            ## > > | `$6` | Scope code, e.g. `S` for `static` or `i` for `instance` |
            ## > > | `$7` | Visibility code, e.g. `p` for `private` or `P` for `public` |
            ## > > | `$8` | Name of function to invoke when invoking this method |
            ## > > | `$9` | Comment text, if any. Note: this is only persisted if `T_COMMENTS=enabled` (default value in development environment) |
            define)
              # Calculate a safe the method name (which may include generics)
              if [[ "$5" = *"["* ]]
              then
                local __T_methodName="${5%%[*}_GENERIC_"
                local __T_genericTypeCount="${5//[^,]}"
                __T_methodName="$__T_methodName${#__T_genericTypeCount}"
              else
                local __T_methodName="$5"
              fi
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[2]}\"" # Get the method lookup list
              local __T_methodDefinition="$5^$6|$7<>$8"
              local __T_typeName="$4"
              local __T_comment="${10}"
              if [ "$T_COMMENTS" = enabled ]
              then
                :
                # TODO
              fi
              eval "T_TYPE_$__T_typeName[2]=\"\${T_TYPE_$__T_typeName[2]};\$__T_methodName:\${#T_TYPE_$__T_typeName[@]}\""
              eval "T_TYPE_$__T_typeName+=(\"\$__T_methodDefinition\")"
              ;;

            ## ### `reflection types methods exists`
            ##
            ## Returns 0 if method with provided name exists on this type else returns 1.
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `methods` |
            ## > > | `$3` | `exists` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Reflection-safe method name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions.  |
            ##
            exists)
              eval "[[ \"\${T_TYPE_$4[2]}\" = *\";$5:\"* ]]"
              ;;

            ## ### `reflection types methods getComment`
            ##
            ## Returns the method comment, if any.
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `methods` |
            ## > > | `$3` | `getComment` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Reflection-safe method name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |
            ##
            getComment)
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[2]}\""
              __T_tempVariable="${__T_tempVariable#*;$5:}" # Get rid of the left side, leaving just the method index (possibly followed by a ;)
              __T_tempVariable="${__T_tempVariable%%;*}" # This gets the array index of the method definition
              if [ $# -eq 5 ]
              then
                eval "printf \"\${T_TYPE_$4[$__T_tempVariable]#*!}\"" # This gets the method definition + removes everything to the left of the method comment
              else
                eval "printf -v \"$6\" \"\${T_TYPE_$4[$__T_tempVariable]#*!}\"" # This gets the method definition + removes everything to the left of the method comment
              fi
              ;;

            ## ### `reflection types methods getFunctionName`
            ##
            ## Get the name of the BASH function to invoke when invoking this method
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `methods` |
            ## > > | `$3` | `getFunctionName` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Reflection-safe method name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |
            ##
            getFunctionName)
              eval "[ -n \"\${T_TYPE_$4+x}\" ]" || { echo "Type '$4' not found" >&2; return 1; }
              eval "[[ \"\${T_TYPE_$4[2]}\" = *\";$5:\"* ]]" || { echo "Method '$5' not found on type $(reflection types getTypeName "$4")" >&2; return 1; }
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[2]}\""
              __T_tempVariable="${__T_tempVariable#*;$5:}" # Get rid of the left side, leaving just the method index (possibly followed by a ;)
              __T_tempVariable="${__T_tempVariable%%;*}" # This gets the array index of the method definition
              eval "__T_tempVariable=\"\${T_TYPE_$4[$__T_tempVariable]#*>}\"" # This gets the method definition + removes everything to the left of the function name
              __T_tempVariable="${__T_tempVariable%%&*}" # Get rid of everything to the right of the function name (if parameters)
              if [ $# -eq 5 ]
              then
                printf "${__T_tempVariable%%&*}" # Get rid of everything to the right of the function name (param definitions, if any)
              else
                printf -v "$6" "${__T_tempVariable%%&*}" # Get rid of everything to the right of the function name (param definitions, if any)
              fi
              ;;

            ## ### `reflection types methods getGenericParams`
            ##
            ## Get the names of the generic type parameters for this method, e.g. for `add[T,K]` the generic type parameters are `T` and `K`
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `methods` |
            ## > > | `$3` | `getGenericParams` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Reflection-safe method name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |
            ##
            getGenericParams)
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[2]}\""
              __T_tempVariable="${__T_tempVariable#*;$5:}" # Get rid of the left side, leaving just the method index (possibly followed by a ;)
              __T_tempVariable="${__T_tempVariable%%;*}" # This gets the array index of the method definition
              eval "__T_tempVariable=\"\${T_TYPE_$4[$__T_tempVariable]%%^*}\"" # This gets the method definition + removes everything to the right of the original method name
              __T_tempVariable="${__T_tempVariable##*[}"
              __T_tempVariable="${__T_tempVariable%]}"
              if [ $# -eq 5 ]
              then
                printf "${__T_tempVariable//,/ }"
              else
                printf -v "$6" "${__T_tempVariable//,/ }"
              fi
              ;;

            ## ### `reflection types methods getMethodName`
            ##
            ## Given the reflection-safe method name, return the original full method name including generic type parameters.
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `methods` |
            ## > > | `$3` | `getMethodName` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Reflection-safe method name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |
            ##
            getMethodName)
              eval "[ -n \"\${T_TYPE_$4+x}\" ]" || { echo "Type '$4' not found" >&2; return 1; }
              eval "[[ \"\${T_TYPE_$4[2]}\" = *\";$5:\"* ]]" || { echo "Method '$5' not found on type $(reflection types getTypeName "$4")" >&2; return 1; }
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[2]}\""
              __T_tempVariable="${__T_tempVariable#*;$5:}" # Get rid of the left side, leaving just the method index (possibly followed by a ;)
              __T_tempVariable="${__T_tempVariable%%;*}" # This gets the array index of the method definition
              if [ $# -eq 5 ]
              then
                eval "printf \"\${T_TYPE_$4[$__T_tempVariable]%%^*}\"" # This gets the method definition + removes everything to the right of the original method name
              else
                eval "printf -v \"$6\" \"\${T_TYPE_$4[$__T_tempVariable]%%^*}\"" # This gets the method definition + removes everything to the right of the original method name
              fi
              ;;

            ## ### `reflection types methods getReturnType`
            ##
            ## Returns the return type for this method.
            ##
            ## Must return a value. May return the `void` type.
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `methods` |
            ## > > | `$3` | `getReturnType` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Reflection-safe method name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |
            ##
            getReturnType)
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[2]}\""
              __T_tempVariable="${__T_tempVariable#*;$5:}" # Get rid of the left side, leaving just the method index (possibly followed by a ;)
              __T_tempVariable="${__T_tempVariable%%;*}" # This gets the array index of the method definition
              eval "__T_tempVariable=\"\${T_TYPE_$4[$__T_tempVariable]#*<}\"" # This gets the method definition + removes everything to left of the return type
              if [ $# -eq 5 ]
              then
                printf "${__T_tempVariable%%>*}" # Get rid of everything to the right of the return type
              else
                printf -v "$6" "${__T_tempVariable%%>*}" # Get rid of everything to the right of the return type
              fi
              ;;

            ## ### `reflection types methods getScope`
            ##
            ## > 👥 User Function
            ##
            ## Returns this this method's scope, e.g. `static` or `instance`
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `methods` |
            ## > > | `$3` | `getScope` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Reflection-safe method name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |
            ##
            getScope)
              eval "[ -n \"\${T_TYPE_$4+x}\" ]" || { echo "Type '$4' not found" >&2; return 1; }
              eval "[[ \"\${T_TYPE_$4[2]}\" = *\";$5:\"* ]]" || { echo "Method '$5' not found on type $(reflection types getTypeName "$4")" >&2; return 1; }
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[2]}\""
              __T_tempVariable="${__T_tempVariable#*;$5:}" # Get rid of the left side, leaving just the method index (possibly followed by a ;)
              __T_tempVariable="${__T_tempVariable%%;*}" # This gets the array index of the method definition
              eval "__T_tempVariable=\"\${T_TYPE_$4[$__T_tempVariable]#*^}\"" # This gets the method definition + removes everything to left of the scope code
              if [ $# -eq 5 ]
              then
                printf "$( reflection getCodeValue "${__T_tempVariable%%|*}" )"
              else
                printf -v "$6" "$( reflection getCodeValue "${__T_tempVariable%%|*}" )"
              fi
              ;;

            ## ### `reflection types methods getScopeCode`
            ##
            ## Returns the short code for this method's scope, e.g. `S` for `static` and `i` for instance
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `methods` |
            ## > > | `$3` | `getScopeCode` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Reflection-safe method name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |
            ##
            getScopeCode)
              eval "[ -n \"\${T_TYPE_$4+x}\" ]" || { echo "Type '$4' not found" >&2; return 1; }
              eval "[[ \"\${T_TYPE_$4[2]}\" = *\";$5:\"* ]]" || { echo "Method '$5' not found on type $(reflection types getTypeName "$4")" >&2; return 1; }
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[2]}\""
              __T_tempVariable="${__T_tempVariable#*;$5:}" # Get rid of the left side, leaving just the method index (possibly followed by a ;)
              __T_tempVariable="${__T_tempVariable%%;*}" # This gets the array index of the method definition
              eval "__T_tempVariable=\"\${T_TYPE_$4[$__T_tempVariable]#*^}\"" # This gets the method definition + removes everything to left of the scope code
              if [ $# -eq 5 ]
              then
                printf "${__T_tempVariable%%|*}" # Get rid of everything to the right of the scope code
              else
                printf -v "$6" "${__T_tempVariable%%|*}" # Get rid of everything to the right of the scope code
              fi
              ;;

            ## ### `reflection types methods getVisibility`
            ##
            ## > 👥 User Function
            ##
            ## Get this method's visibility, e.g. `public` or `private`
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `methods` |
            ## > > | `$3` | `getVisibility` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Reflection-safe method name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |
            ##
            getVisibility)
              eval "[ -n \"\${T_TYPE_$4+x}\" ]" || { echo "Type '$4' not found" >&2; return 1; }
              eval "[[ \"\${T_TYPE_$4[2]}\" = *\";$5:\"* ]]" || { echo "Method '$5' not found on type $(reflection types getTypeName "$4")" >&2; return 1; }
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[2]}\""
              __T_tempVariable="${__T_tempVariable#*;$5:}" # Get rid of the left side, leaving just the method index (possibly followed by a ;)
              __T_tempVariable="${__T_tempVariable%%;*}" # This gets the array index of the method definition
              eval "__T_tempVariable=\"\${T_TYPE_$4[$__T_tempVariable]#*|}\"" # This gets the method definition + removes everything to left of the visibility code
              if [ $# -eq 5 ]
              then
                printf "$( reflection getCodeValue "${__T_tempVariable%%<*}" )"
              else
                printf -v "$6" "$( reflection getCodeValue "${__T_tempVariable%%<*}" )"
              fi
              ;;

            ## ### `reflection types methods getVisibilityCode`
            ##
            ## Returns the short code for this method's visibility, e.g. `P` for `public` and `p` for `private`
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `methods` |
            ## > > | `$3` | `getVisibilityCode` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Reflection-safe method name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |
            ##
            getVisibilityCode)
              eval "[ -n \"\${T_TYPE_$4+x}\" ]" || { echo "Type '$4' not found" >&2; return 1; }
              eval "[[ \"\${T_TYPE_$4[2]}\" = *\";$5:\"* ]]" || { echo "Method '$5' not found on type $(reflection types getTypeName "$4")" >&2; return 1; }
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[2]}\""
              __T_tempVariable="${__T_tempVariable#*;$5:}" # Get rid of the left side, leaving just the method index (possibly followed by a ;)
              __T_tempVariable="${__T_tempVariable%%;*}" # This gets the array index of the method definition
              eval "__T_tempVariable=\"\${T_TYPE_$4[$__T_tempVariable]#*|}\"" # This gets the method definition + removes everything to left of the visibility code
              if [ $# -eq 5 ]
              then
                printf "${__T_tempVariable%%<*}" # Get rid of everything to the right of the visibility code
              else
                printf -v "$6" "${__T_tempVariable%%<*}" # Get rid of everything to the right of the visibility code
              fi
              ;;

            ## ### `reflection types methods list`
            ##
            ## > 👥 User Function
            ##
            ## Print a list of each of this type's methods with details including the scope, visibility, default value, and comment.
            ##
            ## Prints one method per line
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `methods` |
            ## > > | `$3` | `list` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ##
            list)
              local __T_methodName
              for __T_methodName in $(reflection types methods listSafeNames $4)
              do
                echo "$(reflection types methods getVisibility $4 $__T_methodName)\t$(reflection types methods getScope $4 $__T_methodName)\t$(reflection types methods getReturnType $4 $__T_methodName)\t$__T_methodName\t$(reflection types methods getMethodName $4 $__T_methodName)\t$(reflection types methods getComment $4 $__T_methodName)"
              done
              ;;

            ## ### `reflection types methods listNames`
            ##
            ## > 👥 User Function
            ##
            ## Returns a space-delimited list of method names for this type.
            ##
            ## > `O(N)` looks up every method's definition to get the original method name (to account for generics)
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `methods` |
            ## > > | `$3` | `listNames` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | (Optional) name of BASH variable to set to the return value rather than printing return value |
            ##
            listNames)
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[2]}\""
              local __T_methodNames=""
              local __T_currentMethodIndex
              while [[ "$__T_tempVariable" = *";"* ]]
              do
                __T_currentMethodIndex="${__T_tempVariable##*:}"
                eval "__T_methodNames=\"\${T_TYPE_$4[\$__T_currentMethodIndex]%%^*} \${__T_methodNames}\""
                __T_tempVariable="${__T_tempVariable%;*}"
              done
              if [ $# -eq 4 ]
              then
                printf "${__T_methodNames% }"
              else
                printf -v "$5" "${__T_methodNames% }"
              fi

              # ;bark_GENERIC_0:3;anotherMethod:4
              ;;

            ## ### `reflection types methods listSafeNames`
            ##
            ## Returns a space-delimited list of the reflection-safe method names for this type.
            ##
            ## To get the original method names, i.e. with original generic parameter names, use `listNames`
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `methods` |
            ## > > | `$3` | `listSafeNames` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | (Optional) name of BASH variable to set to the return value rather than printing return value |
            ##
            listSafeNames)
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[2]}\""
              if shopt -q extglob
              then
                __T_tempVariable="${__T_tempVariable//:+([0-9])}"
              else
                shopt -s extglob
                __T_tempVariable="${__T_tempVariable//:+([0-9])}"
                shopt -u extglob
              fi
              __T_tempVariable="${__T_tempVariable//;/ }"
              if [ $# -eq 4 ]
              then
                printf "${__T_tempVariable# }"
              else
                printf -v "$5" "${__T_tempVariable# }"
              fi
              ;;

            ## ### `reflection types methods undefine`
            ##
            ## Remove the given methods from the type definition.
            ##
            ## > ℹ️ Implementation Detail
            ## >
            ## > The underlying BASH variable which stores this type definition will keep
            ## > an empty array index value where this methods definition previously was,
            ## > so this does not reduce the size of the type definition BASH variable.
            ##
            ## > > | | Parameter |
            ## > > |-|-----------|
            ## > > | `$1` | `types` |
            ## > > | `$2` | `methods` |
            ## > > | `$3` | `undefine` |
            ## > > | `$4` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
            ## > > | `$5` | Reflection-safe method name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions.  |
            ##
            undefine)
              local __T_tempVariable
              eval "__T_tempVariable=\"\${T_TYPE_$4[2]}\""
              __T_tempVariable="${__T_tempVariable#*;$5:}" # Get rid of the left side, leaving just the method index (possibly followed by a ;)
              __T_tempVariable="${__T_tempVariable%%;*}" # This gets the array index of the method definition
              eval "T_TYPE_$4[$__T_tempVariable]=\"\"" # Clear the method definition (leaving the array index, `undefine` does not rearrange the array)
              if shopt -q extglob
              then
                eval "T_TYPE_$4[2]=\"\${T_TYPE_$4[2]/;$5:+([0-9])}\"" # Remove the method name from the field index lookup
              else
                shopt -s extglob
                eval "T_TYPE_$4[2]=\"\${T_TYPE_$4[2]/;$5:+([0-9])}\"" # Remove the method name from the field index lookup
                shopt -u extglob
              fi
              ;;

            ## ### `reflection types methods params`
            ##
            ## `TODO` talk about params
            ##
            ## - [`reflection types methods params define`](#reflection-types-methods-params-define)
            ## - [`reflection types methods params list`](#reflection-types-methods-params-list)
            ## - [`reflection types methods params getComment`](#reflection-types-methods-params-getComment)
            ## - [`reflection types methods params getDefaultValue`](#reflection-types-methods-params-getDefaultValue)
            ## - [`reflection types methods params getModifier`](#reflection-types-methods-params-getModifier)
            ## - [`reflection types methods params getType`](#reflection-types-methods-params-getType)
            ## - [`reflection types methods params undefine`](#reflection-types-methods-params-undefine)
            ##
            params)
              case "$4" in

                ## ### `reflection types methods params define`
                ##
                ## Add a parameter to the specified method.
                ##
                ## > > | | Parameter |
                ## > > |-|-----------|
                ## > > | `$1` | `types` |
                ## > > | `$2` | `methods` |
                ## > > | `$3` | `params` |
                ## > > | `$4` | `define` |
                ## > > | `$5` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
                ## > > | `$6` | Reflection-safe method name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions.  |
                ## > > | `$7` | Parameter name |
                ## > > | `$8` | Reflection-safe type name of parameter type (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
                ## > > | `$9` | Parameter modifier, e.g. `out` or `ref` or blank value |
                ## > > | `$10` | Parameter default value. This is stored separately from the method definition, it is stored in its own index of the type definition BASH array. |
                ## > > | `$11` | Parameter comment. This is stored separately from the method definition, it is stored in its own index of the type definition BASH array when `T_COMMENTS=enabled`. |
                ##
                define)
                  :
                ;;

                ## ### `reflection types methods params getDefaultValue`
                ##
                ## Get the default value of a method parameter with the provided name, if any
                ##
                ## > > | | Parameter |
                ## > > |-|-----------|
                ## > > | `$1` | `types` |
                ## > > | `$2` | `methods` |
                ## > > | `$3` | `params` |
                ## > > | `$4` | `getDefaultValue` |
                ## > > | `$5` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
                ## > > | `$6` | Reflection-safe method name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions.  |
                ## > > | `$7` | Parameter name|
                ## > > | `$8` | (Optional) name of BASH variable to set to the return value rather than printing return value |
                ##
                getDefaultValue)
                  :
                ;;

                ## ### `reflection types methods params getModifier`
                ##
                ## Get the modifier of a method parameter with the provided name, if any, e.g. `out` or `ref`
                ##
                ## > > | | Parameter |
                ## > > |-|-----------|
                ## > > | `$1` | `types` |
                ## > > | `$2` | `methods` |
                ## > > | `$3` | `params` |
                ## > > | `$4` | `getModifier` |
                ## > > | `$5` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
                ## > > | `$6` | Reflection-safe method name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions.  |
                ## > > | `$7` | Parameter name|
                ## > > | `$8` | (Optional) name of BASH variable to set to the return value rather than printing return value |
                ##
                getModifier)
                  :
                ;;

                ## ### `reflection types methods params getType`
                ##
                ## Get the full type name of a method parameter with the provided name
                ##
                ## > > | | Parameter |
                ## > > |-|-----------|
                ## > > | `$1` | `types` |
                ## > > | `$2` | `methods` |
                ## > > | `$3` | `params` |
                ## > > | `$4` | `getType` |
                ## > > | `$5` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
                ## > > | `$6` | Reflection-safe method name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions.  |
                ## > > | `$7` | Parameter name|
                ## > > | `$8` | (Optional) name of BASH variable to set to the return value rather than printing return value |
                ##
                getType)
                  :
                ;;

                ## ### `reflection types methods params listNames`
                ##
                ## Returns a space-delimited list of param names for this method
                ##
                ## > > | | Parameter |
                ## > > |-|-----------|
                ## > > | `$1` | `types` |
                ## > > | `$2` | `methods` |
                ## > > | `$3` | `params` |
                ## > > | `$4` | `listNames` |
                ## > > | `$5` | Reflection-safe type name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions. |
                ## > > | `$6` | Reflection-safe method name (use [`safeName`](#reflection-safeName) to acquire) which converts generic type and method names into a BASH variable compatible format for use directly with hot-path reflection functions.  |
                ## > > | `$7` | (Optional) name of BASH variable to set to the return value rather than printing return value |
                ##
                listNames)
                  local __T_tempVariable
                  eval "__T_tempVariable=\"\${T_TYPE_$5[2]}\""
                  __T_tempVariable="${__T_tempVariable#*;$6:}" # Get rid of the left side, leaving just the method index (possibly followed by a ;)
                  __T_tempVariable="${__T_tempVariable%%;*}" # This gets the array index of the method definition
                  eval "__T_tempVariable=\${T_TYPE_$5[\$__T_tempVariable]}"
                  local __T_currentParamDefinition
                  local __T_paramNames=""
                  while [[ "$__T_tempVariable" = *"&"* ]]
                  do
                    __T_currentParamDefinition="${__T_tempVariable##*&}"
                    __T_paramNames="${__T_currentParamDefinition%%:*} ${__T_paramNames}"
                    __T_tempVariable="${__T_tempVariable%&*}"
                  done
                  if [ $# -eq 6 ]
                  then
                    printf "${__T_paramNames% }"
                  else
                    printf -v "$7" "${__T_paramNames% }"
                  fi
                ;;

                *)
                  echo "Unknown 'reflection types methods params' command: $4"
                  ;;
              esac
              ;;
            *)
              echo "Unknown 'reflection types methods' command: $3"
              ;;
          esac
          ;;
        *)
          echo "Unknown 'reflection types' command: $2"
          ;;
      esac
      ;;

    ## ## 📸 `reflection snapshots`
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
    ## Variables are `set` and `unset`.
    ##
    ## ### 🎨 BASH Data Representation
    ##
    ## Variables are represented in BASH single-dimensional array structures (see [TeaScript use of BASH arrays](#TeaScript-use-of-BASH-arrays) above)
    ##
    ## TODO: details
    ##
    variables)
      case "$2" in

        ## ### `reflection variables exists`
        ##
        ## Returns 1 if variable with provided name does not exist else returns 0.
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `variables` |
        ## > > | `$2` | `getType` |
        ## > > | `$3` | Variable name |
        ##
        exists)
          eval "[ -n \"\${T_VAR_$3+x}\" ]"
          ;;

        ## ### `reflection variables isReferenceType`
        ##
        ## Returns 0 if variable is a `r` reference type else returns 1.
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `variables` |
        ## > > | `$2` | `getType` |
        ## > > | `$3` | Variable name |
        ##
        isReferenceType)
          eval "[ \"\${T_VAR_$3[0]%;*}\" = r ]"
          ;;

        ## ### `reflection variables getValueTypeCode`
        ##
        ## Get the type of this variable, e.g. object reference, literal value, or named reference.
        ##
        ## ℹ️ Note: this returns the code for the value type, e.g. `r` or `v` or `n`.  
        ##
        ## See [`getValueType`](#reflection-variables-getValueType) to get friendly name.
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `variables` |
        ## > > | `$2` | `getValueTypeCode` |
        ## > > | `$3` | Variable name |
        ##
        getValueTypeCode)
          eval "printf \"\${T_VAR_$3[0]%;*}\""
          ;;

        ## ### `reflection variables getType`
        ##
        ## Get the type stored in the variable, e.g. `String` or `Integer`.
        ##
        ## For named references this value is blank.
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `variables` |
        ## > > | `$2` | `getType` |
        ## > > | `$3` | Variable name |
        ## > > | `$4` | (Optional) name of BASH variable to set to the return value rather than printing return value |
        ##
        getType)
          if eval "[ -n \"\${T_VAR_$3+x}\" ]"
          then
            if [ $# -eq 3 ]
            then
              eval "printf \"\${T_VAR_$3[0]#*;}\""
            else
              eval "printf -v \"$4\" \"\${T_VAR_$3[0]#*;}\""
            fi
          else
            return 1
          fi
          ;;

        ## ### `reflection variables getValue`
        ##
        ## Get the value stored in this variable, e.g. a literal text value or an Object ID
        ## for reference or a field index is the variable stores as `struct`.
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `variables` |
        ## > > | `$2` | `getValue` |
        ## > > | `$3` | Variable name |
        ## > > | `$4` | (Optional) name of BASH variable to set to the return value rather than printing return value |
        ##
        getValue)
          if [ $# -eq 3 ]
          then
            eval "printf \"\${T_VAR_$3[1]}\""
          else
            eval "printf -v \"$4\" \"\${T_VAR_$3[1]}\""
          fi
          ;;

        ## ### `reflection variables getValueType`
        ##
        ## > 👥 User Function
        ##
        ## Get the type of this variable, e.g. object reference, literal value, or named reference.
        ##
        ## Specifically returns one of these values: `nameref`, `byref`, or `val`.
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `variables` |
        ## > > | `$2` | `getValueType` |
        ## > > | `$3` | Variable name |
        ##
        getValueTypeName)
          # TODO rename this to start with __T_
          local valueTypeCode
          eval "valueTypeCode=\"\${T_VAR_$3[0]%;*}\""
          reflection getCodeValue "$valueTypeCode"
          ;;

        ## ### `reflection variables list`
        ##
        ## > 👥 User Function
        ##
        ## Returns a list of all defined variables including their type and value, one per line.
        ##
        ## - For `struct` types, the value will appear empty. Use [`variables show`](#reflection-variables-show) to view details.
        ## - For named reference variables, the type will be empty. Named references do not copy the type of their target (_target may change_).
        ##
        ## Variable information is tab-delimited.
        ##
        ## To print just the variable names:
        ##
        ## ```sh
        ## reflection variables list | awk '{print $1}'
        ## ```
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$2` | `variables` |
        ##
        list)
          local variableName
          for variableName in $(( set -o posix ; set ) | grep "^T_VAR_" | sed 's/=.*//' | sed 's/^T_VAR_//' )
          do
            echo "$variableName\t$( reflection variables getValueTypeName "$variableName" )\t$( reflection variables getType "$variableName" )\t$( reflection variables getValue "$variableName" )"
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
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$1` | `variables` |
        ## > > | `$2` | `set` |
        ## > > | `$3` | Variable name |
        ## > > | `$4` | Type of variable (object `r`eference, literal `v`alue, or `n`amed reference) |
        ## > > | `$5` | Variable type (e.g. String or Integer) |
        ## > > | `$6` | Variable value (object ID, literal text value, or name of another variable) |
        ##
        set)
          eval "T_VAR_$3=(\"$4;$5\" \"$6\")"
          ;;

        ## ### `reflection variables show`
        ##
        ## > 👥 User Function
        ##
        ## Print out details about a variable.
        ##
        ## Print out details on separate lines including variable name, type, and value.
        ##
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$2` | `variables` |
        ## > > | `$3` | Variable name |
        ##
        show)
          if ! reflection variables exists "$3"
          then
            return 1
          else
            echo "Name: $3"
            echo "Value Type: $( reflection variables getValueTypeName "$3" )"
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
        ## > > | | Parameter |
        ## > > |-|-----------|
        ## > > | `$2` | `variables` |
        ## > > | `$3` | Variable name |
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

      ## ## `reflection safeName`
      ##
      ## Given a type name, e.g. `Dog` or `MyMap[K,V]`, get a type identifier which can be used to pass this type name to any other `reflection` function.
      ##
      ## Calling `reflection types exists MyMap[K,V]` does NOT WORK.
      ##
      ## Instead, use `safeName` to convert your type name for use with `reflection` functions:
      ##
      ## ```sh
      ## reflection types listFieldNames $(reflection safeName MyCollection[T])
      ##
      ## # Alternatively, you can get the Reflection-safe name in a variable:
      ## local reflectionSafeTypeName
      ## reflection safeName MyCollection[T] reflectionSafeTypeName
      ##
      ## # Now call your reflection calls using the converted reflection-safe type variable:
      ## reflection types listFieldNames $reflectionSafeTypeName
      ## reflection types listMethodNames $reflectionSafeTypeName
      ## ```
      ##
      ## Note: it is always safe to use `safeName` without "quotation marks"
      ##
      ## > > | | Parameter |
      ## > > |-|-----------|
      ## > > | `$1` | `safeName` |
      ## > > | `$2` | Full type name, including generics if any, e.g. `MyMap[K,V]`. All other reflection methods require a differently formatted type name for generic types. |
      ## > > | `$3` | (Optional) name of BASH variable to set to the return value rather than printing return value |
      ##
      safeName)
        if [[ "$2" = *"["* ]]
        then
          local __T_tempVariable="${2%%[*}_GENERIC_"
          local __T_genericTypeCount="${2//[^,]}"
          __T_tempVariable="$__T_tempVariable${#__T_genericTypeCount}"
        else
          local __T_tempVariable="$2"
        fi
        if [ $# -eq 2 ]
        then
          printf "$__T_tempVariable"
        else
          printf -v "$3" "$__T_tempVariable"
        fi
        ;;

    ## ## `reflection getCode`
    ##
    ## Returns the special code for values such as "class", "private", "public", "static", et al for use with `reflection`
    ##
    ## ```sh
    ## reflection getCode public
    ## # => P
    ##
    ## reflection getCode private
    ## # => p
    ##
    ## # Or get the code as a variable
    ## local code
    ##
    ## reflection getCode private code
    ## # => prints nothing
    ##
    ## printf "$code"
    ## #=> p
    ## ```
    ##
    ## See [`getCodeValue`](#reflection-getCodeValue) to get the value from a code
    ##
    ## > > | | Parameter |
    ## > > |-|-----------|
    ## > > | `$1` | `getCode` |
    ## > > | `$2` | Value such as "class" or "private" or "static" |
    ## > > | `$3` | (Optional) name of BASH variable to set to the return value rather than printing return value |
    ##
    getCode)
      local __T_code="$2"
      case "$2" in
        BASH) __T_code=b ;;
        class) __T_code=c ;;
        fn) __T_code=f ;;
        instance) __T_code=i ;;
        primitive) __T_code=m ;;
        nameref) __T_code=n ;;
        out) __T_code=o ;;
        private) __T_code=p ;;
        public) __T_code=P ;;
        ref) __T_code=r ;;
        struct) __T_code=s ;;
        static) __T_code=S ;;
        val) __T_code=v ;;
      esac
      # TODO: update all functions to use -n "$x" for this logic, it's much more sensible!
      if [ -n "$3" ]
      then
        printf -v "$3" "$__T_code"
      else
        printf "$__T_code"
      fi
      ;;

    ## ## `reflection getCodeValue`
    ##
    ## Returns the full value for a code such as `private` for `p` and `public` for `P`.
    ##
    ## These codes are used all throughout `reflection`
    ##
    ## See [`getCode`](#reflection-getCode) to get the code from a value
    ##
    ## ```sh
    ## reflection getCode public
    ## # => P
    ##
    ## reflection getCode private
    ## # => p
    ##
    ## # Or get the code as a variable
    ## local code
    ##
    ## reflection getCode private code
    ## # => prints nothing
    ##
    ## printf "$code"
    ## #=> p
    ## ```
    ##
    ## > > | | Parameter |
    ## > > |-|-----------|
    ## > > | `$1` | `getCodeValue` |
    ## > > | `$2` | Code such as "class" or "private" or "static" |
    ## > > | `$3` | (Optional) name of BASH variable to set to the return value rather than printing return value |
    ##
    getCodeValue)
      local __T_codeValue="$2"
      case "$2" in
        b) __T_codeValue=BASH ;;
        c) __T_codeValue=class ;;
        i) __T_codeValue=instance ;;
        f) __T_codeValue=fn ;;
        o) __T_codeValue=out ;;
        i) __T_codeValue=nameref ;;
        m) __T_codeValue=primitive ;;
        p) __T_codeValue=private ;;
        P) __T_codeValue=public ;;
        r) __T_codeValue=ref ;;
        s) __T_codeValue=struct ;;
        S) __T_codeValue=static ;;
        v) __T_codeValue=val ;;
      esac
      if [ -n "$3" ]
      then
        printf -v "$3" "$__T_codeValue"
      else
        printf "$__T_codeValue"
      fi
      ;;

    *)
      echo "Unknown 'reflection' command: $1"
      return 1
      ;;
  esac
}