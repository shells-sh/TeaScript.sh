class Dog do
  reflection types methods define Dog bark i P DogFunctions.bark
end

class MyMap[K,V] do
  reflection types methods define $(safeName MyMap[K,V]) add[V] S p ""
end

@spec.reflection.types.methods.getVisibility() {
  expect { reflection types methods getVisibility Dog bark } toEqual public
  expect { reflection types methods getVisibility $(safeName MyMap[K,V]) $(safeName add[V]) } toEqual private
}

@spec.reflection.types.methods.getVisibility.method_or_type_doesnt_exist() {
  expect { reflection types methods getVisibility Dog doesntExist } toFail "Method 'doesntExist' not found on type Dog"
  expect { reflection types methods getVisibility $(safeName MyMap[K,V]) doesntExist } toFail "Method 'doesntExist' not found on type MyMap[K,V]"
  expect { reflection types methods getVisibility DoesntExist doesntExist } toFail "Type 'DoesntExist' not found"
}

@spec.reflection.types.methods.getVisibility.as_variable() {
  local var
  expect "$var" toBeEmpty

  expect { reflection types methods getVisibility Dog bark var } toBeEmpty

  expect "$var" toEqual public
}
