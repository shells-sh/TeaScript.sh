@spec.reflection.types.safeName() {
  expect { reflection safeName Dog } toEqual Dog
  expect { reflection safeName DogCollection } toEqual DogCollection
  expect { reflection safeName MyCollection[T] } toEqual DogCollection_GENERIC_0
  expect { reflection safeName DogMap[K,V] } toEqual DogMap_GENERIC_1
  expect { reflection safeName $(reflection safeName CollectionOfThings[A,B,C]) } toEqual CollectionOfThings_GENERIC_2
}