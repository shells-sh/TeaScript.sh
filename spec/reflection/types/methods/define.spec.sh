T_COMMENTS=enabled

@spec.reflection.methods.define.hello_world() {
  assert reflection types define Dog c

  refute reflection types methods exists Dog $(reflection safeName add[T,K])
  expect { reflection types methods listNames Dog } toBeEmpty
  expect { reflection types methods list Dog } toBeEmpty

  ## > > | `$@` | Method parameter arguments, 5 arguments are required to define each parameter: (1) param name (2) reflection-safe param type name (3) param default value or empty (4) param modifier, e.g. `out`, or empty (5) param comment. e.g. `String name "Rover" ""` or `Array[Dog] dogs "" out "Array of dogs"` |
  assert reflection types methods define Dog add[T,K] String i P Dog.add "The dog says 'woof!'" dog Dog "" "" "" message String "default value" "out" ""
  assert reflection types methods define Dog anotherMethod int S P Dog.anotherMethod

  assert reflection types methods exists Dog $(reflection safeName add[T,K])
  expect { reflection types methods listSafeNames Dog } toEqual "$(reflection safeName add[T,K]) anotherMethod"
  expect { reflection types methods listNames Dog } toEqual "add[T,K] anotherMethod"
  expect { reflection types methods list Dog } toContain "add[T,K]" "instance" "public" "String" "The dog says 'woof!'"
  expect { reflection types methods getMethodName Dog $(reflection safeName add[T,K]) } toEqual "add[T,K]"
  expect { reflection types methods getFunctionName Dog $(reflection safeName add[T,K]) } toEqual Dog.add
  expect { reflection types methods getFunctionName Dog $(reflection safeName anotherMethod) } toEqual Dog.anotherMethod
  expect { reflection types methods getScope Dog $(reflection safeName add[T,K]) } toEqual instance
  expect { reflection types methods getScopeCode Dog $(reflection safeName add[T,K]) } toEqual i
  expect { reflection types methods getVisibility Dog $(reflection safeName add[T,K]) } toEqual public
  expect { reflection types methods getVisibilityCode Dog $(reflection safeName add[T,K]) } toEqual P
  expect { reflection types methods getReturnType Dog $(reflection safeName add[T,K]) } toEqual String
  expect { reflection types methods getGenericParams Dog $(reflection safeName add[T,K]) } toEqual "T K"
  expect { reflection types methods getComment Dog $(reflection safeName add[T,K]) } toEqual "The dog says 'woof!'"

  assert reflection types methods undefine Dog $(reflection safeName add[T,K])

  refute reflection types methods exists Dog $(reflection safeName add[T,K])
}

@spec.reflection.methods.define.with_params() {
  assert reflection types define Dog c
  # expect { reflection types methods params listNames Dog bark } toBeEmpty

  assert reflection types methods define Dog add[T,K] String i P Dog.add "The dog says 'woof!'" dog Dog "" "" "" message String "default value" "out" ""
  expect { reflection types methods params listNames Dog $(reflection safeName add[T,K]) } toEqual "dog message"

  #
  # reflection types methods params define Dog bark result Result[BarkResult] o "" "Out variable which gets the result of the bark"
  # expect { reflection types methods params listNames Dog bark } toEqual "message result"
}

@pending.reflection.methods.define.add_params_individually() {
  :
}

@pending.reflection.methods.define.generic_method_parameter() {
  :
}

@pending.reflection.methods.define.multiple_generic_method_parameters() {
  :
}

@pending.reflection.methods.define.generic_type_and_return_type_and_method_parameters() {
  :
}