@spec.reflection.types.getBaseClass() {
  reflection types define Dog c "" "" "This represents a dog"

  expect { reflection types getBaseClass Dog } toBeEmpty

  reflection types define DogCollection[T] s Collection IEnumerable,IComparable

  expect { reflection types getBaseClass DogCollection[T] } toEqual Collection
}