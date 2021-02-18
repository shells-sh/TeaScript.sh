source teascript.sh

@pending.can_create_a_TEXT_variable_and_get_its_type() {
  TEXT hello = "hello"

  expect { typeof hello } toEqual TEXT
}

@pending.can_change_the_value_of_a_TEXT_variable() {
  :
}