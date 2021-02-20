abstract() {
  T_ABSTRACT=true
}

class() {
  # class -- [Internal Class API]
  if [ "$1" = "--" ]
  then
    case "$2" in
      alloc)
        :
        ;;
      dealloc)
        :
        ;;
      invoke)
        :
        ;;
      setField)
        :
        ;;
      getField)
        :
        ;;
    esac
  fi

  # ...
  # if T_ABSTRACT
}