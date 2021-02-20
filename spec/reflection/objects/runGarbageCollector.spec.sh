@spec.reflection.objects.gc.run() {
  local dogId
  reflection objects create Dog dogId

  local catId
  reflection objects create Cat catId

  local animalGroupId
  reflection objects create AnimalGroup animalGroupId

  # Reference the animal group from a variable
  # and reference both animals within the group
  reflection variables set animals r AnimalGroup "$animalGroupId"
  reflection objects setField "$animalGroupId" theDog "$dogId"
  reflection objects setField "$animalGroupId" theCat "$catId"

  # There should currently be no unused objects
  expect { reflection objects gc unused } toBeEmpty

  # De-reference the cat from the group and it should become unused (but still exist - orphaned)
  reflection objects setField "$animalGroupId" theCat "different value"
  expect { reflection objects gc unused } toContain "$catId"
  expect { reflection objects gc unused } not toContain "$dogId" "$animalGroupId"
  assert reflection objects exists "$catId"

  # Run the GC! Bye bye kitty
  reflection objects gc run

  refute reflection objects exists "$catId"

  # But the other objects are still around and nothing unused
  assert reflection objects exists "$dogId"
  assert reflection objects exists "$animalGroupId"

  # De-reference the animal group variable and something interesting happens:
  # the animal GROUP is no longer referenced but the DOG ID is still referenced
  # by the group:
  expect { reflection objects gc unused } toBeEmpty
  
  reflection variables unset animals
  expect { reflection objects gc unused } toContain "$animalGroupId"
  expect { reflection objects gc unused } not toContain "$dogId"
  assert reflection objects exists "$dogId"
  assert reflection objects exists "$animalGroupId"

  # # Run the GC! Bye bye animal group
  reflection objects gc run

  # So, depending on the ORDER of the objects (based on their random IDs)
  # the dog may or may not still exist!

  # assert reflection objects exists "$dogId"
  # refute reflection objects exists "$animalGroupId"
  # expect { reflection objects gc unused } toContain "$dogId"

  # # To handle this scenario, the GC needs to sweep regularly.
  # # Each sweep may leave new orphans.
  # # Sweep again and the dog should be reaped.

  # reflection objects gc run

  # refute reflection objects exists "$dogId"
}

@spec.reflection.objects.gc.automatically_runs_after_a_certain_number_of_object_allocations() {
  T_GC_OBJECT_THRESHOLD=2
  T_GC_OBJECT_THRESHOLD_COUNT=0

  local fooId
  reflection objects create Foo fooId
  reflection variables set foo r "$fooId"

  local barId
  reflection objects create Bar barId
  # bar is not referenced by anything

  # TODO use mocking library to confirm that gc gets called

  assert reflection objects exists "$fooId"
  assert reflection objects exists "$barId"

  # Allocating the next object will run gc and deallocate bar

  local bazId
  reflection objects create Baz bazId

  assert reflection objects exists "$fooId"
  refute reflection objects exists "$barId"
  # assert reflection objects exists "$bazId"

  # After another 3 allocations, it will run again

  local aId
  reflection objects create A aId
  local bId
  reflection objects create B bId

  assert reflection objects exists "$fooId"
  assert reflection objects exists "$bazId"
  assert reflection objects exists "$aId"
  assert reflection objects exists "$bId"

  local cId
  reflection objects create C cId

  assert reflection objects exists "$fooId"
  refute reflection objects exists "$bazId"
  refute reflection objects exists "$aId"
  refute reflection objects exists "$bId"
  assert reflection objects exists "$cId"
}