class Dog do
  def bark
  param int loudness = 5 : Specifies how loudly the dog barks
end

class MyMap[K,V] do
  def add
  param K out key
  param V ref value
end

@spec.reflection.types.methods.params.getModifierCode() {
  expect { reflection types methods params getModifierCode Dog bark loudness } toEqual v
  expect { reflection types methods params getModifierCode $(safeName MyMap[K,V]) add key } toEqual o
  expect { reflection types methods params getModifierCode $(safeName MyMap[K,V]) add value } toEqual r
}

@spec.reflection.types.methods.params.getModifierCode.field_or_type_doesnt_exist() {
  expect { reflection types methods params getModifierCode DoesntExist doesntExist foo } toFail "Type 'DoesntExist' not found"
  expect { reflection types methods params getModifierCode Dog doesntExist foo } toFail "Method 'doesntExist' not found on type Dog"
  expect { reflection types methods params getModifierCode $(safeName MyMap[K,V]) add doesntExist } toFail "Parameter 'doesntExist' not found on method MyMap[K,V].add"
}

@spec.reflection.types.methods.params.getModifierCode.as_variable() {
  local var
  expect "$var" toBeEmpty

  expect { reflection types methods params getModifierCode Dog bark loudness var } toBeEmpty

  expect "$var" toEqual v
}
