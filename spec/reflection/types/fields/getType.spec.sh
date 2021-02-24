class Dog do
  field name
  field int age
  field Array[Dog] siblings
end

class MyMap[K,V] do
  field int count
  field Array[V] items
end

@spec.reflection.types.fields.getType() {
  expect { reflection types fields getType Dog name } toEqual string
  expect { reflection types fields getType Dog age } toEqual int
  expect { reflection types fields getType Dog siblings } toEqual Array[Dog]
  expect { reflection types fields getType $(safeName MyMap[K,V]) count } toEqual int
  expect { reflection types fields getType $(safeName MyMap[K,V]) items } toEqual Array[V]
}

@spec.reflection.types.fields.getType.field_or_type_doesnt_exist() {
  expect { reflection types fields getType Dog doesntExist } toFail "Field 'doesntExist' not found on type Dog"
  expect { reflection types fields getType $(safeName MyMap[K,V]) doesntExist } toFail "Field 'doesntExist' not found on type MyMap[K,V]"
  expect { reflection types fields getType DoesntExist doesntExist } toFail "Type 'DoesntExist' not found"
}

@spec.reflection.types.fields.getType.as_variable() {
  local var
  expect "$var" toBeEmpty

  expect { reflection types fields getType Dog siblings var } toBeEmpty

  expect "$var" toEqual Array[Dog]
}
