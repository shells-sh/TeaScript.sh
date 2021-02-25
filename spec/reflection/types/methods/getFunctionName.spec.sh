class Dog do
  reflection types methods define Dog bark i P DogFunctions.bark
end

class MyMap[K,V] do
  reflection types methods define $(safeName MyMap[K,V]) add[V] S p ""
end

@spec.reflection.types.methods.getFunctionName() {
  expect { reflection types methods getFunctionName Dog bark } toEqual DogFunctions.bark
  expect { reflection types methods getFunctionName $(safeName MyMap[K,V]) $(safeName add[V]) } toBeEmpty
}

@spec.reflection.types.methods.getFunctionName.method_or_type_doesnt_exist() {
  expect { reflection types methods getFunctionName Dog doesntExist } toFail "Method 'doesntExist' not found on type Dog"
  expect { reflection types methods getFunctionName $(safeName MyMap[K,V]) doesntExist } toFail "Method 'doesntExist' not found on type MyMap[K,V]"
  expect { reflection types methods getFunctionName DoesntExist doesntExist } toFail "Type 'DoesntExist' not found"
}

@spec.reflection.types.methods.getFunctionName.as_variable() {
  local var
  expect "$var" toBeEmpty

  expect { reflection types methods getFunctionName Dog bark var } toBeEmpty

  expect "$var" toEqual DogFunctions.bark
}
