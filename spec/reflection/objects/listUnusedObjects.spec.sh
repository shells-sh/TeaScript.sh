@spec.reflection.objects.gc.unused() {
  expect { reflection objects gc unused } toBeEmpty

  local dogId
  reflection objects create Dog dogId

  local anotherDogId
  reflection objects create Dog anotherDogId

  expect { reflection objects gc unused } toContain "$dogId" "$anotherDogId"

  # No longer unused if referenced by a variable
  reflection variables set theDog r Dog "$dogId"

  expect { reflection objects gc unused } not toContain "$dogId"
  expect { reflection objects gc unused } toContain "$anotherDogId"

  reflection variables unset theDog

  expect { reflection objects gc unused } toContain "$dogId" "$anotherDogId"

  # No longer unused if referenced by an object
  local dogGroupId
  reflection objects create DogGroup dogGroupId

  expect { reflection objects gc unused } toContain "$dogId"
  
  reflection objects setField "$dogGroupId" firstDog "$anotherDogId"

  expect { reflection objects gc unused } not toContain "$anotherDogId"
  expect { reflection objects gc unused } toContain "$dogId"

  reflection objects setField "$dogGroupId" secondDog "$dogId"

  ( set -o posix ; set ) | grep "^T_OBJECT_\|^T_VAR_"

  expect { reflection objects gc unused } not toContain "$dogId"
  expect { reflection objects gc unused } toContain "$dogGroupId"

  reflection variables set theDogGroup r DogGroup "$dogGroupId"

  expect { reflection objects gc unused } toBeEmpty
}