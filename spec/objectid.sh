@spec.objectid.returns_objectId_for_provided_variable() {
  local mockObjectId="object-abc123"

  refute objectid foo

  reflection variables set foo r Dog "$mockObjectId"

  assert objectid foo
  expect { objectid foo } toEqual "$mockObjectId"

  # When a second argument is provided, sets the BASH variable value rather than printing out
  # local getObjectId
  # expect "$getObjectId" toBeEmpty
  # objectid foo getObjectId
  # expect "$getObjectId" toEqual "$mockObjectId"
}