class Dog do
  field name = "Rover"
  public field int age
  private field Array[Dog] siblings
end

class MyMap[K,V] do
  field count = 5
  public field items
end

@spec.reflection.types.fields.listNames() {
  expect { reflection types fields listNames Dog } toEqual "name age siblings"
  expect { reflection types fields listNames $(safeName MyMap[K,V]) } toEqual "count items"
}

@spec.reflection.types.fields.listNames.field_or_type_doesnt_exist() {
  expect { reflection types fields listNames DoesntExist doesntExist } toFail "Type 'DoesntExist' not found"
}

@spec.reflection.types.fields.listNames.as_variable() {
  local var
  expect "$var" toBeEmpty

  expect { reflection types fields listNames Dog var } toBeEmpty

  expect "$var" toEqual "name age siblings"
}
