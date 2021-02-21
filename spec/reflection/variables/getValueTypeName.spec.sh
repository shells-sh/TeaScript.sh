@spec.reflection.variables.getValueTypeName() {
  expect { reflection variables getValueTypeName foo } toBeEmpty
  expect { reflection variables getValueTypeName bar } toBeEmpty
  expect { reflection variables getValueTypeName baz } toBeEmpty

  reflection variables set foo v Integer 42
  reflection variables set bar r String "Hello, world!"
  reflection variables set baz n "" foo

  expect { reflection variables getValueTypeName foo } toEqual byval
  expect { reflection variables getValueTypeName bar } toEqual byref
  expect { reflection variables getValueTypeName baz } toEqual nameref
}