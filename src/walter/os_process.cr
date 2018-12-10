require "./interfaces/os_process"

class Walter::OSProcess
  include Interfaces::OSProcess

  def run(command, output, error)
    Process.run(command, shell: true, output: output, error: error)
  end
end
