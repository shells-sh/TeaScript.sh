@spec.reflection.types.define() {
  refute reflection types exists Dog

  reflection types define Dog c "" "" "This represents a dog"

  assert reflection types exists Dog

  expect { reflection types getBaseType Dog } toEqual Dog
  expect { reflection types getGenericTypes Dog } toBeEmpty
  expect { reflection types getDescriptorCode Dog } toEqual c
  expect { reflection types getDescriptorName Dog } toEqual class
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
  expect { reflection types getDescriptorName DogCollection[T] } toEqual struct
  expect { reflection types getBaseClass DogCollection[T] } toEqual Collection
  expect { reflection types getInterfaces DogCollection[T] } toEqual "IEnumerable IComparable"
  expect { reflection types getComment DogCollection[T] } toBeEmpty

  reflection types define MyMap[K,V] s

  expect { reflection types getBaseType MyMap[K,V] } toEqual MyMap
  expect { reflection types getGenericTypes MyMap[K,V] } toEqual "K V"
}

@spec.reflection.types.define.does_not_store_comment_if_disabled() {
  reflection types define Dog c "" "" "This represents a dog"
  expect { reflection types getComment Dog } toEqual "This represents a dog"

  local T_COMMENTS=disabled

  reflection types define Cat c "" "" "This represents a dog"
  expect { reflection types getComment Cat } toBeEmpty
}