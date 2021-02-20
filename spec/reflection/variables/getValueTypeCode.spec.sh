@spec.reflection.variables.getValueTypeCode() {
  expect { reflection variables getValueTypeCode foo } toBeEmpty
  expect { reflection variables getValueTypeCode bar } toBeEmpty
  expect { reflection variables getValueTypeCode baz } toBeEmpty

  reflection variables set foo v Integer 42
  reflection variables set bar r String "Hello, world!"
  reflection variables set baz n "" foo

  expect { reflection variables getValueTypeCode foo } toEqual v
  expect { reflection variables getValueTypeCode bar } toEqual r
  expect { reflection variables getValueTypeCode baz } toEqual n
}