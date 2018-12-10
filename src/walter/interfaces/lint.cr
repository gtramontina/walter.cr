module Walter::Interfaces::Lint
  abstract def apply(rules : Array(Interfaces::Rule)) : Result
end
