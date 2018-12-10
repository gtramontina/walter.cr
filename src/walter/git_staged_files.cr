require "./interfaces/files"

class Walter::GitStagedFiles
  include Interfaces::Files
  @context : Interfaces::ExecutionContext

  private COMMAND   = "git"
  private ARGUMENTS = ["--no-pager", "diff", "--diff-filter=ACM", "--cached", "--name-only"]

  def initialize(@context); end

  def list
    @context.execute(COMMAND, ARGUMENTS)
      .map(&.lines)
      .map(&.map(&.strip))
      .map(&.reject(&.empty?))
      .map(&.to_a)
  end
end
