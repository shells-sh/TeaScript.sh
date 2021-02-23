@spec.reflection.types.fields.getDefaultValue.no_generics() {
  local typeName=Dog
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P "Rover"
  expect { reflection types fields getDefaultValue $safeTypeName name } toEqual "Rover"

  assert reflection types fields define $safeTypeName age Integer i P
  expect { reflection types fields getDefaultValue $safeTypeName age } toBeEmpty

  assert reflection types fields define $safeTypeName breed String i p "Golden Retriever"
  expect { reflection types fields getDefaultValue $safeTypeName breed } toEqual "Golden Retriever"
}

@spec.reflection.types.fields.getDefaultValue.single_generic_type_parameter() {
  local typeName=Collection[T]
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P "Rover"
  expect { reflection types fields getDefaultValue $safeTypeName name } toEqual "Rover"

  assert reflection types fields define $safeTypeName age Integer i P
  expect { reflection types fields getDefaultValue $safeTypeName age } toBeEmpty

  assert reflection types fields define $safeTypeName breed Array[Dog] i p "Golden Retriever"
  expect { reflection types fields getDefaultValue $safeTypeName breed } toEqual "Golden Retriever"
}

@spec.reflection.types.fields.getDefaultValue.multiple_generic_type_parameters() {
  local typeName=VariousThings[A,B,C]
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P "Rover"
  expect { reflection types fields getDefaultValue $safeTypeName name } toEqual "Rover"

  assert reflection types fields define $safeTypeName age Integer i P
  expect { reflection types fields getDefaultValue $safeTypeName age } toBeEmpty

  assert reflection types fields define $safeTypeName breed Map[String,Dog] i p "Golden Retriever"
  expect { reflection types fields getDefaultValue $safeTypeName breed } toEqual "Golden Retriever"
}

@spec.reflection.types.fields.getDefaultValue.as_variable() {
  local typeName=Dog
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P "Rover"

  local var
  expect "$var" toBeEmpty

  expect { reflection types fields getDefaultValue $safeTypeName name var } toBeEmpty

  expect "$var" toEqual "Rover"
}