class() {
  # class -- [Internal Class API]
  # if [ "$1" = "--" ]
  # then
  #   case "$2" in
  #     alloc)
  #       :
  #       ;;
  #     dealloc)
  #       :
  #       ;;
  #     invoke)
  #       :
  #       ;;
  #     setField)
  #       :
  #       ;;
  #     getField)
  #       :
  #       ;;
  #   esac
  # fi

  local __T_className="$1"; shift

  reflection types define "$__T_className" c

  [ "$1" = "do" ] && T_DO="$__T_className"
}


# TODO
# abstract() { T_ABSTRACT=true; }