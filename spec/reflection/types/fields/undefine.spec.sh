@spec.reflection.fields.undefine() {
  reflection types define Dog c

  refute reflection types fields exists Dog name
  refute reflection types fields exists Dog age
  refute reflection types fields exists Dog another

  reflection types fields define Dog name String i P "Rover" "This represents the dog name"
  reflection types fields define Dog age Integer i P
  reflection types fields define Dog another Foo i P

  assert reflection types fields exists Dog name

  reflection types fields undefine Dog name

  refute reflection types fields exists Dog name
  assert reflection types fields exists Dog age
  assert reflection types fields exists Dog another

  reflection types fields undefine Dog age

  refute reflection types fields exists Dog name
  refute reflection types fields exists Dog age
  assert reflection types fields exists Dog another
}