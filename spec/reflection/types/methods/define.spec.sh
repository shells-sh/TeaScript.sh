T_COMMENTS=enabled

@spec.reflection.methods.define.hello_world() {
  assert reflection types define Dog c

  refute reflection types methods exists Dog $(reflection safeName add[T,K])
  expect { reflection types methods listNames Dog } toBeEmpty
  expect { reflection types methods list Dog } toBeEmpty

  assert reflection types methods define Dog add[T,K] String i P Dog.add "The dog says 'woof!'"
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