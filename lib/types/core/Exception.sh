class Exception do << _
  Represents an error scenario in code.
  Can be thrown via the `throw` function.
  Can be caught via a `catch` defined function.
  If not catched, a thrown error will `stop` the TeaScript interpreter.
_

field message << _
  The exception message.
_

field sourceFile << _
  Path to the file the `Exception` was thrown from.
_

field sourceLine int << _
  Line of code in the `sourceFile` where the `Exception` was thrown.
_

field backtrace CallStack << _
  Copy of the TeaScript backtrace at the time the Exception was thrown.
_

def Exception
param message = "" 
Exception.init() {
  this message = params message
  this backtrace = Backtrace.current
  # "${FUNCNAME[1]}" "${BASH_LINENO[0]}
  # I could use the uniqueness of function names - IF we know the file too... trap is likely too chatty.
}

end