require "walter/interfaces/os_process"

class Walter::Doubles::BadOSProcess
  include Walter::Interfaces::OSProcess

  def run(command, output, error)
    raise "borked!"
  end
end
