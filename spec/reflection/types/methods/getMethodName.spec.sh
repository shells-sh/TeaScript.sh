
class Dog do
  reflection types methods define Dog bark i P
end

class MyMap[K,V] do
  reflection types methods define $(safeName MyMap[K,V]) add[V] S p
end

@spec.reflection.types.methods.getMethodName() {
  expect { reflection types methods getMethodName Dog bark } toEqual bark
  expect { reflection types methods getMethodName $(safeName MyMap[K,V]) $(safeName add[V]) } toEqual add[V]
}

@spec.reflection.types.methods.getMethodName.method_or_type_doesnt_exist() {
  expect { reflection types methods getMethodName Dog doesntExist } toFail "Method 'doesntExist' not found on type Dog"
  expect { reflection types methods getMethodName $(safeName MyMap[K,V]) doesntExist } toFail "Method 'doesntExist' not found on type MyMap[K,V]"
  expect { reflection types methods getMethodName DoesntExist doesntExist } toFail "Type 'DoesntExist' not found"
}

@spec.reflection.types.methods.getMethodName.as_variable() {
  local var
  expect "$var" toBeEmpty

  expect { reflection types methods getMethodName $(safeName MyMap[K,V]) $(safeName add[V]) var } toBeEmpty

  expect "$var" toEqual add[V]
}
