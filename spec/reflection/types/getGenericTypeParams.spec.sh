@spec.reflection.types.getGenericTypeParams.no_generics() {
  reflection types define Dog c "" "" "This represents a dog"

  expect { reflection types getGenericTypeParams Dog } toBeEmpty
}

@spec.reflection.types.getGenericTypeParams.single_generic_type_parameter() {
  reflection types define MyCollection[T] s Collection IEnumerable,IComparable

  expect { reflection types getGenericTypeParams $(reflection reflectionType MyCollection[T]) } toEqual T
}

@spec.reflection.types.getGenericTypeParams.multiple_generic_type_parameters() {
  reflection types define CollectionOfThings[A,B,C] s Collection IEnumerable,IComparable "Hello, world!"

  expect { reflection types getGenericTypeParams $(reflection reflectionType CollectionOfThings[A,B,C]) } toEqual "A B C"
}

@spec.reflection.types.getGenericTypeParams.as_variable() {
  reflection types define CollectionOfThings[A,B,C] s Collection IEnumerable,IComparable "Hello, world!"

  local var
  expect "$var" toBeEmpty

  expect { reflection types getGenericTypeParams $(reflection reflectionType CollectionOfThings[A,B,C]) var } toBeEmpty

  expect "$var" toEqual "A B C"
}