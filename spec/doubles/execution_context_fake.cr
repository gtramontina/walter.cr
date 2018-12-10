require "crz"
require "walter/interfaces/execution_context"

class Walter::Doubles::ExecutionContextFake
  include Interfaces::ExecutionContext
  getter :executed_commands

  def initialize(@expected_commands : Hash(String, Result(String, String)) = Hash(String, Result(String, String)).new)
    @executed_commands = [] of String
  end

  def execute(command : String, arguments : Array(String) = [] of String)
    @executed_commands << (line = "#{command} #{arguments.join(' ')}")
    @expected_commands.has_key?(line) ? @expected_commands[line] : default_result(line)
  end

  private def default_result(line)
    Result(String, String).of("Command '#{line}' output: OK!")
  end
end
