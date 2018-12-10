require "./interfaces/files"
require "./reporter"

class Walter::VerboseFiles
  include Interfaces::Files
  @files : Interfaces::Files
  @reporter : Reporter

  def initialize(@files, @reporter); end

  def list
    @reporter.before_files
    result = @files.list
    Result.match(result, {
      [Ok, output] => @reporter.on_files_success(output),
      [Err, error] => @reporter.on_files_failure(error),
    })
    @reporter.after_files
    result
  end
end
