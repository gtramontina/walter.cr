module Walter::Interfaces::OSProcess
  abstract def run(command : String, input : IO, output : IO) : Process::Status
end
