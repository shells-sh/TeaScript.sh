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
enum ServerStatus { ACTIVE MAINTENANCE REBOOTING }

fn verifyServer(int serverNumber, ServerStatus expectedStatus) bool
verifyServer() {
  run servers stat | grep "^Server {{serverNumber}}" | grep "{{expectedStatus}}"
}
```
> _# Example which wraps the return value of the shell script in a strongly typed object_  
> _# and adds business logic into static and instance methods:_

```sh
struct Server {
  enum Status { ACTIVE MAINTENANCE REBOOTING }

  int number
  Status status
  
  static def getServers() : Get the current list of servers with status (via `servers stat`)
  returns List[Server] : The current list of servers
  Server.getServers() {
    run servers stat
    output map (line) do
      new Server number: line.match(/Server (\d+)/)[0].groups.first, status: line.match(/Status: (\w+)/)[0]
    end
  }
  
  def verify : Returns true if the server matches the expected status
  param int serverNumber : Identifier of server to verify
  param Status expectedStatus
  returns bool
  Server.verify() {
    var server = Server.getServers() getFirst (server) { server.number == serverNumber }
    returns server.status == expectedStatus
  }
}
```
