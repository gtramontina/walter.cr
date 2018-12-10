require "docopt"
require "./walter/*"

VERSION  = {{ `shards version #{__DIR__}`.chomp.stringify }}
BASENAME = File.basename(::PROGRAM_NAME)
DOC      = <<-DOC
Walter - Keeping your Crystal clean!

Usage:
  #{BASENAME}
  #{BASENAME} (-c <config> | -C <config-file>)
  #{BASENAME} (-h | --help | -v | --version)

Options:
  -h --help                         Show this screen.
  -v --version                      Show version.
  -c --config=<config>              Rules configuration in YAML.
  -C --config-file=<config-file>    Rules configuration file in YAML [default: .walter.yml]
DOC

module Walter
  begin
    options = Docopt.docopt(DOC, version: VERSION, exit: false)
    config = options["--config"] || File.read(options["--config-file"].as(String))
    yaml_rules = YAMLRules.new(config.to_s)
    staged = GitStagedFiles.new(context = OSExecutionContext.new)
    result = VerboseLint.new(Lint.new(staged, context), Reporter.new).apply(yaml_rules.as_rules)
    Result.match(result, {
      [Ok, _]  => exit(0),
      [Err, _] => exit(1),
    })
  rescue error
    STDERR.puts(error)
    exit(1)
  end
end
