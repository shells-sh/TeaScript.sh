@spec.reflection.types.fields.getComment.no_generics() {
  local typeName=Dog
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P "" "This represents a dog!"
  expect { reflection types fields getComment $safeTypeName name } toEqual "This represents a dog!"

  assert reflection types fields define $safeTypeName age String i P ""
  expect { reflection types fields getComment $safeTypeName age } toBeEmpty

  assert reflection types fields define $safeTypeName breed String i P "" "Breed name"
  expect { reflection types fields getComment $safeTypeName breed } toEqual "Breed name"
}

@spec.reflection.types.fields.getComment.single_generic_type_parameter() {
  local typeName=Collection[T]
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P "" "This represents a dog!"
  expect { reflection types fields getComment $safeTypeName name } toEqual "This represents a dog!"

  assert reflection types fields define $safeTypeName age String i P ""
  expect { reflection types fields getComment $safeTypeName age } toBeEmpty

  assert reflection types fields define $safeTypeName breed String i P "" "Breed name"
  expect { reflection types fields getComment $safeTypeName breed } toEqual "Breed name"
}

@spec.reflection.types.fields.getComment.multiple_generic_type_parameters() {
  local typeName=VariousThings[A,B,C]
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P "" "This represents a dog!"
  expect { reflection types fields getComment $safeTypeName name } toEqual "This represents a dog!"

  assert reflection types fields define $safeTypeName age String i P ""
  expect { reflection types fields getComment $safeTypeName age } toBeEmpty

  assert reflection types fields define $safeTypeName breed String i P "" "Breed name"
  expect { reflection types fields getComment $safeTypeName breed } toEqual "Breed name"
}

@spec.reflection.types.fields.getComment.as_variable() {
  local typeName=Dog
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P "" "This represents a dog!"

  local var
  expect "$var" toBeEmpty

  expect { reflection types fields getComment $safeTypeName name var } toBeEmpty

  expect "$var" toEqual "This represents a dog!"
}