@spec.reflection.types.fields.getVisibility.no_generics() {
  local typeName=Dog
  local safeTypeName="$(reflection safeName $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  expect { reflection types fields getVisibility $safeTypeName name } toEqual public

  assert reflection types fields define $safeTypeName age Integer i p
  expect { reflection types fields getVisibility $safeTypeName age } toEqual private
}

@spec.reflection.types.fields.getVisibility.single_generic_type_parameter() {
  local typeName=Collection[T]
  local safeTypeName="$(reflection safeName $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  expect { reflection types fields getVisibility $safeTypeName name } toEqual public

  assert reflection types fields define $safeTypeName age Integer i p
  expect { reflection types fields getVisibility $safeTypeName age } toEqual private
}

@spec.reflection.types.fields.getVisibility.multiple_generic_type_parameters() {
  local typeName=VariousThings[A,B,C]
  local safeTypeName="$(reflection safeName $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  expect { reflection types fields getVisibility $safeTypeName name } toEqual public

  assert reflection types fields define $safeTypeName age Integer i p
  expect { reflection types fields getVisibility $safeTypeName age } toEqual private
}

@spec.reflection.types.fields.getVisibility.as_variable() {
  local typeName=Dog
  local safeTypeName="$(reflection safeName $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P

  local var
  expect "$var" toBeEmpty

  expect { reflection types fields getVisibility $safeTypeName name var } toBeEmpty

  expect "$var" toEqual public
}