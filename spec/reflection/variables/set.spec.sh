@spec.reflection.variables.set() {
  expect { reflection variables list } toBeEmpty

  reflection variables set foo r Dog "<the object ID here>"
  expect { reflection variables list } toContain "foo\tbyref\tDog\t<the object ID here>"

  reflection variables set bar v Integer 42
  expect { reflection variables list } toContain "bar\tbyval\tInteger\t42"

  reflection variables set baz n "" foo
  expect { reflection variables list } toContain "baz\tnameref\t\tfoo"
}