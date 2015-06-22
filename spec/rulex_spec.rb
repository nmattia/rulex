require 'spec_helper'

describe Rulex do
  it 'has a version number' do
    expect(Rulex::VERSION).not_to be nil
  end

  it 'does something useful' do
    reader = Rulex::Tex::Reader.new
    expect(reader).not_to be nil
  end

  it 'translates a documentclass command' do
    rex_reader = Rulex::Rex::Reader.new
    tex_writer = Rulex::Tex::Writer.new
    rex_reader.read %q[documentclass :article]
    tex_writer.import rex_reader.export
    latex_content = tex_writer.export
    expect(latex_content.strip).to eq(%q[\documentclass{article}])
  end

  it 'processes the examples correctly' do
    rex_files = Dir.glob('examples/*.rex')
    rex_files.each do |dot_rex|

      dot_tex = dot_rex.sub /\.[^.]+\z/, ".tex"

      rex_reader = Rulex::Rex::Reader.new
      tex_writer = Rulex::Tex::Writer.new
      rex_reader.import dot_rex
      tex_writer.import rex_reader.export

      expect(tex_writer.export.strip).to eq(File.open(dot_tex).read.strip)
    end

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
  it 'reads raw text' do
    reader = Rulex::Rex::Reader.new
    reader.read "raw '\\mycommand{}'"
    text_node = reader.export.first
    expect(text_node).to include(type: :raw)
    expect(text_node).to include(text: "\\mycommand{}")
  end

  it 'reads LaTeX more than once' do
    reader = Rulex::Rex::Reader.new
    reader.read  %q[tex '\mycommand{a}'
                    tex '\frac{1}{2}']

                    first_node = reader.export.first[:children][:children].first
                    second_node = reader.export[1][:children][:children].first
                    expect(first_node).to include(name: "mycommand")
                    expect(second_node).to include(name: "frac")
                    expect(second_node).to include(arguments: ["1","2"])
  end

  it 'translates missing_method calls to latex commands' do
    reader = Rulex::Rex::Reader.new

    reader.read %q[rndcmd "my arg"]
    node = reader.export.first
    expect(node).to include(type: :command)
    expect(node).to include(name: :rndcmd)
    expect(node).to include(arguments: ["my arg"])
  end

  it 'imports a file' do
    reader = Rulex::Rex::Reader.new
    reader.import 'examples/hello_world.rex'
    node = reader.export.first
    expect(node).to include(type: :command)
    expect(node).to include(name: :documentclass)
    expect(node).to include(arguments: [:article])
  end
end


