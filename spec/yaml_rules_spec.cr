require "minitest/autorun"
require "walter/rule"
require "walter/yaml_rules"

describe Walter::YAMLRules do
  it "parses short-syntax YAML-formatted configs" do
    assert_parses("{expression: \\.txt$, command: echo}", [Rule.new(/\.txt$/, Command.new("echo"))])
    assert_parses("{expression: \\.txt$, command: echo}", [Rule.new(/\.txt$/, Command.new("echo"))])
    assert_parses("{expression: \\.txt$, command: echo}", [Rule.new(/\.txt$/, Command.new("echo"))])
    assert_parses("{expression: [\\.txt$], command: echo}", [Rule.new(/(?-imsx:\.txt$)/, Command.new("echo"))])
    assert_parses("{expression: \\.txt$, command: [echo]}", [Rule.new(/\.txt$/, Command.new("echo"))])
    assert_parses("[{expression: \\.txt$, command: echo}]", [Rule.new(/\.txt$/, Command.new("echo"))])
    assert_parses("[{expression: \\.txt$, command: [echo]}]", [Rule.new(/\.txt$/, Command.new("echo"))])
    assert_parses("[{expression: [\\.txt$], command: [echo]}]", [Rule.new(/(?-imsx:\.txt$)/, Command.new("echo"))])
  end

  it "parses full-syntax YAML-formated configurations" do
    assert_parses(<<-CONFIG, [Rule.new(/\.txt$/, Command.new("echo"))])
    expression: \\.txt$
    command: echo
    CONFIG

    assert_parses(<<-CONFIG, [Rule.new(/(?-imsx:\.txt$)/, Command.new("echo"))])
    expression:
      - \\.txt$
    command: echo
    CONFIG

    assert_parses(<<-CONFIG, [Rule.new(/(?-imsx:\.txt$)/, Command.new("echo"))])
    expression:
      - \\.txt$
    command:
      - echo
    CONFIG

    assert_parses(<<-CONFIG, [Rule.new(/(?-imsx:\.txt$)|(?-imsx:\.md$)/, Command.new("echo"))])
    expression:
      - \\.txt$
      - \\.md$
    command:
      - echo
    CONFIG

    assert_parses(<<-CONFIG, [Rule.new(/(?-imsx:\.txt$)|(?-imsx:\.md$)/, [Command.new("echo"), Command.new("cat")])])
    expression:
      - \\.txt$
      - \\.md$
    command:
      - echo
      - cat
    CONFIG

    assert_parses(<<-CONFIG, [Rule.new(/\.txt$/, Command.new("echo")), Rule.new(/\.md$/, Command.new("cat"))])
    - expression: \\.txt$
      command: echo
    - expression: \\.md$
      command: cat
    CONFIG
  end

  it "raises parsing issues " do
    assert_raises(YAMLRules::ParsingError) { YAMLRules.new("{expression: 0, command: 0}").as_rules }
    assert_raises(YAMLRules::ParsingError) { YAMLRules.new("[{expression: 0, command: 0}]").as_rules }
    assert_raises(KeyError) { YAMLRules.new("[{}]").as_rules }
    assert_raises(KeyError) { YAMLRules.new("[{expression: \\.txt$}]").as_rules }
    assert_raises(KeyError) { YAMLRules.new("[{command: echo}]").as_rules }
  end

  private def assert_parses(yaml_config, expected_rules, file = __FILE__, line = __LINE__)
    assert_equal(expected_rules, YAMLRules.new(yaml_config).as_rules, nil, file, line)
  end
end
