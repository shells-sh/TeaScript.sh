class Dog do
  reflection types methods define Dog bark i P DogFunctions.bark
end

class MyMap[K,V] do
  reflection types methods define $(safeName MyMap[K,V]) add[V] S p ""
end

@spec.reflection.types.methods.getScope() {
  expect { reflection types methods getScope Dog bark } toEqual instance
  expect { reflection types methods getScope $(safeName MyMap[K,V]) $(safeName add[V]) } toEqual static
}

@spec.reflection.types.methods.getScope.method_or_type_doesnt_exist() {
  expect { reflection types methods getScope Dog doesntExist } toFail "Method 'doesntExist' not found on type Dog"
  expect { reflection types methods getScope $(safeName MyMap[K,V]) doesntExist } toFail "Method 'doesntExist' not found on type MyMap[K,V]"
  expect { reflection types methods getScope DoesntExist doesntExist } toFail "Type 'DoesntExist' not found"
}

@spec.reflection.types.methods.getScope.as_variable() {
  local var
  expect "$var" toBeEmpty

  expect { reflection types methods getScope Dog bark var } toBeEmpty

  expect "$var" toEqual instance
}
