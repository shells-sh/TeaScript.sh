source teascript.sh

@spec.define_and_delete_types() {
  expect { reflection types list } not toContain "Dog"

  reflection types define class Dog

  expect { reflection types list } toContain "Dog"
  # expect { reflection types show Dog } toContain "T_TYPE_Dog=..."

  reflection types delete Dog

  expect { reflection types list } not toContain "Dog"
}

@spec.can_define_field_with_a_type() {
  reflection types define class Dog
  
  expect { reflection types show Dog } not toContain "name"
  expect { reflection types show Dog } toContain 'T_TYPE_Dog=([0]="Dog" [1]="class" [2]="" [3]="" [4]="" [5]="" [6]="")'

  reflection types addField Dog name String

  expect { reflection types show Dog } toContain "name" "String"
  expect { reflection types show Dog } toContain 'T_TYPE_Dog=([0]="Dog" [1]="class" [2]="" [3]="" [4]="" [5]=";name:7" [6]="" [7]="name<String>")'
}

@spec.can_get_properties_of_a_defined_field() {
  reflection types define class Dog
  reflection types addField Dog name String
  reflection types addField Dog age Integer
  
  expect { reflection types getFieldType Dog name } toEqual String
  expect { reflection types getFieldType Dog age } toEqual Integer
}

@pending.can_define_field_with_visibility_and_default_value_as_well() {
  :
}

@pending.can_define_method_with_parameters_and_return_type() {
  :
}

@pending.can_optionally_add_a_comment_to_type_and_method_and_field_declarations() {
  :
}