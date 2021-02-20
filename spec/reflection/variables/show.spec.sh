# TODO this should print out objects using reflection objects show for objects.
# TODO this should print out the same type of thing for structs as well.
# Related: when structs are initialized, copy all of their default values. Do the same for classes. On init.

@spec.reflection.variables.show() {
  refute reflection variables show foo
  expect { reflection variables show foo } toBeEmpty

  reflection variables set foo v String "Hello, world!"

  assert reflection variables show foo
  expect { reflection variables show foo } toContain "Name: foo" "Value Type: byval" "Type: String" "Value: Hello, world!"
}