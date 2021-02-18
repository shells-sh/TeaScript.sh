source teascript.sh

@spec.define_and_delete_types() {
  expect { reflection types list } not toContain "Dog"

  reflection types define class Dog

  expect { reflection types list } toContain "Dog"

  reflection types delete Dog

  expect { reflection types list } not toContain "Dog"
}

@spec.can_define_properties_of_a_defined_field() {
  reflection types define class Dog
  expect { reflection types show Dog } toEqual 'T_TYPE_Dog=([0]="Dog" [1]="class" [2]="" [3]="" [4]="" [5]="" [6]="")'
  
  reflection types addField Dog public name String "Rover" ""
  expect { reflection types show Dog } toEqual 'T_TYPE_Dog=([0]="Dog" [1]="class" [2]="" [3]="" [4]="" [5]=";name:7" [6]="" [7]="public|name<String>Rover&")'

  reflection types addField Dog private age Integer "" "This is the dog age"
  expect { reflection types show Dog } toEqual 'T_TYPE_Dog=([0]="Dog" [1]="class" [2]="" [3]="" [4]="" [5]=";name:7;age:8" [6]="" [7]="public|name<String>Rover&" [8]="private|age<Integer>&This is the dog age")'

  expect { reflection types getFieldType Dog name } toEqual String
  expect { reflection types getFieldVisibility Dog name } toEqual public
  expect { reflection types getFieldDefaultValue Dog name } toEqual "Rover"
  expect { reflection types getFieldComment Dog name } toEqual ""

  expect { reflection types getFieldType Dog age } toEqual Integer
  expect { reflection types getFieldVisibility Dog age } toEqual private
  expect { reflection types getFieldDefaultValue Dog age } toEqual ""
  expect { reflection types getFieldComment Dog age } toEqual "This is the dog age"
}

@spec.can_define_method_with_parameters_and_return_type() {
  reflection types define class Dog
  expect { reflection types show Dog } toEqual 'T_TYPE_Dog=([0]="Dog" [1]="class" [2]="" [3]="" [4]="" [5]="" [6]="")'

  reflection types addMethod Dog public bark String "This says 'Woof!'"

  expect { reflection types getMethodVisibility Dog bark } toEqual public
  expect { reflection types getMethodReturnType Dog bark } toEqual String
  expect { reflection types getMethodComment Dog bark } toEqual "This says 'Woof!'"
  expect { reflection types getMethodParamNames Dog bark } toEqual ""

  reflection types addMethod Dog private setName void "" name String

  expect { reflection types getMethodVisibility Dog setName } toEqual private
  expect { reflection types getMethodReturnType Dog setName } toEqual void
  expect { reflection types getMethodComment Dog setName } toEqual ""
  expect { reflection types getMethodParamNames Dog setName } toEqual "name"
  expect { reflection types getMethodParamType Dog setName name } toEqual String

  reflection types addMethod Dog public setNameAndAge void "Sets both the name and age" name String "Rover" age Integer ""

  expect { reflection types getMethodVisibility Dog setNameAndAge } toEqual public
  expect { reflection types getMethodReturnType Dog setNameAndAge } toEqual void
  expect { reflection types getMethodComment Dog setNameAndAge } toEqual "Sets both the name and age"
  expect { reflection types getMethodParamNames Dog setNameAndAge } toEqual "name age"
  expect { reflection types getMethodParamType Dog setNameAndAge name } toEqual String
  expect { reflection types getMethodParamDefaultValue Dog setNameAndAge name } toEqual "Rover"
  expect { reflection types getMethodParamType Dog setNameAndAge age } toEqual Integer
  expect { reflection types getMethodParamDefaultValue Dog setNameAndAge age } toEqual ""
}
