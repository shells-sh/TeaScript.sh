@spec.reflection.variables.unset() {
  refute reflection variables exists foo # it will return a non-zero status code

  reflection variables set foo r String "Hello, world!"

  assert reflection variables exists foo

  reflection variables unset foo

  refute reflection variables exists foo
}