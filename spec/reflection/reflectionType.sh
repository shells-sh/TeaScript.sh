@spec.reflection.types.reflectionType() {
  expect { reflection reflectionType Dog } toEqual Dog
  expect { reflection reflectionType DogCollection } toEqual DogCollection
  expect { reflection reflectionType DogCollection[T] } toEqual DogCollection_GENERIC_0
  expect { reflection reflectionType DogMap[K,V] } toEqual DogMap_GENERIC_1
  expect { reflection reflectionType $(reflection reflectionType CollectionOfThings[A,B,C]) } toEqual CollectionOfThings_GENERIC_2
}