require "colorize"
require "spinner-frames"
require "griffith"

class Walter::Reporter
  @task : (Task | Task::Null) = Task::Null.new
  @then : Time = Time.now

  def before_lint(rules)
    @then = Time.now
  end

  def before_rule(rule)
    @task = Task.new(Griffith.create_task("Running commands for #{rule.to_s.colorize.yellow.to_s}:"))
    @task.start_spinning
  end

  def before_files
    @task.details("Matching staged files…")
  end

  def before_execution_context(command, arguments = [] of String)
    @task.details("#{command} #{arguments.join(' ')}")
  end

  def on_execution_context_success(output); end

  def on_execution_context_failure(output); end

  def on_files_success(output); end

  def on_files_failure(output); end

  def after_files; end

  def after_execution_context(command, arguments = [] of String); end

  def on_rule_success(output)
    @task.done("Done!")
  end

  def on_rule_failure(output)
    @task.fail(output)
  end

  def after_rule(rule); end

  def on_lint_success(output)
    puts "✨  All good! #{time_elapsed}"
  end

  def on_lint_failure(output)
    puts "💥  Something went wrong! #{time_elapsed}"
  end

  def after_lint; end

  private def time_elapsed
    "(#{(Time.now - @then).total_milliseconds}ms)".colorize.dark_gray.to_s
  end

  # ---

  private class WalterReporter < Griffith::ConsoleReporter
    private def render(task)
      "%s %s %s" % [task.status_message, task.description, task.details]
    end
  end

  private class Task
    Griffith.config do |c|
      c.reporter = WalterReporter.new
      c.done_message = "✓ ".colorize.green.to_s
      c.fail_message = "✗ ".colorize.red.to_s
    end

    def initialize(@task : Griffith::Task)
      @done = true
    end

    def start_spinning
      @done = false
      spawn { spin(SpinnerFrames.new(SpinnerFrames::Charset[:dots12])) }
    end

    private def stop_spinning
      @done = true
    end

    private def spin(spinner)
      until @done
        @task.running(spinner.next.colorize.blue.to_s)
        sleep 0.05
      end
    end

    def done(output)
      stop_spinning
      details(output).done
    end

    def fail(output)
      stop_spinning
      @task.fail.details('\n' + output)
    end

    def details(message)
      @task.details(truncate(message.colorize.blue.to_s, 50))
    end

    private def truncate(string, max)
      string.size > max ? "#{string[0...(max - 1)]}…" : string
    end

    class Null
      def start_spinning; end

      def fail(output); end

      def done(output); end

      def details(message); end
    end
  end
end
