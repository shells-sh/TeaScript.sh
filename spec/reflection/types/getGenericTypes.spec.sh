@spec.reflection.types.getGenericTypes.no_generics() {
  reflection types define Dog c "" "" "This represents a dog"

  expect { reflection types getGenericTypes Dog } toBeEmpty
}

@spec.reflection.types.getGenericTypes.single_generic_type_parameter() {
  reflection types define MyCollection[T] s Collection IEnumerable,IComparable

  expect { reflection types getGenericTypes $(reflection reflectionType MyCollection[T]) } toEqual T
}

@spec.reflection.types.getGenericTypes.multiple_generic_type_parameters() {
  reflection types define CollectionOfThings[A,B,C] s Collection IEnumerable,IComparable "Hello, world!"

  expect { reflection types getGenericTypes $(reflection reflectionType CollectionOfThings[A,B,C]) } toEqual "A B C"
}

@spec.reflection.types.getGenericTypes.as_variable() {
  reflection types define CollectionOfThings[A,B,C] s Collection IEnumerable,IComparable "Hello, world!"

  local var
  expect "$var" toBeEmpty

  expect { reflection types getGenericTypes $(reflection reflectionType CollectionOfThings[A,B,C]) var } toBeEmpty

  expect "$var" toEqual "A B C"
}