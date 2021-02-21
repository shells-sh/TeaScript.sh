@spec.var.instantiateObject() {
  reflection types define Dog c

  expect { reflection types getInstanceIds Dog } toBeEmpty

  refute typeof rover

  var rover = new Dog

  assert typeof rover
  expect { typeof rover } toEqual Dog
  expect { reflection types getInstanceIds Dog } not toBeEmpty

  local dogObjectId
  objectid rover dogObjectId

  expect { reflection types getType "$dogObjectId" } toEqual "Dog"
}