@spec.reflection.getCodeValue() {
  expect { reflection getCodeValue c } toEqual class
  expect { reflection getCodeValue i } toEqual instance
  expect { reflection getCodeValue n } toEqual nameref
  expect { reflection getCodeValue p } toEqual private
  expect { reflection getCodeValue P } toEqual public
  expect { reflection getCodeValue r } toEqual byref
  expect { reflection getCodeValue s } toEqual struct
  expect { reflection getCodeValue S } toEqual static
  expect { reflection getCodeValue v } toEqual byval
  expect { reflection getCodeValue custom } toEqual custom
}

@spec.reflection.getCodeValue.as_variable() {
  local var
  reflection getCodeValue c var
  expect "$var" toEqual class
  reflection getCodeValue i var
  expect "$var" toEqual instance
  reflection getCodeValue n var
  expect "$var" toEqual nameref
  reflection getCodeValue p var
  expect "$var" toEqual private
  reflection getCodeValue P var
  expect "$var" toEqual public
  reflection getCodeValue r var
  expect "$var" toEqual byref
  reflection getCodeValue s var
  expect "$var" toEqual struct
  reflection getCodeValue S var
  expect "$var" toEqual static
  reflection getCodeValue v var
  expect "$var" toEqual byval
  reflection getCodeValue custom var
  expect "$var" toEqual custom
}