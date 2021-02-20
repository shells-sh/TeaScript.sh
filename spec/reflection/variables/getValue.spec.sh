@spec.reflection.variables.getValue() {
  expect { reflection variables getValue foo } toBeEmpty
  expect { reflection variables getValue bar } toBeEmpty

  reflection variables set foo v String "Hello, world!"
  reflection variables set bar v Integer 42

  expect { reflection variables getValue foo } toEqual "Hello, world!"
  expect { reflection variables getValue bar } toEqual 42
}