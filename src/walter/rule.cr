require "crz"
require "./interfaces/rule"
require "./command"

class Walter::Rule
  include Interfaces::Rule
  @expression : Regex
  @commands : Array(Command)

  private OK = Result(String, String).of("")

  def initialize(expression, command : Command)
    initialize(expression, [command])
  end

  def initialize(@expression, @commands); end

  def apply(files, context)
    files.list.map(&.grep(@expression)).bind do |paths|
      paths.reduce(OK) do |result, path|
        result.bind { run_commands_for_path(path, context) }
      end
    end
  end

  private def run_commands_for_path(path, context)
    @commands.reduce(OK) do |result, command|
      result.bind { command.add_arguments([path]).run(context) }
    end
  end

  def ==(other : Rule)
    other.same_expression?(@expression) && other.same_commands?(@commands)
  end

  def to_s
    @expression.source.to_s
  end

  protected def same_expression?(expression)
    @expression == expression
  end

  protected def same_commands?(commands)
    @commands == commands
  end
end
