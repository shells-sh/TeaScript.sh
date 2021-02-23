@spec.reflection.methods.define.no_params() {
  assert reflection types define Dog c

  refute reflection types methods exists Dog bark
  # expect { reflection types methods listNames Dog } not toContain "bark"

  assert reflection types methods define Dog bark String i P "The dog says 'woof'"

  assert reflection types methods exists Dog bark
  # expect { reflection types methods listNames Dog } toContain "bark"
  # expect { reflection types methods listNames Dog } toContain "instance" "public" "String" "The dog says 'woof!'"
  # expect { reflection types methods getScope Dog bark } toEqual ""
  # expect { reflection types methods getScopeCode Dog bark } toEqual ""
  # expect { reflection types methods getVisibility Dog bark } toEqual ""
  # expect { reflection types methods getVisibilityCode Dog bark } toEqual ""
  # expect { reflection types methods getReturnType Dog bark } toEqual ""
  # expect { reflection types methods getGenericParams Dog bark } toEqual ""
  # expect { reflection types methods getComment Dog bark } toEqual "The dog says 'woof!'"
  # expect { reflection types methods getParamNames Dog bark } toEqual ""
  # expect { reflection types methods getParamCount Dog bark } toEqual ""

  assert reflection types methods undefine Dog bark

  refute reflection types methods exists Dog bark
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