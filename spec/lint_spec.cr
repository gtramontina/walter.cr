require "crz"
require "minitest/autorun"
require "./doubles/files_stub"
require "./doubles/execution_context_fake"
require "walter/lint"

describe Walter::Lint do
  describe "with no rules configured" do
    it "does not run anything" do
      no_rules = [] of Rule
      context_fake = Doubles::ExecutionContextFake.new
      files = Doubles::FilesStub.new(["does.txt", "not.txt", "matter.cr"])
      result = Lint.new(files, context_fake).apply(no_rules)
      result.has_value.must_equal(true)
      context_fake.executed_commands.must_equal([] of String)
    end
  end

  describe "with rules configured" do
    let(:format) { Command.new("format") }
    let(:git_add) { Command.new("git add") }
    let(:convert) { Command.new("convert") }
    let(:lint) { Command.new("lint") }

    let(:format_crystal_files) { Rule.new(/\.cr$/, [format]) }
    let(:convert_image_files) { Rule.new(/\.(jpg|gif)$/, [convert, git_add]) }
    let(:lint_markdown_files) { Rule.new(/\.md$/, [lint, git_add]) }

    it "runs a single command on a single file" do
      context_fake = Doubles::ExecutionContextFake.new
      files = Doubles::FilesStub.new(["single_file.cr"])
      result = Lint.new(files, context_fake).apply([format_crystal_files])
      context_fake.executed_commands.must_equal(["format single_file.cr"])
      result.has_value.must_equal(true)
    end

    it "runs a single command on multiple files of the same type" do
      context_fake = Doubles::ExecutionContextFake.new
      files = Doubles::FilesStub.new(["path/1.cr", "path/2.cr"])
      result = Lint.new(files, context_fake).apply([format_crystal_files])
      context_fake.executed_commands.must_equal(["format path/1.cr", "format path/2.cr"])
      result.has_value.must_equal(true)
    end

    it "runs multiple commands on multiple files of the same type" do
      context_fake = Doubles::ExecutionContextFake.new
      files = Doubles::FilesStub.new(["path/1.jpg", "path/2.gif"])
      result = Lint.new(files, context_fake).apply([convert_image_files])
      context_fake.executed_commands.must_equal(["convert path/1.jpg", "git add path/1.jpg", "convert path/2.gif", "git add path/2.gif"])
      result.has_value.must_equal(true)
    end

    it "runs multiple commands on multiple files of different types" do
      context_fake = Doubles::ExecutionContextFake.new
      files = Doubles::FilesStub.new(["sources/1.cr", "sources/2.cr", "path/1.jpg", "path/2.gif", "ignored/file.txt"])
      result = Lint.new(files, context_fake).apply([format_crystal_files, convert_image_files])
      context_fake.executed_commands.must_equal(["format sources/1.cr", "format sources/2.cr", "convert path/1.jpg", "git add path/1.jpg", "convert path/2.gif", "git add path/2.gif"])
      result.has_value.must_equal(true)
    end

    describe "with borked commands" do
      it "ceases executing rules and commands" do
        context_fake = Doubles::ExecutionContextFake.new(Hash(String, Result(String, String)).new.merge({
          "convert path/1.jpg" => Result::Err(String, String).new("3. uh-oh!"),
        }))
        files = Doubles::FilesStub.new(["sources/1.cr", "sources/2.cr", "path/1.jpg", "path/2.gif", "ignored/file.txt", "README.md"])
        result = Lint.new(files, context_fake).apply([format_crystal_files, convert_image_files, lint_markdown_files])
        context_fake.executed_commands.must_equal(["format sources/1.cr", "format sources/2.cr", "convert path/1.jpg"])
        result.has_value.must_equal(false)
        result.value0.must_equal("3. uh-oh!")
      end
    end
  end
end
