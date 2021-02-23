@spec.reflection.types.fields.getScopeCode.no_generics() {
  local typeName=Dog
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  expect { reflection types fields getScopeCode $safeTypeName name } toEqual i

  assert reflection types fields define $safeTypeName age Integer S p
  expect { reflection types fields getScopeCode $safeTypeName age } toEqual S
}

@spec.reflection.types.fields.getScopeCode.single_generic_type_parameter() {
  local typeName=Collection[T]
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  expect { reflection types fields getScopeCode $safeTypeName name } toEqual i

  assert reflection types fields define $safeTypeName age Integer S p
  expect { reflection types fields getScopeCode $safeTypeName age } toEqual S
}

@spec.reflection.types.fields.getScopeCode.multiple_generic_type_parameters() {
  local typeName=VariousThings[A,B,C]
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  expect { reflection types fields getScopeCode $safeTypeName name } toEqual i

  assert reflection types fields define $safeTypeName age Integer S p
  expect { reflection types fields getScopeCode $safeTypeName age } toEqual S
}

@spec.reflection.types.fields.getScopeCode.as_variable() {
  local typeName=Dog
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P

  local var
  expect "$var" toBeEmpty

  expect { reflection types fields getScopeCode $safeTypeName name var } toBeEmpty

  expect "$var" toEqual i
}