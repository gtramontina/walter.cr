require "./interfaces/rule"
require "./rule"
require "./reporter"
require "./verbose_files"
require "./verbose_execution_context"

class Walter::VerboseRule
  include Interfaces::Rule
  @rule : Interfaces::Rule
  @reporter : Reporter

  def initialize(@rule, @reporter); end

  def apply(files, context)
    @reporter.before_rule(@rule)
    result = @rule.apply(VerboseFiles.new(files, @reporter), VerboseExecutionContext.new(context, @reporter))
    Result.match(result, {
      [Ok, output] => @reporter.on_rule_success(output),
      [Err, error] => @reporter.on_rule_failure(error),
    })
    @reporter.after_rule(@rule)
    result
  end
end
