require "crz"

module Walter::Interfaces::Files
  abstract def list : Result(Array(String))
end
