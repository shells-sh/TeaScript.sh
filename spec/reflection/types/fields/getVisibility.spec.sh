class Dog do
  field name = "Rover"
  public field int age
  private field Array[Dog] siblings
end

class MyMap[K,V] do
  field count = 5
  public field items
end

@spec.reflection.types.fields.getVisibility() {
  expect { reflection types fields getVisibility Dog name } toEqual private # field default
  expect { reflection types fields getVisibility Dog age } toEqual public
  expect { reflection types fields getVisibility Dog siblings } toEqual private
  expect { reflection types fields getVisibility $(safeName MyMap[K,V]) count } toEqual private
  expect { reflection types fields getVisibility $(safeName MyMap[K,V]) items } toEqual public
}

@spec.reflection.types.fields.getVisibility.field_or_type_doesnt_exist() {
  expect { reflection types fields getVisibility Dog doesntExist } toFail "Field 'doesntExist' not found on type Dog"
  expect { reflection types fields getVisibility $(safeName MyMap[K,V]) doesntExist } toFail "Field 'doesntExist' not found on type MyMap[K,V]"
  expect { reflection types fields getVisibility DoesntExist doesntExist } toFail "Type 'DoesntExist' not found"
}

@spec.reflection.types.fields.getVisibility.as_variable() {
  local var
  expect "$var" toBeEmpty

  expect { reflection types fields getVisibility Dog age var } toBeEmpty

  expect "$var" toEqual public
}
