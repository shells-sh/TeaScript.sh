@spec.reflection.types.getGenericParams.no_generics() {
  reflection types define Dog c "" "" "This represents a dog"

  expect { reflection types getGenericParams Dog } toBeEmpty
}

@spec.reflection.types.getGenericParams.single_generic_type_parameter() {
  reflection types define MyCollection[T] s Collection IEnumerable,IComparable

  expect { reflection types getGenericParams $(reflection safeName MyCollection[T]) } toEqual T
}

@spec.reflection.types.getGenericParams.multiple_generic_type_parameters() {
  reflection types define CollectionOfThings[A,B,C] s Collection IEnumerable,IComparable "Hello, world!"

  expect { reflection types getGenericParams $(reflection safeName CollectionOfThings[A,B,C]) } toEqual "A B C"
}

@spec.reflection.types.getGenericParams.as_variable() {
  reflection types define CollectionOfThings[A,B,C] s Collection IEnumerable,IComparable "Hello, world!"

  local var
  expect "$var" toBeEmpty

  expect { reflection types getGenericParams $(reflection safeName CollectionOfThings[A,B,C]) var } toBeEmpty

  expect "$var" toEqual "A B C"
}