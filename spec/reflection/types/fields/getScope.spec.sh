@spec.reflection.types.fields.getScope.no_generics() {
  local typeName=Dog
  local safeTypeName="$(reflection safeName $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  expect { reflection types fields getScope $safeTypeName name } toEqual instance

  assert reflection types fields define $safeTypeName age Integer S p
  expect { reflection types fields getScope $safeTypeName age } toEqual static
}

@spec.reflection.types.fields.getScope.single_generic_type_parameter() {
  local typeName=Collection[T]
  local safeTypeName="$(reflection safeName $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  expect { reflection types fields getScope $safeTypeName name } toEqual instance

  assert reflection types fields define $safeTypeName age Integer S p
  expect { reflection types fields getScope $safeTypeName age } toEqual static
}

@spec.reflection.types.fields.getScope.multiple_generic_type_parameters() {
  local typeName=VariousThings[A,B,C]
  local safeTypeName="$(reflection safeName $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  expect { reflection types fields getScope $safeTypeName name } toEqual instance

  assert reflection types fields define $safeTypeName age Integer S p
  expect { reflection types fields getScope $safeTypeName age } toEqual static
}

@spec.reflection.types.fields.getScope.as_variable() {
  local typeName=Dog
  local safeTypeName="$(reflection safeName $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P

  local var
  expect "$var" toBeEmpty

  expect { reflection types fields getScope $safeTypeName name var } toBeEmpty

  expect "$var" toEqual instance
}