class Dog do
  field name = "Rover"
  field age
end

class MyMap[K,V] do
  field count = 5
  field items
end

@spec.reflection.types.fields.getDefaultValue() {
  expect { reflection types fields getDefaultValue Dog name } toEqual "Rover"
  expect { reflection types fields getDefaultValue Dog age } toBeEmpty
  expect { reflection types fields getDefaultValue $(safeName MyMap[K,V]) count } toEqual "5"
  expect { reflection types fields getDefaultValue $(safeName MyMap[K,V]) items } toBeEmpty
}

@spec.reflection.types.fields.getDefaultValue.field_or_type_doesnt_exist() {
  expect { reflection types fields getDefaultValue Dog doesntExist } toFail "Field 'doesntExist' not found on type Dog"
  expect { reflection types fields getDefaultValue $(safeName MyMap[K,V]) doesntExist } toFail "Field 'doesntExist' not found on type MyMap[K,V]"
  expect { reflection types fields getDefaultValue DoesntExist doesntExist } toFail "Type 'DoesntExist' not found"
}

@spec.reflection.types.fields.getDefaultValue.as_variable() {
  local var
  expect "$var" toBeEmpty

  expect { reflection types fields getDefaultValue Dog name var } toBeEmpty

  expect "$var" toEqual "Rover"
}
