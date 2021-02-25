@spec.field.without_type_do_scope() {
  class Dog
  class Cat
  expect { reflection types fields listNames Dog } toBeEmpty
  expect { reflection types fields listNames Cat } toBeEmpty

  field Dog.name

  expect { reflection types fields listNames Dog } toEqual "name"
  expect { reflection types fields listNames Cat } toBeEmpty
}

@spec.field.with_type_do_scope.explicit_type() {
  class Dog do
  refute reflection types fields exists Dog age

  field int age

  assert reflection types fields exists Dog age
  expect { reflection types fields getType Dog age } toEqual int
}

## TODO field MyMap[K,V].count - will probably fail, update field to use safeName

@pending.field.with_type_do_scope.explicit_target_type() {
  :
  # TODO do field Cat.age within Dog and make sure it works, I believe it's currently broken
  #
  # TODO rename specs and clarify 'type' being defined on and 'type' of the field
}

@spec.field.with_type_do_scope.implicit_type() {
  class Dog do
  refute reflection types fields exists Dog name

  field name

  assert reflection types fields exists Dog name
  expect { reflection types fields getType Dog name } toEqual string
}

@spec.field.error_if_implicit_type_but_no_open_do_scope() {
  class Dog

  refute reflection types fields exists Dog name

  refute field name

  refute reflection types fields exists Dog name
}

@pending.field.error_if_field_already_exists() {
  :
}

@spec.field.type() {
  class Dog do
  refute reflection types fields exists Dog name
  refute reflection types fields exists Dog age

  field string name
  field int age

  assert reflection types fields exists Dog name
  assert reflection types fields exists Dog age
  expect { reflection types fields getType Dog name } toEqual string
  expect { reflection types fields getType Dog age } toEqual int
}

@spec.field.type.generic() {
  class Dog do
  refute reflection types fields exists Dog siblings
  refute reflection types fields exists Dog toys

  field List[Dog] siblings
  field Map[string,Toy] toys

  assert reflection types fields exists Dog siblings
  assert reflection types fields exists Dog toys
  expect { reflection types fields getType Dog siblings } toEqual List[Dog]
  expect { reflection types fields getType Dog toys } toEqual Map[string,Toy]
}

@spec.field.type.default_is_string() {
  class Dog do
  refute reflection types fields exists Dog name

  field name

  assert reflection types fields exists Dog name
  expect { reflection types fields getType Dog name } toEqual string
}

@spec.field.visibility.default_is_private() {
  class Dog do

  field name

  expect { reflection types fields getVisibility Dog name } toEqual private
}

@spec.field.visibility.public() {
  class Dog do

  public field name

  expect { reflection types fields getVisibility Dog name } toEqual public
}

@spec.field.visibility.private() {
  class Dog do

  private field name

  expect { reflection types fields getVisibility Dog name } toEqual private
}

@spec.field.scope.default_is_instance() {
  class Dog do

  field name

  expect { reflection types fields getScope Dog name } toEqual instance
}

@spec.field.scope.static() {
  class Dog do

  static field name

  expect { reflection types fields getScope Dog name } toEqual static
}

@spec.field.comment() {
  T_COMMENTS=enabled

  class Dog do

  field name

  field int age : Represents the dog age

  field List[Dog] another : '
    Represents some other stuff
    and whatnot
    and yadda yadda yadda'

  expect { reflection types fields getComment Dog name } toBeEmpty
  expect { reflection types fields getComment Dog age } toEqual "Represents the dog age"
  expect { reflection types fields getComment Dog another } toContain "Represents some other stuff" "and whatnot" "and yadda yadda yadda"
}