# FIXME
# setUp() {
#   reflection types define Dog c
# }

@spec.expression.new_class_constructor_with_explicit_type() {
  reflection types define Dog c

  assert run { expression new Dog name: "Rover" }

  expect "$STDERR" toBeEmpty
  expect "$STDOUT" toContain "class constructor: Dog"
  expect "$STDOUT" toContain "Return type: Dog"
}

@spec.expression.new_implicit_class_constructor_with_type_hint() {
  reflection types define Dog c

  local T_HINT_TYPE=Dog
  assert run { expression new name: "Rover" }

  expect "$STDERR" toBeEmpty
  expect "$STDOUT" toContain "Type hint: Dog"
  expect "$STDOUT" toContain "class constructor: Dog"
  expect "$STDOUT" toContain "Return type: Dog"
}

@spec.expression.new_explicit_class_constructor_with_type_hint() {
  reflection types define Dog c

  local T_HINT_TYPE=Dog
  assert run { expression new Dog name: "Rover" }

  expect "$STDERR" toBeEmpty
  expect "$STDOUT" toContain "Type hint: Dog"
  expect "$STDOUT" toContain "class constructor: Dog"
  expect "$STDOUT" toContain "Return type: Dog"
}