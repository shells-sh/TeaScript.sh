@spec.def.without_type_do_scope() {
  refute reflection types methods exists Dog bark

  class Dog

  def Dog.bark

  assert reflection types methods exists Dog bark
}

@spec.def.with_type_do_scope.implicit() {
  refute reflection types methods exists Dog bark

  class Dog do
    def bark
  end

  assert reflection types methods exists Dog bark
}

@spec.def.with_type_do_scope.explicit() {
  class Dog

  refute reflection types methods exists Dog bark

  class Cat do
    def Dog.bark
  end

  assert reflection types methods exists Dog bark
  refute reflection types methods exists Cat bark
}

@pending.def.error_if_implicit_type_but_no_open_do_scope() {
  :
}

@pending.def.error_if_method_already_exists() {
  :
}