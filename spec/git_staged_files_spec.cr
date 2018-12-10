require "minitest/autorun"
require "./doubles/execution_context_fake"
require "walter/git_staged_files"

describe Walter::GitStagedFiles do
  it "forwards any errors from the execution context when something goes wrong" do
    bad_execution_context = git_execution_context(Result::Err(String, String).new("halp!"))
    Result.match(GitStagedFiles.new(bad_execution_context).list, {
      [Ok, output] => flunk("Should have failed!"),
      [Err, error] => error.must_equal("halp!"),
    })
  end

  it "splits each line of the executed command into a stripped array" do
    assert_splits("", [] of String)
    assert_splits("a.txt", ["a.txt"])
    assert_splits("a.txt ", ["a.txt"])
    assert_splits(" a.txt ", ["a.txt"])
    assert_splits("a.txt\n", ["a.txt"])
    assert_splits("a.txt\r\n", ["a.txt"])
    assert_splits("a.txt\nb.txt", ["a.txt", "b.txt"])
    assert_splits("a.txt\n b.txt", ["a.txt", "b.txt"])
    assert_splits("a.txt \n b.txt", ["a.txt", "b.txt"])
    assert_splits("a.txt \r\n b.txt", ["a.txt", "b.txt"])
    assert_splits("a.txt \r\n b.txt\n\r\n c.jpg", ["a.txt", "b.txt", "c.jpg"])
    assert_splits("\n  a.txt \r\n b.txt\n\r\n c.jpg\n\n\r\n \n  \r\n", ["a.txt", "b.txt", "c.jpg"])
  end

  private def assert_splits(command_output, expected_output, file = __FILE__, line = __LINE__)
    execution_context = git_execution_context(Result(String, String).of(command_output))
    Result.match(GitStagedFiles.new(execution_context).list, {
      [Ok, output] => assert_equal(expected_output, output, nil, file, line),
      [Err, error] => flunk(error),
    })
  end

  private def git_execution_context(result)
    Doubles::ExecutionContextFake.new(Hash(String, Result(String, String)).new.merge({
      "git --no-pager diff --diff-filter=ACM --cached --name-only" => result,
    }))
  end
end
