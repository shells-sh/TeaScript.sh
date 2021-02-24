@spec.reflection.types.getDescriptorCode.no_generics() {
  reflection types define Dog c "" "" "This represents a dog"

  expect { reflection types getDescriptorCode Dog } toEqual c
}

@spec.reflection.types.getDescriptorCode.single_generic_type_parameter() {
  reflection types define MyCollection[T] s Collection IEnumerable,IComparable

  expect { reflection types getDescriptorCode $(reflection safeName MyCollection[T]) } toEqual s
}

@spec.reflection.types.getDescriptorCode.multiple_generic_type_parameters() {
  reflection types define CollectionOfThings[A,B,C] s Collection IEnumerable,IComparable "Hello, world!"

  expect { reflection types getDescriptorCode $(reflection safeName CollectionOfThings[A,B,C]) } toEqual s
}

@spec.reflection.types.getDescriptorCode.as_variable() {
  reflection types define CollectionOfThings[A,B,C] s Collection IEnumerable,IComparable "Hello, world!"

  local var
  expect "$var" toBeEmpty

  expect { reflection types getDescriptorCode $(reflection safeName CollectionOfThings[A,B,C]) var } toBeEmpty

  expect "$var" toEqual s
}