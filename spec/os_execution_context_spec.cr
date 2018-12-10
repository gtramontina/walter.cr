require "minitest/autorun"
require "./doubles/bad_os_process"
require "walter/os_execution_context"

describe Walter::OSExecutionContext do
  describe "when the command executes successfully" do
    it "returns what was sent to stdout" do
      OSExecutionContext.new.execute("echo foo").unwrap.must_equal("foo\n")
      OSExecutionContext.new.execute("printf", ["foo"]).unwrap.must_equal("foo")
      OSExecutionContext.new.execute("echo a more convoluted example | grep -o convoluted").unwrap.must_equal("convoluted\n")
      OSExecutionContext.new.execute("$(which crystal) --help").unwrap.must_match(/Usage: crystal/)
    end
  end

  describe "when the command fails to execute" do
    it "results on what was sent to stderr" do
      Result.match(OSExecutionContext.new.execute("this-command-does-not-exist"), {
        [Ok, output] => flunk("Should have failed"),
        [Err, error] => error.must_match(/not found/),
      })

      Result.match(OSExecutionContext.new.execute("echo boo | this-command-does-not-exist"), {
        [Ok, output] => flunk("Should have failed"),
        [Err, error] => error.must_match(/not found/),
      })

      Result.match(OSExecutionContext.new(Doubles::BadOSProcess.new).execute("anything"), {
        [Ok, output] => flunk("Should have failed"),
        [Err, error] => error.to_s.must_equal("borked!"),
      })
    end

    it "results on what was sent to stdout" do
      Result.match(OSExecutionContext.new.execute("this-command-does-not-exist 2>&1"), {
        [Ok, output] => flunk("Should have failed"),
        [Err, error] => error.must_match(/not found/),
      })
    end
  end
end
