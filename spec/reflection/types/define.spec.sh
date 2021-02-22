@spec.reflection.types.define() {
  refute reflection types exists Dog

  reflection types define Dog c "" "" "This represents a dog"

  assert reflection types exists Dog

  expect { reflection types getBaseType Dog } toEqual Dog
  expect { reflection types getGenericTypes Dog } toBeEmpty
  expect { reflection types getDescriptorCode Dog } toEqual c
  expect { reflection types getDescriptor Dog } toEqual class
  expect { reflection types getBaseClass Dog } toBeEmpty
  expect { reflection types getInterfaces Dog } toBeEmpty
  expect { reflection types getComment Dog } toEqual "This represents a dog"

  refute reflection types exists DogCollection
  refute reflection types exists DogCollection[T]

  reflection types define DogCollection[T] s Collection IEnumerable,IComparable

  refute reflection types exists DogCollection
  assert reflection types exists DogCollection[T]

  expect { reflection types getBaseType DogCollection[T] } toEqual DogCollection
  expect { reflection types getGenericTypes DogCollection[T] } toEqual T
  expect { reflection types getDescriptorCode DogCollection[T] } toEqual s
  expect { reflection types getDescriptor DogCollection[T] } toEqual struct
  expect { reflection types getBaseClass DogCollection[T] } toEqual Collection
  expect { reflection types getInterfaces DogCollection[T] } toEqual "IEnumerable IComparable"
  expect { reflection types getComment DogCollection[T] } toBeEmpty

  reflection types define CollectionOfThings[A,B,C] s Collection IEnumerable,IComparable "Hello, world!"

  expect { reflection types getBaseType CollectionOfThings[A,B,C] } toEqual CollectionOfThings
  expect { reflection types getGenericTypes CollectionOfThings[A,B,C] } toEqual "A B C"
  expect { reflection types getDescriptorCode CollectionOfThings[A,B,C] } toEqual s
  expect { reflection types getDescriptor CollectionOfThings[A,B,C] } toEqual struct
  expect { reflection types getBaseClass CollectionOfThings[A,B,C] } toEqual Collection
  expect { reflection types getInterfaces CollectionOfThings[A,B,C] } toEqual "IEnumerable IComparable"
  expect { reflection types getComment CollectionOfThings[A,B,C] } toEqual "Hello, world!"

  local BASHTypeVariables="$( ( set -o posix ; set ) | grep "^T_TYPE_" )"
  expect "$BASHTypeVariables" toContain 'T_TYPE_CollectionOfThings_GENERIC_2=([0]="CollectionOfThings[A,B,C];s|Collection<IEnumerable,IComparable>Hello, world!" [1]="" [2]="")'
  expect "$BASHTypeVariables" toContain 'T_TYPE_Dog=([0]="Dog;c|<>This represents a dog" [1]="" [2]="")'
  expect "$BASHTypeVariables" toContain 'T_TYPE_DogCollection_GENERIC_0=([0]="DogCollection[T];s|Collection<IEnumerable,IComparable>" [1]="" [2]="")'
}