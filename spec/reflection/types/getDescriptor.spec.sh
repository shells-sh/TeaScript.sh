@spec.reflection.types.getDescriptor.no_generics() {
  refute reflection types getDescriptor Dog

  reflection types define Dog c "" "" "This represents a dog"

  assert reflection types getDescriptor Dog
  expect { reflection types getDescriptor Dog } toEqual class
}

@spec.reflection.types.getDescriptor.single_generic_type_parameter() {
  refute reflection types getDescriptor $(reflection reflectionType MyCollection[T])

  reflection types define MyCollection[T] s Collection IEnumerable,IComparable

  assert reflection types getDescriptor $(reflection reflectionType MyCollection[T])
  expect { reflection types getDescriptor $(reflection reflectionType MyCollection[T]) } toEqual struct
}

@spec.reflection.types.getDescriptor.multiple_generic_type_parameters() {
  reflection types define CollectionOfThings[A,B,C] s Collection IEnumerable,IComparable "Hello, world!"

  expect { reflection types getDescriptor $(reflection reflectionType CollectionOfThings[A,B,C]) } toEqual struct
}

@spec.reflection.types.getDescriptor.as_variable() {
  reflection types define CollectionOfThings[A,B,C] s Collection IEnumerable,IComparable "Hello, world!"

  local var
  expect "$var" toBeEmpty

  expect { reflection types getDescriptor $(reflection reflectionType CollectionOfThings[A,B,C]) var } toBeEmpty

  expect "$var" toEqual struct
}