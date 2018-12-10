require "crz"
require "./interfaces/command"

class Walter::Command
  include Interfaces::Command
  @command : String
  @arguments : Array(String)

  def initialize(@command, @arguments = [] of String); end

  def run(context : Interfaces::ExecutionContext) : Result(String, String)
    context.execute(@command, @arguments)
  end

  def add_arguments(arguments)
    Command.new(@command, arguments)
  end

  def ==(other : Command)
    other.same_command?(@command) && other.same_arguments?(@arguments)
  end

  protected def same_command?(command)
    @command == command
  end

  protected def same_arguments?(arguments)
    @arguments == arguments
  end
end
