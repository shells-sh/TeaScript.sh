source teascript.sh

@pending.create_requires_a_type() {
  :
}

# def something and something too <<- _
#   And this is 
#   a description of the method :)
# _
@spec.create_and_dispose_of_object() {
  expect { reflection objects list } toBeEmpty

  run { reflection objects create Dog }
  local objectId="$STDOUT"

  expect { reflection objects list } toContain "Dog"
  expect { reflection objects list } toEqual "T_OBJECT_$objectId=([0]=\"Dog\" [1]=\"\")"

  reflection objects dispose "$objectId"

  expect { reflection objects list } not toContain "Dog"
}

@pending.get_field_requires_existing_object() {
  :
}

@pending.get_field_requires_field_name() {
  :
}

@pending.set_field_requires_existing_object() {
  :
}

@pending.set_field_requires_field_name_and_value() {
  :
}

@spec.get_and_set_object_fields() {
  run { reflection objects create Dog }
  local objectId="$STDOUT"
  
  expect { reflection objects show "$objectId" } not toContain "name" "Rover"
  expect { reflection objects show "$objectId" } toEqual "T_OBJECT_$objectId=([0]=\"Dog\" [1]=\"\")"
  expect { reflection objects getField "$objectId" name } toBeEmpty

  reflection objects setField "$objectId" name "Rover"

  expect { reflection objects show "$objectId" } toContain "name" "Rover"
  expect { reflection objects getField "$objectId" name } toEqual "Rover"
  expect { reflection objects show "$objectId" } toEqual "T_OBJECT_$objectId=([0]=\"Dog\" [1]=\";name:2\" [2]=\"Rover\")"

  reflection objects setField "$objectId" name "Spot"

  expect { reflection objects show "$objectId" } not toContain "Rover"
  expect { reflection objects show "$objectId" } toContain "name" "Spot"
  expect { reflection objects getField "$objectId" name } toEqual "Spot"
  expect { reflection objects show "$objectId" } toEqual "T_OBJECT_$objectId=([0]=\"Dog\" [1]=\";name:2\" [2]=\"Spot\")"

  reflection objects setField "$objectId" breed "Golden Retriever"
  expect { reflection objects show "$objectId" } toEqual "T_OBJECT_$objectId=([0]=\"Dog\" [1]=\";name:2;breed:3\" [2]=\"Spot\" [3]=\"Golden Retriever\")"
}