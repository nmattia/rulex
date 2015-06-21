require 'spec_helper'

describe Rulex do
  it 'has a version number' do
    expect(Rulex::VERSION).not_to be nil
  end

  it 'does something useful' do
    reader = Rulex::Tex::Reader.new
    expect(reader).not_to be nil
  end
end

describe Rulex::Tex::Reader do
  it 'parses an empty document' do
    reader = Rulex::Tex::Reader.new
    reader.parse ""
    expect(reader.export).to include({type: :document})
  end

  it 'accepts text' do
    reader = Rulex::Tex::Reader.new
    reader.parse "abc"
    h = reader.export
    expect(h).to include(type: :document)
  end

  it 'parses a word' do
    word = "abc"
    reader = Rulex::Tex::Reader.new
    reader.parse word
    text_node = reader.export[:children].first
    expect(text_node).to include(type: :text)
    expect(text_node).to include(text: word)
  end

  it 'parses a text' do
    text = "some sentence with spaces and we1rd c#arac!er3s"
    reader = Rulex::Tex::Reader.new
    reader.parse text
    text_node = reader.export[:children].first
    expect(text_node).to include(type: :text)
    expect(text_node).to include(text: text)
  end


  it 'accepts commands' do
    reader = Rulex::Tex::Reader.new
    reader.parse "\\somecommand{arg}"
    h = reader.export
    expect(h).to include(type: :document)
  end


  it 'parses commands' do
    reader = Rulex::Tex::Reader.new
    cmd = "\\somecommand{arg}"
    reader.parse cmd
    command_node = reader.export[:children].first
    expect(command_node).to include(type: :command)
    expect(command_node).to include(log: "\\somecommand{arg}")
    expect(command_node).to include(name: "somecommand")
  end

  it 'parses a command\'s arguments' do
    reader = Rulex::Tex::Reader.new
    reader.parse "\\somecommand{first arg}{other}"
    command_node = reader.export[:children].first
    expect(command_node).to include(arguments: ["first arg", "other"])
  end

  it 'accepts environments' do
    reader = Rulex::Tex::Reader.new
    reader.parse "\\begin{env} some text \\end{env}"
    env_node = reader.export[:children].first
    expect(env_node).to include(type: :environment)
  end

  it 'parses environments' do
    reader = Rulex::Tex::Reader.new
    reader.parse "\\begin{env} some text \\end{env}"
    env_node = reader.export[:children].first
    expect(env_node).to include(type: :environment)
    expect(env_node).to include(name: "env")
    expect(env_node).to include(content: " some text ")

  end
end
