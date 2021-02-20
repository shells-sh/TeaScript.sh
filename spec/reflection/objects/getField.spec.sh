@spec.reflection.objects.getField() {
  local dogObjectId
  reflection objects create Dog dogObjectId

  refute reflection objects getField "$dogObjectId" name
  reflection objects setField "$dogObjectId" name "Rover"
  assert reflection objects getField "$dogObjectId" name
  reflection objects setField "$dogObjectId" age 4

  expect { reflection objects getField "$dogObjectId" name } toEqual "Rover"
  expect { reflection objects getField "$dogObjectId" age } toEqual 4

  local catObjectId
  reflection objects create Cat catObjectId
  reflection objects setField "$catObjectId" name "Mittens"
  reflection objects setField "$catObjectId" age 10

  expect { reflection objects getField "$catObjectId" name } toEqual "Mittens"
  expect { reflection objects getField "$catObjectId" age } toEqual 10
  expect { reflection objects getField "$dogObjectId" name } toEqual "Rover"
  expect { reflection objects getField "$dogObjectId" age } toEqual 4
}