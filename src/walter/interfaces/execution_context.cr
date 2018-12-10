require "crz"

module Walter::Interfaces::ExecutionContext
  abstract def execute(command : String, arguments : Array(String)) : Result(String, String)
  abstract def execute(command : String) : Result(String, String)
end
