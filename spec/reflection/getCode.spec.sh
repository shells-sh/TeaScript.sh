@spec.reflection.getCode() {
  expect { reflection getCode class } toEqual c
  expect { reflection getCode instance } toEqual i
  expect { reflection getCode nameref } toEqual n
  expect { reflection getCode private } toEqual p
  expect { reflection getCode public } toEqual P
  expect { reflection getCode byref } toEqual r
  expect { reflection getCode struct } toEqual s
  expect { reflection getCode static } toEqual S
  expect { reflection getCode byval } toEqual v
  expect { reflection getCode custom } toEqual custom
}

@spec.reflection.getCode.as_variable() {
  local var
  reflection getCode class var
  expect "$var" toEqual c
  reflection getCode instance var
  expect "$var" toEqual i
  reflection getCode nameref var
  expect "$var" toEqual n
  reflection getCode private var
  expect "$var" toEqual p
  reflection getCode public var
  expect "$var" toEqual P
  reflection getCode byref var
  expect "$var" toEqual r
  reflection getCode struct var
  expect "$var" toEqual s
  reflection getCode static var
  expect "$var" toEqual S
  reflection getCode byval var
  expect "$var" toEqual v
  reflection getCode custom var
  expect "$var" toEqual custom
}