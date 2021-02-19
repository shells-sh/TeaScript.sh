# Add a note on type of whether it supports literals? or check for method?

# Also, whether the Storage Type is a: literal, object ID, OR fields (for struct)

# Add ability to mark it as abstract vs concrete/class which are class types specifically

# Get to these later:
# - Nullable? <-- variable specific or part of the type itself? var/field/param specific
# - Generics? <-- this is part of the type name, need T (et al) for methods and fields to be able to use as a type(s) :)

@pending.define_and_delete_types() {
  expect { reflection types list } not toContain "Dog"

  reflection types define class Dog object "This represents a dog"
  expect { reflection types list } toContain "Dog"
  expect { reflection types getTypeOfType Dog } toEqual "class"
  expect { reflection types getTypeComment Dog } toEqual "This represents a dog"

  reflection types undefine Dog
  expect { reflection types list } not toContain "Dog"
}

@pending.can_define_types_as_value_types_or_with_literal_support() {
  reflection types define class Animal object
  expect { reflection types getTypeStorageType Animal } toEqual object

  reflection types define class AnimalName value
  expect { reflection types getTypeStorageType AnimalName } toEqual value
}

@pending.can_set_type_base_class_and_or_implemented_interface() {
  reflection types define class Animal object
  expect { reflection types getTypeBaseClass Animal } toEqual ""
  expect { reflection types getTypeInterface Animal } toEqual ""

  reflection types define interface IAnimal object
  expect { reflection types getTypeBaseClass IAnimal } toEqual ""
  expect { reflection types getTypeInterface IAnimal } toEqual ""

  reflection types define class Dog object "" Animal
  expect { reflection types getTypeBaseClass Dog } toEqual "Animal"
  expect { reflection types getTypeInterface Dog } toEqual ""

  reflection types define class Cat object "" "" IAnimal
  expect { reflection types getTypeBaseClass Cat } toEqual ""
  expect { reflection types getTypeInterface Cat } toEqual "IAnimal"
  expect { reflection types getTypeComment Cat } toEqual ""

  reflection types define class Bird object "Represents a bird" Animal IAnimal
  expect { reflection types getTypeBaseClass Bird } toEqual "Animal"
  expect { reflection types getTypeInterface Bird } toEqual "IAnimal"
  expect { reflection types getTypeComment Bird } toEqual "Represents a bird"
}

@pending.can_define_properties_of_a_defined_field() {
  reflection types define class Dog object
  
  reflection types addField Dog instance public name String "Rover" ""

  reflection types addField Dog static private age Integer "" "This is the dog age"

  expect { reflection types getFieldType Dog name } toEqual String
  expect { reflection types getFieldVisibility Dog name } toEqual public
  expect { reflection types getFieldDefaultValue Dog name } toEqual "Rover"
  expect { reflection types getFieldComment Dog name } toEqual ""
  expect { reflection types getFieldScope Dog name } toEqual instance

  expect { reflection types getFieldType Dog age } toEqual Integer
  expect { reflection types getFieldVisibility Dog age } toEqual private
  expect { reflection types getFieldDefaultValue Dog age } toEqual ""
  expect { reflection types getFieldComment Dog age } toEqual "This is the dog age"
  expect { reflection types getFieldScope Dog age } toEqual static
}

@pending.can_define_method_with_parameters_and_return_type() {
  reflection types define class Dog object

  reflection types addMethod Dog static public bark String "This says 'Woof!'"

  expect { reflection types getMethodVisibility Dog bark } toEqual public
  expect { reflection types getMethodScope Dog bark } toEqual static
  expect { reflection types getMethodReturnType Dog bark } toEqual String
  expect { reflection types getMethodComment Dog bark } toEqual "This says 'Woof!'"
  expect { reflection types getMethodParamNames Dog bark } toEqual ""

  reflection types addMethod Dog instance private setName void "" name String

  expect { reflection types getMethodVisibility Dog setName } toEqual private
  expect { reflection types getMethodScope Dog setName } toEqual instance
  expect { reflection types getMethodReturnType Dog setName } toEqual void
  expect { reflection types getMethodComment Dog setName } toEqual ""
  expect { reflection types getMethodParamNames Dog setName } toEqual "name"
  expect { reflection types getMethodParamType Dog setName name } toEqual String

  reflection types addMethod Dog instance public setNameAndAge void "Sets both the name and age" name String "Rover" age Integer ""

  expect { reflection types getMethodVisibility Dog setNameAndAge } toEqual public
  expect { reflection types getMethodScope Dog setNameAndAge } toEqual instance
  expect { reflection types getMethodReturnType Dog setNameAndAge } toEqual void
  expect { reflection types getMethodComment Dog setNameAndAge } toEqual "Sets both the name and age"
  expect { reflection types getMethodParamNames Dog setNameAndAge } toEqual "name age"
  expect { reflection types getMethodParamType Dog setNameAndAge name } toEqual String
  expect { reflection types getMethodParamDefaultValue Dog setNameAndAge name } toEqual "Rover"
  expect { reflection types getMethodParamType Dog setNameAndAge age } toEqual Integer
  expect { reflection types getMethodParamDefaultValue Dog setNameAndAge age } toEqual ""
}
