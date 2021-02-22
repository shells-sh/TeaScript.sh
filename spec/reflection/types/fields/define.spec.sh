@pending.reflection.fields.define() {
  refute reflection types fields exists Dog name

  reflection types fields define Dog name P i String "This represents the dog name"

  assert reflection types fields exists Dog name

  # expect { reflection types fields getType Dog name } toEqual String

  # expect { reflection types fields getDefaultValue Dog name } toEqual "Rover"

  # expect { reflection types fields getComment Dog name } toEqual "This represents the dog name"

  # expect { reflection types fields getVisibility Dog name } toEqual public
  # expect { reflection types fields getVisibilityCode Dog name } toEqual P

  # expect { reflection types fields getScope Dog name } toEqual instance
  # expect { reflection types fields getScopeCode Dog name } toEqual i
}