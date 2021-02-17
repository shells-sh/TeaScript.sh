source teascript.sh

@spec.create_variable_value_type() {
  # T_VAR_REF_
  # T_VAR_VAL_
  expect { reflection variables list } not toContain "myVar"

  reflect variables create myVar TEXT

  expect { reflection variables list } toContain "myVar"
}