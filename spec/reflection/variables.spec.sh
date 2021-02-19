source teascript.sh

# Update a bit so that value is 1 field and its renamed 'representation' because it
# can be one of: literal value string, object id reference, or field lookup for a struct where values are kept in expanded variable array slots :)
# STACK vs HEAP -> easier copying and match the expectation that struct/value type allocation is cheaper

@spec.create_variables_and_get_their_type_value_and_object_reference_Ids() {
  expect { reflection variables list } not toContain "myVar"

  reflection variables set myVar TEXT "value of a value type variable"
  expect { reflection variables list } toContain "myVar"
  expect { reflection variables getType myVar } toEqual TEXT
  expect { reflection variables getValue myVar } toEqual "value of a value type variable"
  expect { reflection variables getObjectId myVar } toEqual ""

  reflection variables set myString String "" "abc123-my-object-id"
  expect { reflection variables list } toContain "myString"
  expect { reflection variables getType myString } toEqual String
  expect { reflection variables getValue myString } toEqual ""
  expect { reflection variables getObjectId myString } toEqual "abc123-my-object-id"

  reflection variables unset myVar
  expect { reflection variables list } not toContain "myVar"
  expect { reflection variables list } toContain "myString"

  reflection variables unset myString
  expect { reflection variables list } not toContain "myVar"
  expect { reflection variables list } not toContain "myString"
}