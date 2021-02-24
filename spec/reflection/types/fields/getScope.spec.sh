class Dog do
  field name
  static field age
end

class MyMap[K,V] do
  field count
  static field items
end

@spec.reflection.types.fields.getScope() {
  expect { reflection types fields getScope Dog name } toEqual instance
  expect { reflection types fields getScope Dog age } toEqual static
  expect { reflection types fields getScope $(safeName MyMap[K,V]) count } toEqual instance
  expect { reflection types fields getScope $(safeName MyMap[K,V]) items } toEqual static
}

@spec.reflection.types.fields.getScope.field_or_type_doesnt_exist() {
  expect { reflection types fields getScope Dog doesntExist } toFail "Field 'doesntExist' not found on type Dog"
  expect { reflection types fields getScope $(safeName MyMap[K,V]) doesntExist } toFail "Field 'doesntExist' not found on type MyMap[K,V]"
  expect { reflection types fields getScope DoesntExist doesntExist } toFail "Type 'DoesntExist' not found"
}

@spec.reflection.types.fields.getScope.as_variable() {
  local var
  expect "$var" toBeEmpty

  expect { reflection types fields getScope Dog name var } toBeEmpty

  expect "$var" toEqual instance
}
