@spec.reflection.fields.define() {
  reflection types define Dog c

  refute reflection types fields exists Dog name

  reflection types fields define Dog name String i P "Rover" "This represents the dog name"
  reflection types fields define Dog age Integer i P
  reflection types fields define Dog another Foo i P

  assert reflection types fields exists Dog name

  expect { reflection types fields getType Dog name } toEqual String

  expect { reflection types fields getDefaultValue Dog name } toEqual "Rover"

  expect { reflection types fields getComment Dog name } toEqual "This represents the dog name"

  expect { reflection types fields getVisibility Dog name } toEqual public
  expect { reflection types fields getVisibilityCode Dog name } toEqual P

  expect { reflection types fields getScope Dog name } toEqual instance
  expect { reflection types fields getScopeCode Dog name } toEqual i
}