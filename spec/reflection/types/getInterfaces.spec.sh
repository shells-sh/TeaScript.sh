@spec.reflection.types.getInterfaces.no_generics() {
  reflection types define Dog c "" "" "This represents a dog"

  expect { reflection types getInterfaces Dog } toBeEmpty

  local BASHTypeVariables="$( ( set -o posix ; set ) | grep "^T_TYPE_" )"
  expect "$BASHTypeVariables" toContain 'T_TYPE_Dog=([0]="Dog;c|<>This represents a dog" [1]="" [2]="")'
}

@spec.reflection.types.getInterfaces.single_generic_type_parameter() {
  reflection types define MyCollection[T] s Collection IEnumerable,IComparable

  expect { reflection types getInterfaces $(reflection reflectionType MyCollection[T]) } toEqual "IEnumerable IComparable"
}

@spec.reflection.types.getInterfaces.multiple_generic_type_parameters() {
  reflection types define CollectionOfThings[A,B,C] s Collection IEnumerable,IComparable "Hello, world!"

  expect { reflection types getInterfaces $(reflection reflectionType CollectionOfThings[A,B,C]) } toEqual "IEnumerable IComparable"
}

@spec.reflection.types.getInterfaces.as_variable() {
  reflection types define CollectionOfThings[A,B,C] s Collection IEnumerable,IComparable "Hello, world!"

  local var
  expect "$var" toBeEmpty

  expect { reflection types getInterfaces $(reflection reflectionType CollectionOfThings[A,B,C]) var } toBeEmpty

  expect "$var" toEqual "IEnumerable IComparable"
}