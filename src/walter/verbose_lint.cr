require "./interfaces/lint"
require "./interfaces/rule"
require "./verbose_rule"
require "./reporter"

class Walter::VerboseLint
  include Interfaces::Lint
  @lint : Interfaces::Lint
  @reporter : Reporter

  def initialize(@lint, @reporter); end

  def apply(rules : Array(Interfaces::Rule))
    @reporter.before_lint(rules)
    result = @lint.apply(rules.map { |rule| VerboseRule.new(rule, @reporter) })
    Result.match(result, {
      [Ok, output] => @reporter.on_lint_success(output),
      [Err, error] => @reporter.on_lint_failure(error),
    })
    @reporter.after_lint
    result
  end
end
