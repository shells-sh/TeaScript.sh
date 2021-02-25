class Dog do
  reflection types methods define Dog bark i P DogFunctions.bark
end

class MyMap[K,V] do
  reflection types methods define $(safeName MyMap[K,V]) add[V] S p ""
end

@spec.reflection.types.methods.getScopeCode() {
  expect { reflection types methods getScopeCode Dog bark } toEqual i
  expect { reflection types methods getScopeCode $(safeName MyMap[K,V]) $(safeName add[V]) } toEqual S
}

@spec.reflection.types.methods.getScopeCode.method_or_type_doesnt_exist() {
  expect { reflection types methods getScopeCode Dog doesntExist } toFail "Method 'doesntExist' not found on type Dog"
  expect { reflection types methods getScopeCode $(safeName MyMap[K,V]) doesntExist } toFail "Method 'doesntExist' not found on type MyMap[K,V]"
  expect { reflection types methods getScopeCode DoesntExist doesntExist } toFail "Type 'DoesntExist' not found"
}

@spec.reflection.types.methods.getScopeCode.as_variable() {
  local var
  expect "$var" toBeEmpty

  expect { reflection types methods getScopeCode Dog bark var } toBeEmpty

  expect "$var" toEqual i
}
