@spec.typeof.can_get_the_typeof_a_variable_or_type() {
  refute typeof Dog
  reflection types define Dog c
  assert typeof Dog
  expect { typeof Dog } toEqual class

  local typeType
  expect "$typeType" toBeEmpty
  typeof Dog typeType
  expect "$typeType" toEqual class

  refute typeof rover
  reflection variables set rover r Dog "<the object ID here>"
  assert typeof rover

  local variableType
  expect "$variableType" toBeEmpty
  typeof rover variableType
  expect "$variableType" toEqual Dog
}