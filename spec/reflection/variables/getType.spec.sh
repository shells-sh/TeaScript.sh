@spec.reflection.variables.getType() {
  expect { reflection variables getType foo } toBeEmpty
  expect { reflection variables getType bar } toBeEmpty

  reflection variables set foo v String "Hello, world!"
  reflection variables set bar v Integer 42

  expect { reflection variables getType foo } toEqual String
  expect { reflection variables getType bar } toEqual Integer
}