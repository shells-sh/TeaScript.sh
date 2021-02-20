@spec.reflection.variables.getValueType() {
  expect { reflection variables getValueType foo } toBeEmpty
  expect { reflection variables getValueType bar } toBeEmpty
  expect { reflection variables getValueType baz } toBeEmpty

  reflection variables set foo v Integer 42
  reflection variables set bar r String "Hello, world!"
  reflection variables set baz n "" foo

  expect { reflection variables getValueType foo } toEqual byval
  expect { reflection variables getValueType bar } toEqual byref
  expect { reflection variables getValueType baz } toEqual nameref
}