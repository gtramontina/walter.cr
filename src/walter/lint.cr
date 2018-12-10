require "./interfaces/lint"
require "./interfaces/rule"
require "./interfaces/files"
require "./interfaces/execution_context"

class Walter::Lint
  include Interfaces::Lint
  @files : Interfaces::Files
  @context : Interfaces::ExecutionContext

  private OK = Result(String, String).of("Skipped")

  def initialize(@files, @context); end

  def apply(rules : Array(Interfaces::Rule))
    rules.reduce(OK) do |result, rule|
      result.bind { rule.apply(@files, @context) }
    end
  end
end
