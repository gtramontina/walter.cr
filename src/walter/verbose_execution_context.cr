require "crz"
require "./interfaces/execution_context"
require "./reporter"

class Walter::VerboseExecutionContext
  include Interfaces::ExecutionContext
  @context : Interfaces::ExecutionContext
  @reporter : Reporter

  def initialize(@context, @reporter); end

  def execute(command : String)
    @reporter.before_execution_context(command)
    result = @context.execute(command)
    Result.match(result, {
      [Ok, output] => @reporter.on_execution_context_success(output),
      [Err, error] => @reporter.on_execution_context_failure(error),
    })
    @reporter.after_execution_context(command)
    result
  end

  def execute(command : String, arguments : Array(String))
    @reporter.before_execution_context(command, arguments)
    result = @context.execute(command, arguments)
    Result.match(result, {
      [Ok, output] => @reporter.on_execution_context_success(output),
      [Err, error] => @reporter.on_execution_context_failure(error),
    })
    @reporter.after_execution_context(command, arguments)
    result
  end
end
