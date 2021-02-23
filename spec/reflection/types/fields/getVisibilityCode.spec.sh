@spec.reflection.types.fields.getVisibilityCode.no_generics() {
  local typeName=Dog
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  expect { reflection types fields getVisibilityCode $safeTypeName name } toEqual P

  assert reflection types fields define $safeTypeName age Integer i p
  expect { reflection types fields getVisibilityCode $safeTypeName age } toEqual p
}

@spec.reflection.types.fields.getVisibilityCode.single_generic_type_parameter() {
  local typeName=Collection[T]
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  expect { reflection types fields getVisibilityCode $safeTypeName name } toEqual P

  assert reflection types fields define $safeTypeName age Integer i p
  expect { reflection types fields getVisibilityCode $safeTypeName age } toEqual p
}

@spec.reflection.types.fields.getVisibilityCode.multiple_generic_type_parameters() {
  local typeName=VariousThings[A,B,C]
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  expect { reflection types fields getVisibilityCode $safeTypeName name } toEqual P

  assert reflection types fields define $safeTypeName age Integer i p
  expect { reflection types fields getVisibilityCode $safeTypeName age } toEqual p
}

@spec.reflection.types.fields.getVisibilityCode.as_variable() {
  local typeName=Dog
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P

  local var
  expect "$var" toBeEmpty

  expect { reflection types fields getVisibilityCode $safeTypeName name var } toBeEmpty

  expect "$var" toEqual P
}