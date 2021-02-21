@spec.reflection.types.undefine() {
  refute reflection types exists Dog

  reflection types define Dog c "" "" "This represents a dog"
  assert reflection types exists Dog

  reflection types undefine Dog
  refute reflection types exists Dog

  refute reflection types exists MyMap[K,V]

  reflection types define MyMap[K,V] c "" "" "This represents a dog"
  assert reflection types exists MyMap[K,V]

  reflection types undefine MyMap[K,V]
  refute reflection types exists MyMap[K,V]
}