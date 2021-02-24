T_COMMENTS=enabled

class Dog do
  field name <<< "This represents a dog name!"
  field age
end

class MyMap[K,V] do
  field count <<< "The count of items"
  field items
end

@spec.reflection.types.fields.getComment() {
  expect { reflection types fields getComment Dog name } toEqual "This represents a dog name!"
  expect { reflection types fields getComment Dog age } toBeEmpty
  expect { reflection types fields getComment $(safeName MyMap[K,V]) count } toEqual "The count of items"
  expect { reflection types fields getComment $(safeName MyMap[K,V]) items } toBeEmpty
}

@spec.reflection.types.fields.getComment.field_or_type_doesnt_exist() {
  expect { reflection types fields getComment Dog doesntExist } toFail "Field 'doesntExist' not found on type Dog"
  expect { reflection types fields getComment $(safeName MyMap[K,V]) doesntExist } toFail "Field 'doesntExist' not found on type MyMap[K,V]"
  expect { reflection types fields getComment DoesntExist doesntExist } toFail "Type 'DoesntExist' not found"
}

@spec.reflection.types.fields.getComment.as_variable() {
  local var
  expect "$var" toBeEmpty

  expect { reflection types fields getComment Dog name var } toBeEmpty

  expect "$var" toEqual "This represents a dog name!"
}

@spec.reflection.types.fields.getComment.does_not_store_comment_if_disabled() {
  expect { reflection types fields getComment Dog name } toEqual "This represents a dog name!"
  refute reflection types fields getComment Cat name

  local T_COMMENTS=disabled

  class Cat do
    field name <<< "This represents a cat name!"
  end

 expect { reflection types fields getComment Dog name } toEqual "This represents a dog name!" # comments were enabled at the time
 expect { reflection types fields getComment Cat name } toBeEmpty # comment not added
}