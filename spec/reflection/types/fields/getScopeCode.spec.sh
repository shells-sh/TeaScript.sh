class Dog do
  field name
  static field age
end

class MyMap[K,V] do
  field count
  static field items
end

@spec.reflection.types.fields.getScopeCode() {
  expect { reflection types fields getScopeCode Dog name } toEqual i
  expect { reflection types fields getScopeCode Dog age } toEqual S
  expect { reflection types fields getScopeCode $(safeName MyMap[K,V]) count } toEqual i
  expect { reflection types fields getScopeCode $(safeName MyMap[K,V]) items } toEqual S
}

@spec.reflection.types.fields.getScopeCode.field_or_type_doesnt_exist() {
  expect { reflection types fields getScopeCode Dog doesntExist } toFail "Field 'doesntExist' not found on type Dog"
  expect { reflection types fields getScopeCode $(safeName MyMap[K,V]) doesntExist } toFail "Field 'doesntExist' not found on type MyMap[K,V]"
  expect { reflection types fields getScopeCode DoesntExist doesntExist } toFail "Type 'DoesntExist' not found"
}

@spec.reflection.types.fields.getScopeCode.as_variable() {
  local var
  expect "$var" toBeEmpty

  expect { reflection types fields getScopeCode Dog name var } toBeEmpty

  expect "$var" toEqual i
}
