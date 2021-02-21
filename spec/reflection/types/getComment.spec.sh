@spec.reflection.types.getComment.does_not_collide_with_anything_if_comment_has_all_the_special_character_separators() {
  define -a crazyCommentStrings
  crazyCommentStrings+=("|Hello|<World>;I'm using tons of & characters and Whatnot.|><")
  crazyCommentStrings+=(";Foo;Foo|bar|bar&this_[foo]ish")
  crazyCommentStrings+=("[Hello];World|From the comment[string]&whatnot")

  local commentString
  for commentString in "${crazyCommentStrings[@]}"
  do
    reflection types define MyCollectionOfThings[A,B,C] c Object IAnimal,ICritter "$commentString"
    expect { reflection types getComment MyCollectionOfThings[A,B,C] } toEqual "$commentString"
    expect { reflection types getBaseType MyCollectionOfThings[A,B,C] } toEqual MyCollectionOfThings
    expect { reflection types getBaseClass MyCollectionOfThings[A,B,C] } toEqual Object
    expect { reflection types getInterfaces MyCollectionOfThings[A,B,C] } toEqual "IAnimal ICritter"
    expect { reflection types getDescriptorCode MyCollectionOfThings[A,B,C] } toEqual c
    expect { reflection types getDescriptorName MyCollectionOfThings[A,B,C] } toEqual class
    expect { reflection types getGenericTypes MyCollectionOfThings[A,B,C] } toEqual "A B C"
    reflection types undefine Dog
  done
}

@spec.reflection.types.getComment.does_not_store_comment_if_disabled() {
  reflection types define Dog c "" "" "This represents a dog"
  expect { reflection types getComment Dog } toEqual "This represents a dog"

  local T_COMMENTS=disabled

  reflection types define Cat c "" "" "This represents a dog"
  expect { reflection types getComment Cat } toBeEmpty
}