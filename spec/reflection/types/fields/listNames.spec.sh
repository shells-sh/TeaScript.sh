@spec.reflection.types.fields.listNames.no_generics() {
  local typeName=Dog
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  expect { reflection types fields listNames $safeTypeName } toEqual "name"
}

@spec.reflection.types.fields.listNames.single_generic_type_parameter() {
  local typeName=Collection[T]
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  assert reflection types fields define $safeTypeName siblings Array[Dog] i P

  expect { reflection types fields listNames $safeTypeName } toEqual "name siblings"
}

@spec.reflection.types.fields.listNames.multiple_generic_type_parameters() {
  local typeName=VariousThings[A,B,C]
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  assert reflection types fields define $safeTypeName siblings Array[Dog] i P
  assert reflection types fields define $safeTypeName relations Map[String,Dog] i P

  expect { reflection types fields listNames $safeTypeName } toEqual "name siblings relations"
}

@spec.reflection.types.fields.listNames.as_variable() {
  local typeName=Dog
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  assert reflection types fields define $safeTypeName siblings Array[Dog] i P
  assert reflection types fields define $safeTypeName relations Map[String,Dog] i P

  local var
  expect "$var" toBeEmpty

  expect { reflection types fields listNames $safeTypeName var } toBeEmpty

  expect "$var" toEqual "name siblings relations"
}