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
  it 'reads an empty document' do
    reader = Rulex::Tex::Reader.new
    reader.read ""
    expect(reader.export).to include({type: :document})
  end

  it 'accepts text' do
    reader = Rulex::Tex::Reader.new
    reader.read "abc"
    h = reader.export
    expect(h).to include(type: :document)
  end

  it 'reads a word' do
    word = "abc"
    reader = Rulex::Tex::Reader.new
    reader.read word
    text_node = reader.export[:children].first
    expect(text_node).to include(type: :text)
    expect(text_node).to include(text: word)
  end

  it 'reads a text' do
    text = "some sentence with spaces and we1rd c#arac!er3s"
    reader = Rulex::Tex::Reader.new
    reader.read text
    text_node = reader.export[:children].first
    expect(text_node).to include(type: :text)
    expect(text_node).to include(text: text)
  end


  it 'accepts commands' do
    reader = Rulex::Tex::Reader.new
    reader.read "\\somecommand{arg}"
    h = reader.export
    expect(h).to include(type: :document)
  end


  it 'reads commands' do
    reader = Rulex::Tex::Reader.new
    cmd = "\\somecommand{arg}"
    reader.read cmd
    command_node = reader.export[:children].first
    expect(command_node).to include(type: :command)
    expect(command_node).to include(log: "\\somecommand{arg}")
    expect(command_node).to include(name: "somecommand")
  end

  it 'reads a command\'s arguments' do
    reader = Rulex::Tex::Reader.new
    reader.read "\\somecommand{first arg}{other}"
    command_node = reader.export[:children].first
    expect(command_node).to include(arguments: ["first arg", "other"])
  end

  it 'accepts environments' do
    reader = Rulex::Tex::Reader.new
    reader.read "\\begin{env} some text \\end{env}"
    env_node = reader.export[:children].first
    expect(env_node).to include(type: :environment)
  end

  it 'reads environments' do
    reader = Rulex::Tex::Reader.new
    reader.read "\\begin{env} some text \\end{env}"
    env_node = reader.export[:children].first
    expect(env_node).to include(type: :environment)
    expect(env_node).to include(name: "env")
    expect(env_node).to include(content: " some text ")
  end
end


describe Rulex::Rex::Reader do
  it 'reads raw LaTeX' do
    reader = Rulex::Rex::Reader.new
    reader.read "raw 'Hi'"
    text_node = reader.export[:children].first
    expect(text_node).to include(type: :text)
    expect(text_node).to include(text: "Hi")
  end

end
