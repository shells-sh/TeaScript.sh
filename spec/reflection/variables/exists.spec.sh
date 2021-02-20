@spec.reflection.variables.exists() {
  refute reflection variables exists foo # it will return a non-zero status code

  reflection variables set foo r String "Hello, world!"

  assert reflection variables exists foo
}