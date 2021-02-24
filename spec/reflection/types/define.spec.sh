T_COMMENTS=enabled

@spec.reflection.types.define.no_generics() {
  refute reflection types exists Dog

  reflection types define Dog c "" "" "This represents a dog"

  assert reflection types exists Dog

  expect { reflection types getGenericParams Dog } toBeEmpty
  expect { reflection types getDescriptorCode Dog } toEqual c
  expect { reflection types getDescriptor Dog } toEqual class
  expect { reflection types getBaseClass Dog } toBeEmpty
  expect { reflection types getInterfaces Dog } toBeEmpty
  expect { reflection types getComment Dog } toEqual "This represents a dog"
  expect { reflection types getTypeName $(reflection safeName Dog) } toEqual Dog

  local BASHTypeVariables="$( ( set -o posix ; set ) | grep "^T_TYPE_" )"
  expect "$BASHTypeVariables" toContain 'T_TYPE_Dog=([0]="Dog;c|<>This represents a dog" [1]="" [2]="")'
}

@spec.reflection.types.define.single_generic_type_parameter() {
  refute reflection types exists DogCollection
  refute reflection types exists $(reflection safeName MyCollection[T])

  reflection types define MyCollection[T] s Collection IEnumerable,IComparable

  refute reflection types exists DogCollection
  assert reflection types exists $(reflection safeName MyCollection[T])

  expect { reflection types getGenericParams $(reflection safeName MyCollection[T]) } toEqual T
  expect { reflection types getDescriptorCode $(reflection safeName MyCollection[T]) } toEqual s
  expect { reflection types getDescriptor $(reflection safeName MyCollection[T]) } toEqual struct
  expect { reflection types getBaseClass $(reflection safeName MyCollection[T]) } toEqual Collection
  expect { reflection types getInterfaces $(reflection safeName MyCollection[T]) } toEqual "IEnumerable IComparable"
  expect { reflection types getComment $(reflection safeName MyCollection[T]) } toBeEmpty
  expect { reflection types getTypeName $(reflection safeName MyCollection[T]) } toEqual MyCollection[T]

  local BASHTypeVariables="$( ( set -o posix ; set ) | grep "^T_TYPE_" )"
  expect "$BASHTypeVariables" toContain 'T_TYPE_MyCollection_GENERIC_0=([0]="MyCollection[T];s|Collection<IEnumerable,IComparable>" [1]="" [2]="")'
}

@spec.reflection.types.define.multiple_generic_type_parameters() {
  reflection types define CollectionOfThings[A,B,C] s Collection IEnumerable,IComparable "Hello, world!"

  expect { reflection types getGenericParams $(reflection safeName CollectionOfThings[A,B,C]) } toEqual "A B C"
  expect { reflection types getDescriptorCode $(reflection safeName CollectionOfThings[A,B,C]) } toEqual s
  expect { reflection types getDescriptor $(reflection safeName CollectionOfThings[A,B,C]) } toEqual struct
  expect { reflection types getBaseClass $(reflection safeName CollectionOfThings[A,B,C]) } toEqual Collection
  expect { reflection types getInterfaces $(reflection safeName CollectionOfThings[A,B,C]) } toEqual "IEnumerable IComparable"
  expect { reflection types getComment $(reflection safeName CollectionOfThings[A,B,C]) } toEqual "Hello, world!"

  local BASHTypeVariables="$( ( set -o posix ; set ) | grep "^T_TYPE_" )"
  expect "$BASHTypeVariables" toContain 'T_TYPE_CollectionOfThings_GENERIC_2=([0]="CollectionOfThings[A,B,C];s|Collection<IEnumerable,IComparable>Hello, world!" [1]="" [2]="")'
}