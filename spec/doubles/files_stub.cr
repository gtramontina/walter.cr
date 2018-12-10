require "crz"
require "walter/interfaces/files"

class Walter::Doubles::FilesStub
  include Interfaces::Files

  def initialize(@files = [] of String); end

  def list
    Result(Array(String), String).of(@files)
  end
end
