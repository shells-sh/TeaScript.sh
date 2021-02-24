class Dog do
  field name = "Rover"
  public field int age
  private field Array[Dog] siblings
end

class MyMap[K,V] do
  field count = 5
  public field items
end

@spec.reflection.types.fields.getVisibilityCode() {
  expect { reflection types fields getVisibilityCode Dog name } toEqual p # field default
  expect { reflection types fields getVisibilityCode Dog age } toEqual P
  expect { reflection types fields getVisibilityCode Dog siblings } toEqual p
  expect { reflection types fields getVisibilityCode $(safeName MyMap[K,V]) count } toEqual p
  expect { reflection types fields getVisibilityCode $(safeName MyMap[K,V]) items } toEqual P
}

@spec.reflection.types.fields.getVisibilityCode.field_or_type_doesnt_exist() {
  expect { reflection types fields getVisibilityCode Dog doesntExist } toFail "Field 'doesntExist' not found on type Dog"
  expect { reflection types fields getVisibilityCode $(safeName MyMap[K,V]) doesntExist } toFail "Field 'doesntExist' not found on type MyMap[K,V]"
  expect { reflection types fields getVisibilityCode DoesntExist doesntExist } toFail "Type 'DoesntExist' not found"
}

@spec.reflection.types.fields.getVisibilityCode.as_variable() {
  local var
  expect "$var" toBeEmpty

  expect { reflection types fields getVisibilityCode Dog age var } toBeEmpty

  expect "$var" toEqual P
}
