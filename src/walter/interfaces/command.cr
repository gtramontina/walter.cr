require "crz"

module Walter::Interfaces::Command
  abstract def run(context : ExecutionContext) : Result(String, String)
  abstract def add_arguments(arguments) : Command
end
