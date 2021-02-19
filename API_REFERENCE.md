# `$ reflection`

🍵 TeaScript Reflection API

TeaScript `reflection` provides a read-only interface for introspecting
on TeaScript types and variables as well as a write interface for defining
or making changes to types.

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

reflection types getFieldNames Dog
# => "name age"

reflection types getFieldType Dog age
# => "Integer"
```

## Reference

- [`reflection objects`](#reflection-objects)
- [`reflection types`](#reflection-types)
- [`reflection variables`](#reflection-variables)

## 💻 Developer Notes

> _Inline all the things!_

🌶️ **Reminder:** most of this file is in the _very hot path_ of TeaScript!

Do not attempt to "DRY" this code or refactor it to use meaningful variable names.

This code should be "wet" with as much inline code as possible.

**Never** attempt to refactor code into utility methods and, for example, then call `reflection utils something` within you code. Just - NO.

To the extent possible, **never** start any subshells or run other programs. This means NO `grep` or `sed` or `awk`. Use built-in BASH string manipulation when possible.

Also try not to allocate new native BASH variables. Instead, reuse variables as much as possible (_and limit use of variables, in general - prefer literal strings_).

### `eval`

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

### `p` private -_vs_- `P` public

Some of this code uses user-unfriendly archaic looking characters to represent various bits of type metadata.

This contains a lookup table for all characters.

> Note: most of the read-only reflection functions such as `reflection types getFieldVisibility` return friendly names such as `public` or `private`.
>
> These functions are not used in any path of the core TeaScript engine and perform name conversions.
>
> Other functions such as `reflection types define` expect these characters to be provided as arguments and _do not support_ friendly names such as `public` (use `P` instead).
>
> All functions used by the core TeaScript engine are marked with the race horse 🐎

| Character | Meaning |
|-----------|---------|
| `a` | `abstract` |
| `c` | `class` |
| `i` | `interface` |
| `p` | `private` |
| `P` | `public` |
| `r` | `byref` |
| `s` | `struct` |
| `S` | `static` |
| `v` | `byval` |

## `reflection invocations`

This might be what we call to invoke methods and see if they're available etc (?)

Might also have a `reflection expressions` for validating and evaluating expressions :)

## `reflection objects`

Manages the TeaScript **Heap** where objects are allocated.






### `reflection objects create`

### `reflection objects dispose`

### `reflection objects generateId`

### `reflection objects getField`

### `reflection objects list`

### `reflection objects setField`

### `reflection objects show`

## `reflection types`

`TODO` - space optimizations, which'll make it all harder to read, use COMMENTS 
- addField p s v main string[] args "" <-- public static void
  - CALLER needs to use this arcane language so that `reflection` doesn't need any conditionals
  - `reflection` should do conversions only when responding to `getXY` and should check against them when `isPublic` etc
- combine 'class' (c, i, s, e int stru enum) and value/object (v/o) and if it has literal support (y/n or l/n) <-- don't look at methods, would have to get method def to check if its static

local INDEX_OF_TYPE_OF_TYPE=0
local INDEX_OF_STORAGE_TYPE=1
local INDEX_OF_TYPE_COMMENT=2
local INDEX_OF_BASECLASS=3
local INDEX_OF_INTERFACE=4
local INDEX_OF_FIELD_LOOKUP=5
local INDEX_OF_METHOD_LOOKUP=6
local BASH_VAR_PREFIX_TYPE="T_TYPE_"

### `reflection types addField`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

### `reflection types addMethod`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

### `reflection types define`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

### `reflection types undefine`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

### `reflection types getFieldComment`

Get the comment of a field, if present.

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | `getFieldComment` |
| `$4` | Type name, e.g. `Dog` |
| `$5` | Field name, e.g. `name` |

### `reflection types getFieldDefaultValue`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | `getFieldDefaultValue` |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

### `reflection types getFieldScope`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | `getFieldScope` |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

### `reflection types getFieldType`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | `getFieldType` |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

UPDATE ME
### `reflection types getFieldVisibility`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | `getFieldVisibility` |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

UPDATE ME
### `reflection types getMethodComment`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | `getMethodComment` |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

UPDATE ME
### `reflection types getMethodParamNames`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | `getMethodParamNames` |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

UPDATE ME
### `reflection types getMethodParamDefaultValue`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | `getMethodParamDefaultValue` |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

UPDATE ME
### `reflection types getMethodParamType`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | `getMethodParamType` |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

UPDATE ME
### `reflection types getMethodReturnType`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | `getMethodReturnType` |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

UPDATE ME
### `reflection types getMethodScope`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | `getMethodScope` |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

UPDATE ME
### `reflection types getMethodVisibility`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | `getMethodVisibility` |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

UPDATE ME
### `reflection types getTypeBaseClass`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | `getTypeBaseClass` |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

UPDATE ME
### `reflection types getTypeComment`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | `getTypeComment` |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

UPDATE ME
### `reflection types getTypeOfType`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | `getTypeOfType` |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

UPDATE ME
### `reflection types getTypeInterface`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | `getTypeInterface` |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

UPDATE ME
### `reflection types getTypeStorageType`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | `getTypeStorageType` |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

UPDATE ME
### `reflection types list`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

### `reflection types show`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `types` |
| `$3` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

UPDATE ME
## `reflection snapshots`

You can save the state of your TeaScript program to a snapshot and load it later.

You can specify whether to snapshot just types or also variables etc.

Can be serialized and reloaded for faster program boot time.

Can reduce snapshot size as well with option to remove all type comments.

## `reflection variables`

Manages the TeaScript **Stack** where in-scope variables are allocated.

### `reflection variables getObjectId`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `variables` |
| `$3` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

### `reflection variables getType`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `variables` |
| `$3` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

### `reflection variables getValue`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `variables` |
| `$3` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

### `reflection variables list`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `variables` |
| `$3` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

### `reflection variables set`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `variables` |
| `$3` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

### `reflection variables show`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `variables` |
| `$3` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

### `reflection variables unset`

| | Parameter |
|-|-----------|
| `$1` | `reflection` |
| `$2` | `variables` |
| `$3` | ... |
| `$x` | ... |
| `$x` | ... |
| `$x` | ... |

