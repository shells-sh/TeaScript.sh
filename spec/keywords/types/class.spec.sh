@spec.class.starts_a_new_type_definition_and_opens_class_for_modifications_if_do() {
  expect "$T_DO" toBeEmpty
  refute reflection types exists $(reflection safeName AnimalCollection[T])

  class AnimalCollection[T] do

  assert reflection types exists $(reflection safeName AnimalCollection[T])
  expect "$T_DO" toEqual AnimalCollection[T]
}

@spec.class.does_not_open_class_for_any_modification_without_do() {
  expect "$T_DO" toBeEmpty
  refute reflection types exists $(reflection safeName AnimalCollection[T])

  class AnimalCollection[T]

  assert reflection types exists $(reflection safeName AnimalCollection[T])
  expect "$T_DO" toBeEmpty
}

@pending.class.reopens_an_existing_new_type_definition_and_opens_class_for_modifications() {
  :
}

@pending.class.can_set_comment_of_new_class() {
  :
}

@pending.class.overrides_existing_comment() {
  :
}

@pending.class.can_set_baseclass() {
  :
}

@pending.class.overrides_existing_baseclass_already_set() {
  :
}

@pending.class.can_add_interface_implementations() {
  :
}

@pending.class.can_add_new_interface_implementations_when_reopened() {
  :
}

@pending.class.sets_generic_type_constraints() {
  :
}

@pending.class.overrides_existing_generic_type_constraints_if_already_set() {
  :
}