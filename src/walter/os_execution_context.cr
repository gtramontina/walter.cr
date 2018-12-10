require "crz"
require "./interfaces/os_process"
require "./interfaces/execution_context"
require "./os_process"

class Walter::OSExecutionContext
  include Interfaces::ExecutionContext
  @process : Interfaces::OSProcess

  def initialize(@process = OSProcess.new); end

  def execute(command : String) : Result
    stdout = stderr = IO::Memory.new
    status = @process.run(command, output: stdout, error: stderr)
    status.success? ? Result(String, String).of(stdout.to_s) : Result::Err(String, String).new(stderr.to_s)
  rescue exception
    Result::Err(String, String).new(exception.to_s)
  end

  def execute(command : String, arguments : Array(String)) : Result
    execute("#{command} #{arguments.join(" ")}")
  end
end
