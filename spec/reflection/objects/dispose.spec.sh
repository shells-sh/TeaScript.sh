
@spec.reflection.objects.create() {
  local objectId

  expect "$objectId" toBeEmpty
  expect { reflection objects list } toBeEmpty

  reflection objects create Dog objectId

  expect "$objectId" not toBeEmpty
  expect { reflection objects list } not toBeEmpty
  expect { reflection objects list } toContain "Dog"

  reflection objects dispose "$objectId"

  expect { reflection objects list } toBeEmpty
}