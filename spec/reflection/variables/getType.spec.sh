@spec.reflection.variables.getType() {
  refute reflection variables getType foo
  refute reflection variables getType bar
  expect { reflection variables getType foo } toBeEmpty
  expect { reflection variables getType bar } toBeEmpty

  reflection variables set foo v String "Hello, world!"
  reflection variables set bar v Integer 42

  assert reflection variables getType foo
  assert reflection variables getType bar
  expect { reflection variables getType foo } toEqual String
  expect { reflection variables getType bar } toEqual Integer

  # returns in a BASH variable instead of printing if variable name provided
  local variableType
  expect "$variableType" toBeEmpty
  expect { reflection variables getType foo variableType } toBeEmpty
  expect "$variableType" toEqual String
}