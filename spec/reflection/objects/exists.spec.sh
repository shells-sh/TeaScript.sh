
@spec.reflection.objects.exists() {
  local objectId

  expect "$objectId" toBeEmpty
  expect { reflection objects list } toBeEmpty

  reflection objects create Dog objectId

  assert reflection objects exists "$objectId"

  reflection objects dispose "$objectId"

  refute reflection objects exists "$objectId"
}