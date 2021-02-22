@spec.reflection.types.getBaseClass.no_generics() {
  reflection types define Dog c "" "" "This represents a dog"

  expect { reflection types getBaseClass Dog } toBeEmpty
}

@spec.reflection.types.getBaseClass.single_generic_type_parameter() {
  reflection types define DogCollection[T] s Collection IEnumerable,IComparable

  expect { reflection types getBaseClass $(reflection reflectionType DogCollection[T]) } toEqual Collection
}

@spec.reflection.types.getBaseClass.multiple_generic_type_parameters() {
  reflection types define CollectionOfThings[A,B,C] s Collection IEnumerable,IComparable "Hello, world!"

  expect { reflection types getBaseClass $(reflection reflectionType CollectionOfThings[A,B,C]) } toEqual Collection
}

@spec.reflection.types.getBaseClass.as_variable() {
  reflection types define CollectionOfThings[A,B,C] s Collection IEnumerable,IComparable "Hello, world!"

  local var
  expect { reflection types getBaseClass $(reflection reflectionType CollectionOfThings[A,B,C]) var } toBeEmpty
  expect "$var" toEqual Collection
}