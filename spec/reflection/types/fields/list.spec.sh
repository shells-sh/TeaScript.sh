@spec.reflection.types.fields.list.no_generics() {
  local typeName=Dog
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P
  expect { reflection types fields list $safeTypeName } toContain "public\tinstance\tString\tname"
}

@spec.reflection.types.fields.list.single_generic_type_parameter() {
  local typeName=Collection[T]
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P "Rover" "Represents a dog, default name is Rover"
  assert reflection types fields define $safeTypeName siblings Array[Dog] S p "" "An array of sibling dogs"

  expect { reflection types fields list $safeTypeName } toContain "public\tinstance\tString\tname\tRover\tRepresents a dog, default name is Rover"
  expect { reflection types fields list $safeTypeName } toContain "private\tstatic\tArray[Dog]\tsiblings\t\tAn array of sibling dogs"
}

@spec.reflection.types.fields.list.multiple_generic_type_parameters() {
  local typeName=VariousThings[A,B,C]
  local safeTypeName="$(reflection reflectionType $typeName)"
  assert reflection types define $typeName c

  assert reflection types fields define $safeTypeName name String i P "Rover" "Represents a dog, default name is Rover"
  assert reflection types fields define $safeTypeName siblings Array[Dog] S p "" "An array of sibling dogs"
  assert reflection types fields define $safeTypeName relations Map[String,Dog] i P "" "Map o' Dogs"

  expect { reflection types fields list $safeTypeName } toContain "public\tinstance\tString\tname\tRover\tRepresents a dog, default name is Rover"
  expect { reflection types fields list $safeTypeName } toContain "private\tstatic\tArray[Dog]\tsiblings\t\tAn array of sibling dogs"
  expect { reflection types fields list $safeTypeName } toContain "public\tinstance\tMap[String,Dog]\trelations\t\tMap o' Dogs"
}