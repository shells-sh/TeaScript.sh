source teascript.sh

safeName() {
  reflection safeName "$@"
}

printRawTypes() {
  ( set -o posix ; set ) | grep "^T_TYPE_"
}