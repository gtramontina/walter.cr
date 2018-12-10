module Walter::Interfaces::Rule
  abstract def apply(files : Files, context : ExecutionContext) : Result
end
