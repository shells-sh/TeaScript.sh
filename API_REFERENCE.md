# `expression`

Prints out an analysis of the provided expression, e.g. `x + 5`

Used for debugging, not used by TeaScript.

TeaScript uses `evaluate` to evaluate expressions using the same logic of expression.

> > | | Parameter |
> > |-|-----------|
> > | `$@` | The expression, e.g. `new Dog` or `x + 5` |

# `objectid`

Get the Object ID of the specified variable.

Returns 1 if the variable does not exist or is not a reference type.

| | Parameter |
|-|-----------|
| `$1` | Variable name |
| `$2` | (Optional) name of BASH variable to store Object ID in |

# `reflection`

🍵 TeaScript Reflection API

TeaScript `reflection` provides a read-only interface for introspecting
on TeaScript types and variables as well as a write interface for defining
or making changes to types.

## Reference

- [`reflection objects`](#reflection-objects)
- [`reflection types`](#reflection-types)
  - [`reflection types fields`](#reflection-types-fields)
  - [`reflection types methods`](#reflection-types-methods)
- [`reflection variables`](#reflection-variables)

```sh
class Dog implements IAnimal do <<- _
  Represents a dog
_

  field name: String
  field age: Integer
end

reflection types getTypeInterface Dog
# => "IAnimal"

reflection types getTypeComment Dog
# => "Represents a dog"

reflection types methods listNames Dog
# => "name age"

reflection types getFieldType Dog age
# => "Integer"
```

> ℹ️ Note: `reflection` performs no argument assertions or validation  
> e.g. you can create a variable of a type that does not exist using `reflection variables`.
>
> Higher-level functions such as `var` and `class` and `def` perform these assertions and type-checking.

### 🔍 `reflectionType`

Whenever working with type names, you must convert your type name to a format compatible with `reflection` functions.

This allows the core `reflection` code to remain efficient while also supporting type syntax such as generics, e.g. `MyMap[K,V]`

```sh
reflection types listFieldNames $(reflection reflectionType MyCollection[T])

# Alternatively, you can get the reflection-safe type name in a variable:
local reflectionSafeTypeName
reflection reflectionType MyCollection[T] reflectionSafeTypeName

# Now call your reflection calls using the converted reflection-safe type variable:
reflection types listFieldNames $reflectionSafeTypeName
reflection types listMethodNames $reflectionSafeTypeName
```

> Implementation detail: this is only required for _generic type names_, e.g. `MyMap[K,V]`
>
> You can safely call `reflection` with direct type names when not providing generic names.
>
> For users, `reflectionType` is recommended so as to not create bugs when passing generic types.

### 📤 `out` BASH variables

Every reflection `get[Something]` function supports providing one optional additional argument.

When emitted, the `get[Something]` funtion will print the return value to console, e.g. `getType` might print `Dog`

When the additional argument is provided, the `get[Something]` function prints nothing and, instead, sets the value of the provided variable name to the return value.

This allows for getting return values without executing subshells.

Example:

```sh
source teascript.sh

var x = new Dog name: "Rover"

reflection variables getType x
# => prints "Dog"

local variableType
reflection variables getType x variableType
# => prints nothing

printf "$variableType"
# => "Dog"
```

Other functions such as `typeof` also follow this pattern

```sh
var y = new Cat name: "Mittens"

typeof y
# => Cat

local variableType
typeof x variableType
# => prints nothing

printf "$variableType"
# => "Cat"
```

### 💻 Developer Notes

> _Inline all the things!_

🌶️ **Reminder:** most of this file is in the _very hot path_ of TeaScript!

Do not attempt to "DRY" this code or refactor it to use meaningful variable names.

This code should be "wet" with as much inline code as possible.

**Never** attempt to refactor code into utility methods and, for example, then call `reflection utils something` within you code. Just - NO.

To the extent possible, **never** start any subshells or run other programs. This means NO `grep` or `sed` or `awk`. Use built-in BASH string manipulation when possible.

Try not to allocate new native BASH variables. Instead, reuse variables as much as possible (_and limit use of variables, in general - prefer literal strings_). All BASH locals should be prefixed `__T_`.

Do not loop over values. Usually, if you are writing a loop, you are adding an `O(N)` or worse, do not do it.
Notable exception for [`addMethod`]() which takes a dynamic number of arguments for defining any number of parameters.
In general, keep everything `O(1)` as much as possible. User-friendly functions which are not on the hot path are allowed
to break these rules.

#### 👥 User Functions

TeaScript is an interpreted language which runs on the BASH interpreter.

This is going to be slow. There's no way around it. But we can do everything we can to keep all TeaScript operations as optimized as possible!

> This means making every operation `O(1)` if possible, please avoid `O(N)` in every way possible!

To make `reflection` more user-friendly, a number of functions are provided for use by end-users only.

These functions are annotated with `👥 User Function` and should _never_ be called by TeaScript core code.

#### Character Codes

> e.g. `p` for private -_vs_- `P` for public

Some of this code uses user-unfriendly archaic looking characters to represent various bits of type metadata.

This contains a lookup table for all characters.

> Note: most of the read-only reflection functions such as `reflection types getFieldVisibility` return friendly names such as `public` or `private`.
>
> These functions are not used in any path of the core TeaScript engine and perform name conversions.
>
> Other functions such as `reflection types define` expect these characters to be provided as arguments and _do not support_ friendly names such as `public` (use `P` instead).

| Character | Meaning |
|-----------|---------|
| `a` | `abstract` |
| `c` | `class` |
| `i` | `interface` |
| `n` | Named reference, e.g. marking a variable as being a reference to another variable |
| `p` | `private` |
| `P` | `public` |
| `r` | Reference, e.g. marking a type as being a reference type or a variable as containing a reference |
| `s` | `struct` |
| `S` | `static` |
| `v` | Value, e.g. marking a type as being a value type or a variable as containing a value |

#### TeaScript use of BASH arrays

BASH 4.0 introduces associative arrays.

Mac OS X uses a wicked old version of BASH: `3.2.57` (as mentioned above)

TeaScript is built from the ground up to support `3.2.57` so that it works out-of-the-box on Mac OS X.

However, even if TeaScript did make use of BASH associative arrays, they are still flat objects with a simple text value key/index and a simple text string value.

BASH associative arrays wouldn't actually benefit the TeaScript implementation a whole lot.

So we make the best use of BASH arrays by:

- Storing various bits of metadata inside of single indices
- Proving out own key --> index lookups

See [`reflection objects`](#reflection-objects), [`types`](#reflection-types), and [`variables`](#reflection-variables) for descriptions of how we store each of these using BASH arrays.

#### ⚠️ `eval`

To start with, various functions make use of `eval`. In fact, most do.

This is to support Mac's built-in version of BASH, which is BASH `3.2.57` and will always be this version due to `GPL` licensing.

After `reflection.sh` is mostly "complete" (_i.e. once `var` and `expression` and `class` and `def` are fully up-and-running_)
we will add Docker tests for both BASH `3.2.57` as well as the latest versions of BASH 5 which is distributed
with Linux and used on Windows as well and create 2 versions of `reflection.sh`, one targetting BASH 4.3+ which removes all use of `eval`.

> ℹ️ `eval` is used for defining single-dimensional array variables with dynamic names
> and modifying or reading from those arrays. In BASH 4.3+ these operations are doable by making
> use of `declare -g` and `typeset -n`.
>
> When we create the `eval`less version of `reflection.sh`, we will do benchmarking to see if the `eval`less
> version is _faster_ on BASH 5 or if it's actually slower than `eval`.
> It might turn out that `typeset -n` is prohibitively slow and the copy of `reflection.sh`
> might just use `declare -g` but otherwise be identical. We will see! Can't wait to try and to benchmark :)

## `reflection objects`

Manages the TeaScript **Heap** where objects are allocated.

Objects are `create`'d (_allocated_) and `dispose`'d of (_deallocated_).

All created objects are provided a unique Object ID identifier for
referencing the object, e.g. from a variable.

You can think of objects as simple key/value stores.

The object does *not* know the *types* of the keys/values, that information is stored on the type.

Every object has:

  1. a unique object ID identifier (_see [Object IDs](#-Object-IDs) below for more info on how these are generated_)
  2. a Type name, e.g. `String` or `Integer`
  3. keys and values (these are stored as simple strings, each value in its own index of a single-dimensional BASH array)

### ➗ Object IDs

Object IDs are generated via [`/dev/urandom`](https://en.wikipedia.org/wiki//dev/random).

> _In Unix-like operating systems, /dev/random, /dev/urandom and /dev/arandom are special files that serve as pseudorandom number generators._  
> ~ wikipedia

The random portion of Object IDs is 32 characters long.

The specific command TeaScript uses to generate object IDs is:

```sh
cat /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
```

### 🗑️ Garbage Collection

Unlike variables, which are managed on the stack within a given scope,
objects are not automatically disposed of when a variable goes out of scope.

To deallocate objects which are no longer being referenced,
the garbage collector must be run which disposes of all objects
which are no longer being references by: variables or other objects.

You can run the garbage collector at any time via: `reflection objects gc run`

To simply view objects which are no longer in use and would be reaped and disposed of
by the garbage collector, you can run `reflection objects gc unused`

### 🎨 BASH Data Representation

Objects are represented in BASH single-dimensional array structures (see [TeaScript use of BASH arrays](#TeaScript-use-of-BASH-arrays) above)

TODO: details

### `reflection objects create`

Creates an object of a given type and allocates it on the heap.

The object ID is provided to the caller by passing the name of a variable and this function
will set the variable value to the object ID. This allows calling `reflection objects create`
outside of a subshell.

> ℹ️ At the time of writing, you cannot currently provide key/value fields to `reflection objects create`,
> you must use `setField` for every individual field.

#### 🗑️ Garbage Collection

TeaScript automatically runs a garbage collector when a certain number of objects have been allocated.

This can be configured by setting the `T_GC_OBJECT_THRESHOLD` variable to an integer value (default: `1000`).

To disable automatic garbage collection, `unset T_GC_OBJECT_THRESHOLD`.

Be sure to set or unset `T_GC_OBJECT_THRESHOLD` _after_ sourcing `teascript.sh`.

You can run the garbage collector manually at any time by running: `reflection objects gc run`.

See [`objects gc`](#reflection-objects-gc) for more details.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `objects` |
> > | `$2` | `create` |
> > | `$3` | Type name, e.g. `String` or `Integer` |
> > | `$4` | `out` variable name to persist the object ID |

### `reflection objects dispose`

Deallocate the object.

Note: this does no checking to see if the object leaves any orphans behind.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `objects` |
> > | `$2` | `dispose` |
> > | `$3` | Object ID |

### `reflection objects exists`

Return 0 if an object with the provided ID exists / is currently allocated else returns 1.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `objects` |
> > | `$2` | `exists` |
> > | `$3` | Object ID |

### `reflection objects gc`

Run the garbage collector (_reap all unused objects -or- simply list all unused object IDs_)

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `objects` |
> > | `$2` | `gc` |
> > | `$3` | `run` or `unused` |

### `reflection objects getField`

Get the value of the field in this given object.

If the field does not exist, returns 1.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `objects` |
> > | `$2` | `getField` |
> > | `$3` | Object ID |
> > | `$4` | Field name |

### `reflection objects list`

> 👥 Expensive. Reminder: do not use this in the hot path. This is for users.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `objects` |
> > | `$2` | `list` |

### `reflection objects setField`

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `objects` |
> > | `$2` | `setField` |
> > | `$3` | Object ID |
> > | `$4` | Field name |
> > | `$5` | Field value |

### `reflection objects show`

TODO - update to show pretty things :)

> 👥 Expensive. Reminder: do not use this in the hot path. This is for users.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `objects` |
> > | `$2` | `show` |
> > | `$3` | Object ID |

## `reflection types`

Manages the TeaScript types in the TeaScript type system.

Types are `define`'d and `undefine`'d.

Types are used for describing the shape and behavior of objects and values.

Every type has a "type", e.g. it is a `class` or a `struct` etc. We call these the 'descriptor' (_to reduce confusion, it's really the type type_).

In addition to classes, value types such as literal primitives (`string`, `int`, et al)
and `struct` are also described using TeaScript types.

### 🎨 BASH Data Representation

Variables are represented in BASH single-dimensional array structures (see [TeaScript use of BASH arrays](#TeaScript-use-of-BASH-arrays) above)

```sh
reflection types define Array [...]
# => T_TYPE_Array

reflection types define Array[T]
# => T_TYPE_Array_GENERIC_T

reflection types define Map[K,V]
# => T_TYPE_Map_GENERIC_K_V
```

> | `T_TYPE_` index | Description |
> |-----------------|-------------|
> | `0` | Descriptor name or code, e.g. `c` for `class`, `s` for `struct` et al (see [codes reference](#Character-Codes) above), followed b full type name, e.g. `Array` or `Array[T]`, followed by base class and interfaces, with comment if provided |
> | `1` | Field lookup table, mapping field named to index value where field definition is stored |
> | `2` | Method lookup table, mapping method name to index value where method definition is stored |

```sh
T_TYPE_Array_GENERIC_T=([0]="Array[T];s|Object<IEnumerable,IComparable>This represents a typed array of a provided generic type.")
```

### `reflection types define`

Define a new type, e.g. a `class` or a `struct`

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `define` |
> > | `$3` | Full type name, including generics if any, e.g. `MyMap[K,V]`. All other reflection methods require a differently formatted type name for generic types. |
> > | `$4` | Descriptor name or code, e.g. `c` for `class` or `s` for `struct`. For extensibility, this is stored/used raw if not a known built-in code, allowing definition of one's own descriptors. |
> > | `$5` | Base class name (or empty string) |
> > | `$6` | Interface names (comma-delimited without spaces) (or empty string) |
> > | `$7` | Comment text, if any. Note: this is only persisted if `T_COMMENTS=enabled` (default value in development environment) |

### `reflection types exists`

Return 0 if a type with the provided name exists else returns 1.

Note: for generics, this should be the type name as it was originally defined.  
e.g. if there is a defined `Collection[T]`, then `exists Collection[T]` will succeed
but `exists Collection[K]` will fail.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `exists` |
> > | `$3` | Reflection-safe Type Name (use reflectionType to acquire) which converts generic type names into a BASH variable compatible format for use directly with hot-path reflection functions. |

### `reflection types getBaseClass`

Get the base or 'super' class of the provided type, if any.

e.g. all `class` types inherit from `Object` by default

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `getBaseClass` |
> > | `$3` | Reflection-safe Type Name (use reflectionType to acquire) which converts generic type names into a BASH variable compatible format for use directly with hot-path reflection functions. |
> > | `$4` | (Optional) name of BASH variable to set to the return value rather than printing return value |

### `reflection types getComment`

Gets the comment text for the type, if any.

Note: this is saved to reflection only if `T_COMMENTS=enabled` (default in development environment)

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `getBaseClass` |
> > | `$3` | Reflection-safe Type Name (use reflectionType to acquire) which converts generic type names into a BASH variable compatible format for use directly with hot-path reflection functions. |
> > | `$4` | (Optional) name of BASH variable to set to the return value rather than printing return value |

### `reflection types getDescriptorCode`

Get the short code of this type's "type" or "descriptor", e.g. `c` for `class` or `s` for `struct`

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `getDescriptorCode` |
> > | `$3` | Reflection-safe Type Name (use reflectionType to acquire) which converts generic type names into a BASH variable compatible format for use directly with hot-path reflection functions. |
> > | `$4` | (Optional) name of BASH variable to set to the return value rather than printing return value |

### `reflection types getDescriptor`

Get the full name of this type's "type" or "descriptor", e.g. `class` or `struct`

> 👥 User Function

> Note: this is used by `typeof`. Please do not use `typeof` in core TeaScript code, it is for users.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `getDescriptor` |
> > | `$3` | Reflection-safe Type Name (use reflectionType to acquire) which converts generic type names into a BASH variable compatible format for use directly with hot-path reflection functions. |
> > | `$4` | (Optional) name of BASH variable to set to the return value rather than printing return value |

### `reflection types getGenericTypes`

Get the original names of the 

> 👥 User Function

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `getGenericTypes` |
> > | `$3` | Reflection-safe Type Name (use reflectionType to acquire) which converts generic type names into a BASH variable compatible format for use directly with hot-path reflection functions. |
> > | `$4` | (Optional) name of BASH variable to set to the return value rather than printing return value |

### `reflection types getInterfaces`

Return a space-delimited list of all the interfaces this type implements.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `getInterfaces` |
> > | `$3` | Reflection-safe Type Name (use reflectionType to acquire) which converts generic type names into a BASH variable compatible format for use directly with hot-path reflection functions. |
> > | `$4` | (Optional) name of BASH variable to set to the return value rather than printing return value |

### `reflection types undefine`

Undefine type with provided name.

Note: like all other `reflection` functions (_excluding [types define](#reflection-types-define)_), this required a `reflectionType` converted type name.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `undefine` |
> > | `$3` | Reflection-safe Type Name (use reflectionType to acquire) which converts generic type names into a BASH variable compatible format for use directly with hot-path reflection functions. |

## `reflection types fields`

`TODO` talk about fields!

### `reflection types fields define`

Define a field on this type.

Fields must be of a certain type.

Fields can have optional default values.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `fields` |
> > | `$3` | `define` |
> > | `$4` | Reflection-safe Type Name (use reflectionType to acquire) which converts generic type names into a BASH variable compatible format for use directly with hot-path reflection functions. |
> > | `$5` | Field name, e.g. `name` |
> > | `$6` | Full type name for this field, including generics if any, e.g. `MyMap[K,V]`. All other reflection methods require a differently formatted type name for generic types. |
> > | `$7` | Scope code, e.g. `s` for `static` or `i` for `instance` |
> > | `$8` | Visibility code, e.g. `p` for `private` or `P` for `public` |
> > | `$9` | Default value, e.g. `"Hello, world!"` |
> > | `$10` | Comment text, if any. Note: this is only persisted if `T_COMMENTS=enabled` (default value in development environment) |

### `reflection types fields exists`

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `fields` |
> > | `$3` | `exists` |
> > | `$4` | Reflection-safe Type Name (use reflectionType to acquire) which converts generic type names into a BASH variable compatible format for use directly with hot-path reflection functions. |
> > | `$5` | Field name |

### `reflection types fields getComment`

Returns the field comment, if any.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `fields` |
> > | `$3` | `getComment` |
> > | `$4` | Reflection-safe Type Name (use reflectionType to acquire) which converts generic type names into a BASH variable compatible format for use directly with hot-path reflection functions. |
> > | `$5` | Field name |
> > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |

### `reflection types fields getDefaultValue`

Returns the default value for this field, if any.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `fields` |
> > | `$3` | `getDefaultValue` |
> > | `$4` | Reflection-safe Type Name (use reflectionType to acquire) which converts generic type names into a BASH variable compatible format for use directly with hot-path reflection functions. |
> > | `$5` | Field name |
> > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |

### `reflection types fields getScope`

Returns this this field's scope, e.g. `static` or `instance`

> 👥 User Function

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `fields` |
> > | `$3` | `getScope` |
> > | `$4` | Reflection-safe Type Name (use reflectionType to acquire) which converts generic type names into a BASH variable compatible format for use directly with hot-path reflection functions. |
> > | `$5` | Field name |
> > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |

### `reflection types fields getScopeCode`

Returns the short code for this field's scope, e.g. `S` for `static` and `i` for instance

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `fields` |
> > | `$3` | `getScopeCode` |
> > | `$4` | Reflection-safe Type Name (use reflectionType to acquire) which converts generic type names into a BASH variable compatible format for use directly with hot-path reflection functions. |
> > | `$5` | Field name |
> > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |

### `reflection types fields getType`

Returns the full type name of this field.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `fields` |
> > | `$3` | `getType` |
> > | `$4` | Reflection-safe Type Name (use reflectionType to acquire) which converts generic type names into a BASH variable compatible format for use directly with hot-path reflection functions. |
> > | `$5` | Field name |
> > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |

### `reflection types fields getVisibility`

Get this fields's visibility, e.g. `public` or `private`

> 👥 User Function

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `fields` |
> > | `$3` | `getVisibility` |
> > | `$4` | Reflection-safe Type Name (use reflectionType to acquire) which converts generic type names into a BASH variable compatible format for use directly with hot-path reflection functions. |
> > | `$5` | Field name |
> > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |

### `reflection types fields getVisibilityCode`

Returns the short code for this field's visibility, e.g. `P` for `public` and `p` for `private`

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `fields` |
> > | `$3` | `getVisibilityCode` |
> > | `$4` | Reflection-safe Type Name (use reflectionType to acquire) which converts generic type names into a BASH variable compatible format for use directly with hot-path reflection functions. |
> > | `$5` | Field name |
> > | `$6` | (Optional) name of BASH variable to set to the return value rather than printing return value |

### `reflection types fields undefine`

Remove the given field from the type definition.

> ℹ️ Implementation Detail
>
> The underlying BASH variable which stores this type definition will keep
> an empty array index value where this field definition previously was,
> so this does not reduce the size of the type definition BASH variable.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `fields` |
> > | `$3` | `undefine` |
> > | `$4` | Reflection-safe Type Name (use reflectionType to acquire) which converts generic type names into a BASH variable compatible format for use directly with hot-path reflection functions. |
> > | `$5` | Field name |

## `reflection types methods`

`TODO` talk about methods!

### `reflection types methods define`

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `methods` |
> > | `$3` | ... |
> > | `$4` | ... |
> > | `$5` | ... |

### `reflection types methods undefine`

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `types` |
> > | `$2` | `methods` |
> > | `$3` | ... |
> > | `$4` | ... |
> > | `$5` | ... |

## `reflection snapshots`

You can save the state of your TeaScript program to a snapshot and load it later.

You can specify whether to snapshot just types or also variables etc.

Can be serialized and reloaded for faster program boot time.

Can reduce snapshot size as well with option to remove all type comments.

## `reflection variables`

Manages the TeaScript **Stack** where in-scope variables are allocated.

Variables are `set` and `unset`.

### 🎨 BASH Data Representation

Variables are represented in BASH single-dimensional array structures (see [TeaScript use of BASH arrays](#TeaScript-use-of-BASH-arrays) above)

TODO: details

### `reflection variables exists`

Returns 1 if variable with provided name does not exist else returns 0.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `variables` |
> > | `$2` | `getType` |
> > | `$3` | Variable name |

### `reflection variables isReferenceType`

Returns 0 if variable is a `r` reference type else returns 1.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `variables` |
> > | `$2` | `getType` |
> > | `$3` | Variable name |

### `reflection variables getValueTypeCode`

Get the type of this variable, e.g. object reference, literal value, or named reference.

ℹ️ Note: this returns the code for the value type, e.g. `r` or `v` or `n`.  

See [`getValueType`](#reflection-variables-getValueType) to get friendly name.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `variables` |
> > | `$2` | `getValueTypeCode` |
> > | `$3` | Variable name |

### `reflection variables getType`

Get the type stored in the variable, e.g. `String` or `Integer`.

For named references this value is blank.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `variables` |
> > | `$2` | `getType` |
> > | `$3` | Variable name |
> > | `$4` | (Optional) name of BASH variable to set to the return value rather than printing return value |

### `reflection variables getValue`

Get the value stored in this variable, e.g. a literal text value or an Object ID
for reference or a field index is the variable stores as `struct`.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `variables` |
> > | `$2` | `getValue` |
> > | `$3` | Variable name |
> > | `$4` | (Optional) name of BASH variable to set to the return value rather than printing return value |

### `reflection variables getValueType`

Get the type of this variable, e.g. object reference, literal value, or named reference.

Specifically returns one of these values: `nameref`, `byref`, or `byval`.

> 🚨 Expensive. Reminder: do not use this in the hot path. This is for users.

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `variables` |
> > | `$2` | `getValueType` |
> > | `$3` | Variable name |

### `reflection variables list`

Returns a list of all defined variables including their type and value, one per line.

- For `struct` types, the value will appear empty. Use [`variables show`](#reflection-variables-show) to view details.
- For named reference variables, the type will be empty. Named references do not copy the type of their target (_target may change_).

Variable information is tab-delimited.

To print just the variable names:

```sh
reflection variables list | awk '{print $1}'
```

> 🚨 Expensive. Reminder: do not use this in the hot path. This is for users.

> > | | Parameter |
> > |-|-----------|
> > | `$2` | `variables` |

### `reflection variables set`

Set / allocate a new variable.

```sh
# Define a variable which stores the literal text value in the variable (no object heap allocation)
reflection variables set myString v String "This is the literal value"

# Define a variable which references an object on the heap by its ID
reflection variables set myObject r Dog "<object ID referencing the Dog object>"

# Define a special named reference which is an alias / pointer to another variable by its name
reflection variables set myVariableAlias n "" myString
```

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `variables` |
> > | `$2` | `set` |
> > | `$3` | Variable name |
> > | `$4` | Type of variable (object `r`eference, literal `v`alue, or `n`amed reference) |
> > | `$5` | Variable type (e.g. String or Integer) |
> > | `$6` | Variable value (object ID, literal text value, or name of another variable) |

### `reflection variables show`

Print out details about a variable.

Print out details on separate lines including variable name, type, and value.

> 🚨 Expensive. Reminder: do not use this in the hot path. This is for users.

> > | | Parameter |
> > |-|-----------|
> > | `$2` | `variables` |
> > | `$3` | Variable name |

### `reflection variables unset`

Unset the given variable by name.

Returns 1 if variable with provided name does not exist else returns 0.

> > | | Parameter |
> > |-|-----------|
> > | `$2` | `variables` |
> > | `$3` | Variable name |

## `reflection reflectionType`

> 👥 User Function

Given a type name, e.g. `Dog` or `MyMap[K,V]`, get a type identifier which can be used to pass this type name to any other `reflection` function.

Calling `reflection types exists MyMap[K,V]` does NOT WORK.

Instead, use `reflectionType` to convert your type name for use with `reflection` functions:

```sh
reflection types listFieldNames $(reflection reflectionType MyCollection[T])

# Alternatively, you can get the reflection-safe type name in a variable:
local reflectionSafeTypeName
reflection reflectionType MyCollection[T] reflectionSafeTypeName

# Now call your reflection calls using the converted reflection-safe type variable:
reflection types listFieldNames $reflectionSafeTypeName
reflection types listMethodNames $reflectionSafeTypeName
```

Note: it is always safe to use `reflectionType` without "quotation marks"

> > | | Parameter |
> > |-|-----------|
> > | `$1` | `reflectionType` |
> > | `$2` | Full type name, including generics if any, e.g. `MyMap[K,V]`. All other reflection methods require a differently formatted type name for generic types. |
> > | `$3` | (Optional) name of BASH variable to set to the return value rather than printing return value |

# `var`

Sets a variable equal to the result of an expression.

Used implicit typing, e.g. with `var x = 5` the `x` variable is set to an `int` type
without using explicit typing using the alternate syntax: `int x = 5`

> > | | Parameter |
> > |-|-----------|
> > | `$1` | Variable name |
> > | `$2` | `=` |
> > | `$@` | Right hand side expression which is evaluated via `evaluate` |

