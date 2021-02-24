@spec.reflection.types.fields.getType.no_generics() {
  local typeName=Dog
  local safeTypeName="$(reflection safeName $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P

  expect { reflection types fields getType $safeTypeName name } toEqual String
}

@spec.reflection.types.fields.getType.single_generic_type_parameter() {
  local typeName=Collection[T]
  local safeTypeName="$(reflection safeName $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name Array[Dog] i P

  expect { reflection types fields getType $safeTypeName name } toEqual Array[Dog]
}

@spec.reflection.types.fields.getType.multiple_generic_type_parameters() {
  local typeName=VariousThings[A,B,C]
  local safeTypeName="$(reflection safeName $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name Map[String,Dog] i P

  expect { reflection types fields getType $safeTypeName name } toEqual Map[String,Dog]
}

@spec.reflection.types.fields.getType.as_variable() {
  local typeName=Dog
  local safeTypeName="$(reflection safeName $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P

  local var
  expect "$var" toBeEmpty

  expect { reflection types fields getType $safeTypeName name var } toBeEmpty

  expect "$var" toEqual String
}