@spec.reflection.types.fields.getXXX.no_generics() {
  local typeName=Dog
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  expect { reflection types fields getXXX $safeTypeName name } toEqual "???"
}

@spec.reflection.types.fields.getXXX.single_generic_type_parameter() {
  local typeName=Collection[T]
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  expect { reflection types fields getXXX $safeTypeName name } toEqual "???"

  assert reflection types fields define $safeTypeName siblings Array[Dog] i P
  expect { reflection types fields getXXX $safeTypeName siblings } toEqual "???"
}

@spec.reflection.types.fields.getXXX.multiple_generic_type_parameters() {
  local typeName=VariousThings[A,B,C]
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  expect { reflection types fields getXXX $safeTypeName name } toEqual "???"

  assert reflection types fields define $safeTypeName siblings Map[String,Dog] i P
  expect { reflection types fields getXXX $safeTypeName siblings } toEqual "???"
}

@spec.reflection.types.fields.getXXX.as_variable() {
  local typeName=Dog
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P

  local var
  expect "$var" toBeEmpty

  expect { reflection types fields getXXX $safeTypeName name var } toBeEmpty

  expect "$var" toEqual "???"
}