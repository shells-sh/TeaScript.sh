@spec.reflection.variables.isReferenceType() {
  reflection variables set foo v Integer 42
  reflection variables set bar r String "Hello, world!"
  reflection variables set baz n "" foo

  refute reflection variables isReferenceType foo
  assert reflection variables isReferenceType bar
  refute reflection variables isReferenceType baz
}