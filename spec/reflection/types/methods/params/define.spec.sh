class Dog do
  def bark
end

class MyMap[K,V] do
  def add[T]
end

@spec.reflection.types.methods.params.define.add_to_method_without_existing_param() {
  assert reflection types methods exists Dog bark
  refute reflection types methods params exists Dog bark loudness
  # expect { reflection types methods params getCount Dog bark } toEqual 0

  reflection types methods params define Dog bark loudness int v 4 "Specifies how loudly the dog barks"

  assert reflection types methods params exists Dog bark loudness
  # expect { reflection types methods params getCount Dog bark } toEqual 1
}

@param.reflection.types.methods.params.define.add_to_method_with_existing_params() {
  :
}