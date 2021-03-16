> ℹ️ All of the content here is simply _aspirational_ - nothing to see here yet 👋

---

# 🍵 `TeaScript.sh`

> Strongly Typed Programming Langage
>
> _» Implemented on the BASH interpreter_

---

### Features

- _Strongly typed_
- _Generics_
- _Object-oriented_
- _Closures_
- _Async/Await_
- _Enumerable Support_
- _First class functions_
- _Primitives, Structs, and Classes_
- _Built-in API doc generation_
- _BASH command integration_
- _BASH function integration_

---

🍵 `TeaScript.sh` can either be authored from scratch or iteratively added to existing BASH scripts:

> _# Simple BASH script_

```sh
verifyServer() {
  local serverNumber="$1"
  local expectedStatus="$2"
  servers stat | grep "^Server $serverNumber" | grep "$expectedStatus"
}
```

> _# Example using TeaScript to add robustness and clarity to an existing BASH script:_

```sh
# Using the mini version of TeaScript which does not pollute your PATH
# and only adds one keyword: T
source teascript-T.sh

T enum ServerStatus { ACTIVE MAINTENANCE REBOOTING }

T fn verifyServer(int serverNumber, ServerStatus expectedStatus) bool
verifyServer() {
  local serverNumber="$( params serverNumber )"
  local expectedStatus="$( params expectedStatus )"
  T run servers stat | grep "^Server $serverNumber" | grep "$expectedStatus"
}

# Invoke via `call`:
T call verifyServer 42 ALIVE
# => [ArgumentError] Parameter expectedStatus. 'ALIVE' is not a valid 'ServerStatus' enum value.
```
> _# Example which wraps the return value of the shell script in a strongly typed object and_  
> _# adds business logic into static and instance methods (also using TeaScript functions):_

```sh
# Use the full version of TeaScript
# This is really all just regular ol' BASH!
source teascript.sh

struct Server do
  enum Status { ACTIVE MAINTENANCE REBOOTING }

  int number
  Status status
  
  static def getServers() List[Server] do
    var output = run servers stat
    returns output.lines.map (line) do
      var number = line.match(/Server (\d+)/)[0]
      var status = line.match(/Status: (\w+)/)[0]
      new Server :number :status
    end
  end
  
  static def getServer(int serverNumber) Server do
    returns getServers().first (server) { server.number == serverNumber }
  end
  
  def verifyServer(int serverNumber, Status expectedStatus) bool do
    returns getServer(serverNumber).status == expectedStatus
  end
end

# In a regular ol' BASH shell script elsewhere, invoke via `call`:
if call Server.verifyServer 42 ACTIVE
then
  echo "We found the answer to life, the universe, and everything!"
else
  echo "Uh oh, the server status was actually: $( call Server.getServer(42).status )"
fi
```
