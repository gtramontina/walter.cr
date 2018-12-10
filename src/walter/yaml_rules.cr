require "yaml"
require "./rule"

class Walter::YAMLRules
  alias RawRule = Hash(String, (String | Array(String)))
  @rules : String

  def initialize(@rules); end

  def as_rules
    as_rules((RawRule | Array(RawRule)).from_yaml(@rules))
  rescue YAML::ParseException
    raise ParsingError.new
  end

  private def as_rules(raw_rule : RawRule)
    as_rules([raw_rule])
  end

  private def as_rules(raw_rules : Array(RawRule))
    raw_rules.map do |raw_rule|
      Rule.new(as_expression(raw_rule["expression"]), as_commands(raw_rule["command"]))
    end
  end

  private def as_expression(raw_expression : String)
    Regex.new(raw_expression)
  end

  private def as_expression(raw_expressions : Array(String))
    Regex.union(raw_expressions.map { |e| as_expression(e) })
  end

  private def as_commands(raw_command : String)
    as_commands([raw_command])
  end

  private def as_commands(raw_commands : Array(String))
    raw_commands.map { |raw_command| Command.new(raw_command) }
  end

  class ParsingError < Exception
    protected def initialize
      super("Could not parse the given rules. Please refer to the documentation for the expected format.")
    end
  end
end
