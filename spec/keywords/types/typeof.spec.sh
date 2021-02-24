@spec.typeof.can_get_the_typeof_a_variable_or_type() {
  refute typeof AnimalGroup[T]
  reflection types define AnimalGroup[T] c
  assert typeof AnimalGroup[T]
  expect { typeof AnimalGroup[T] } toEqual class

  # local typeType
  # expect "$typeType" toBeEmpty
  # typeof AnimalGroup[T] typeType
  # expect "$typeType" toEqual class

  # refute typeof rover
  # reflection variables set rover r AnimalGroup[T] "<the object ID here>"
  # assert typeof rover

  # local variableType
  # expect "$variableType" toBeEmpty
  # typeof rover variableType
  # expect "$variableType" toEqual AnimalGroup[T]
}