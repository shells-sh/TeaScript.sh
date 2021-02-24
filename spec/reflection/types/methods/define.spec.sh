T_COMMENTS=enabled

@spec.reflection.methods.define.no_params() {
  assert reflection types define Dog c

  refute reflection types methods exists Dog bark
  expect { reflection types methods listNames Dog } toBeEmpty
  expect { reflection types methods list Dog } toBeEmpty

  assert reflection types methods define Dog bark[T] String i P Dog.bark "The dog says 'woof!'"
  assert reflection types methods define Dog anotherMethod int S P Dog.anotherMethod

  assert reflection types methods exists Dog $(reflection safeName bark[T])
  expect { reflection types methods listSafeNames Dog } toEqual "$(reflection safeName bark[T]) anotherMethod"
  expect { reflection types methods listNames Dog } toEqual "bark[T] anotherMethod"
  expect { reflection types methods list Dog } toContain "bark[T]" "instance" "public" "String" "The dog says 'woof!'"
  expect { reflection types methods getMethodName Dog $(reflection safeName bark[T]) } toEqual "bark[T]"
  expect { reflection types methods getFunctionName Dog $(reflection safeName bark[T]) } toEqual Dog.bark
  expect { reflection types methods getScope Dog $(reflection safeName bark[T]) } toEqual instance
  expect { reflection types methods getScopeCode Dog $(reflection safeName bark[T]) } toEqual i
  expect { reflection types methods getVisibility Dog $(reflection safeName bark[T]) } toEqual public
  expect { reflection types methods getVisibilityCode Dog $(reflection safeName bark[T]) } toEqual P
  expect { reflection types methods getReturnType Dog $(reflection safeName bark[T]) } toEqual String
  # expect { reflection types methods getGenericParams Dog $(reflection safeName bark[T]) } toBeEmpty
  expect { reflection types methods getComment Dog $(reflection safeName bark[T]) } toEqual "The dog says 'woof!'"
  # expect { reflection types methods getParamNames Dog $(reflection safeName bark[T]) } toEqual ""
  # expect { reflection types methods getParamCount Dog $(reflection safeName bark[T]) } toEqual ""

  # assert reflection types methods undefine Dog bark

  # refute reflection types methods exists Dog bark
}

@pending.reflection.methods.define.one_param() {
  :
}

@pending.reflection.methods.define.multiple_params() {
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