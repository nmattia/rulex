require 'spec_helper'

def pandoc?
  begin
    `pandoc -v`
  rescue Errno::ENOENT
    return false
  end
  return true
end

describe Rulex do
  it 'has a version number' do
    expect(Rulex::VERSION).not_to be nil
  end

  it 'translates a documentclass command' do
    rex_reader = Rulex::Rex::Reader.new
    tex_writer = Rulex::Tex::Writer.new
    rex_reader.read %q[documentclass :article]
    tex_writer.import rex_reader.export
    latex_content = tex_writer.export
    expect(latex_content.strip).to eq(%q[\documentclass{article}])
  end

  if pandoc?

    puts "pandoc installed, testing examples"
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
end

describe Rulex::Tex::Reader do

  it 'reads a word' do
    word = "abc"
    reader = Rulex::Tex::Reader.new
    reader.read word
    text_node = reader.export.first
    expect(text_node).to include(type: :text)
    expect(text_node).to include(text: word)
  end

  it 'reads a text' do
    text = "some sentence with spaces and we1rd c#arac!er3s"
    reader = Rulex::Tex::Reader.new
    reader.read text
    text_node = reader.export.first
    expect(text_node).to include(type: :text)
    expect(text_node).to include(text: text)
  end

  it 'reads commands' do
    reader = Rulex::Tex::Reader.new
    cmd = "\\somecommand{arg}"
    reader.read cmd
    command_node = reader.export.first
    expect(command_node).to include(type: :command)
    expect(command_node).to include(log: "\\somecommand{arg}")
    expect(command_node).to include(name: "somecommand")
  end

  it 'reads a command\'s arguments' do
    reader = Rulex::Tex::Reader.new
    reader.read "\\somecommand{first arg}{other}"
    command_node = reader.export.first
    expect(command_node).to include(arguments: ["first arg", "other"])
  end

  it 'reads a command\'s only optional argument' do
    reader = Rulex::Tex::Reader.new
    reader.read "\\somecommand[option]{first arg}{other}"
    command_node = reader.export.first
    expect(command_node).to include(options: ["option"], arguments: ["first arg", "other"])
  end

  it 'reads a command\'s optional arguments' do
    reader = Rulex::Tex::Reader.new
    reader.read "\\somecommand[option1,option2]{first arg}{other}"
    command_node = reader.export.first
    expect(command_node).to include(options: ["option1", "option2" ], arguments: ["first arg", "other"])
  end
  it 'accepts environments' do
    reader = Rulex::Tex::Reader.new
    reader.read "\\begin{env} some text \\end{env}"
    env_node = reader.export.first
    expect(env_node).to include(type: :environment)
  end

  it 'reads environments' do
    reader = Rulex::Tex::Reader.new
    reader.read "\\begin{env} some text \\end{env}"
    env_node = reader.export.first
    expect(env_node).to include(type: :environment)
    expect(env_node).to include(name: "env")
    content = env_node[:children]
    expect(content).to include({type: :text, text: " some text "})
  end
end

describe Rulex::Tex::Writer do

  describe "self.to_str" do
    it 'only accepts a Hash as an argument' do
      expect{Rulex::Tex::Writer.to_str [:type, :name]}.to raise_error TypeError
    end

    it 'only accepts a Hash if :type is defined' do
      expect{Rulex::Tex::Writer.to_str(something: :else)}.to raise_error ArgumentError
    end

  end

  it 'writes an empty document' do
    writer = Rulex::Tex::Writer.new
    writer.import []
    expect(writer.export).to eq("")

 end

  it 'writes text' do
    writer = Rulex::Tex::Writer.new
    writer.import [{type: :text, text: "Hello, world!"}]
    expect(writer.export).to eq("Hello, world!")
  end


  it 'writes commands' do
    writer = Rulex::Tex::Writer.new
    writer.import [{type: :command, name: :documentclass, arguments: [:article]}]
    expect(writer.export.strip).to eq("\\documentclass{article}")
  end

  it 'writes commands with no arguments' do
    writer = Rulex::Tex::Writer.new
    writer.import [{type: :command, name: :titlepage}]
    expect(writer.export.strip).to eq("\\titlepage")
  end

  it 'writes commands with arguments and optional arguments' do
    writer = Rulex::Tex::Writer.new
    writer.import [{type: :command, name: :documentclass, options: ["11pt",:a4paper] , arguments: [:article]}]
    expect(writer.export.strip).to eq("\\documentclass[11pt,a4paper]{article}")
  end

  it 'writes environment' do
    writer = Rulex::Tex::Writer.new
    writer.import([{type: :environment, name: :frame, children: [{type: :command, name: :cmd}]}])
    expect(writer.export.strip).to eq("\\begin{frame}\n\\cmd\n\\end{frame}")
  end

  it 'writes environment with arguments' do
    writer = Rulex::Tex::Writer.new
    writer.import([{type: :environment, name: :frame, 
                    arguments: ["arg1", "arg2"],
                    children: [{type: :command, name: :cmd}]}])
    expect(writer.export.strip).to eq("\\begin{frame}{arg1}{arg2}\n\\cmd\n\\end{frame}")
  end
end

describe Rulex::Rex::Reader do
  it 'reads raw text' do
    reader = Rulex::Rex::Reader.new
    reader.read "raw '\\mycommand{}'"
    text_node = reader.export.first
    expect(text_node).to include(type: :text)
    expect(text_node).to include(text: "\\mycommand{}")
  end

  it 'reads LaTeX more than once' do
    reader = Rulex::Rex::Reader.new
    reader.read  "tex '\\mycommand{a}'\ntex '\\frac{1}{2}'"

    first_command = reader.export.first
    second_command = reader.export[1]
    expect(first_command).to include(name: "mycommand")
    expect(second_command).to include(name: "frac")
    expect(second_command).to include(arguments: ["1","2"])
  end


  it 'translates missing_method calls to latex commands' do
    reader = Rulex::Rex::Reader.new

    reader.read %q[rndcmd "my arg"]
    node = reader.export.first
    expect(node).to include(type: :command)
    expect(node).to include(name: :rndcmd)
    expect(node).to include(arguments: ["my arg"])
  end

  it 'reads method with blocks as environments' do
    reader = Rulex::Rex::Reader.new

    reader.read %q[
    myenv do
      mycom
    end
    ]
    node = reader.export.first
    expect(node).to include(type: :environment)
    expect(node).to include(name: :myenv)
    expect(node[:children].first).to include(type: :command)
    expect(node[:children].first).to include(name: :mycom)
  end

  it 'reads method with params and block as environments with args' do

    reader = Rulex::Rex::Reader.new

    reader.read %q[
    myenv("arg1", "arg2") do
      mycom
    end
    ]
    node = reader.export.first
    expect(node).to include(type: :environment)
    expect(node).to include(name: :myenv)
    expect(node).to include(arguments: ["arg1", "arg2"])
  end
  it 'reads latex commands with several args' do
    reader = Rulex::Rex::Reader.new

    reader.read %q[mycmd("arg1","arg2")]
    node = reader.export.first
    expect(node).to include(type: :command)
    expect(node).to include(name: :mycmd)
    expect(node).to include(arguments: ["arg1","arg2"])
  end

  it 'reads latex commands with args and opts' do
    reader = Rulex::Rex::Reader.new

    reader.read %q[mycmd(["option1","option2"], ["arg1","arg2"])]
    node = reader.export.first
    expect(node).to include(type: :command)
    expect(node).to include(name: :mycmd)
    expect(node).to include(arguments: ["arg1","arg2"])
    expect(node).to include(options: ["option1", "option2"])
  end

  if pandoc?
    it 'reads markdown' do
      reader = Rulex::Rex::Reader.new

      reader.read %q[md "this is *not* funny"]
      nodes = reader.export
      first_text = nodes.first
      command = nodes[1]
      last_text = nodes.last

      expect(first_text).to include(type: :text)
      expect(first_text).to include(text: "this is ")
      expect(command).to include(type: :command)
      expect(command).to include(name: "emph")
      expect(command).to include(arguments: ["not"])
      expect(last_text).to include(type: :text)
      expect(last_text).to include(text: " funny\n")
    end
  end

  it 'translates missing_method calls with blocks to environments' do
    reader = Rulex::Rex::Reader.new
    reader.read  "someEnv do\nsomeCom :some_arg\nend"
    env_node = reader.export.first
    expect(env_node).to include(type: :environment, name: :someEnv)
    env_children = env_node[:children]
    expect(env_children).to include(arguments: [:some_arg], type: :command, name: :someCom)
  end

  it 'imports a file' do
    reader = Rulex::Rex::Reader.new
    reader.import_file 'examples/hello_world.rex'
    node = reader.export.first
    expect(node).to include(type: :command)
    expect(node).to include(name: :documentclass)
    expect(node).to include(arguments: [:article])
  end

  it 'translates missing methods starting with `pure_` to equivalent pure functions' do
    reader = Rulex::Rex::Reader.new
    expect(reader.pure_tilde("x").strip).to eq("\\tilde{x}")
  end

  it "transforms text blocs delimited by '<##' and '##>' into raw calls if called with read_rex" do
    reader = Rulex::Rex::Reader.new

    reader.read_rex "<##\\documentclass{}##>"

    document = reader.export.first
    expect(document).to include(type: :text, text: "\\documentclass{}")
  end


  it "transforms text blocs delimited by '<##' and '##>' into raw calls if called with read" do
    reader = Rulex::Rex::Reader.new

    reader.read "<##\\documentclass{}##>"

    document = reader.export.first
    expect(document).to include(type: :text, text: "\\documentclass{}")
  end

  it "transforms text blocs delimited by '<(#' and '#)>' into tex calls if called with read" do
    reader = Rulex::Rex::Reader.new

    reader.read "<(#\\documentclass{}#)>"

    document = reader.export.first
    expect(document).to include(type: :command, name: "documentclass")
  end

  it "allows delimiters to be modified through frontmatter" do
    reader = Rulex::Rex::Reader.new

    reader.import_content <<-EOF
---
delimiters:
  tex: 
    open: AA
    close: BB
---
AA\\documentclass{}BB
EOF

    document = reader.export.first
    expect(document).to include(type: :command, name: "documentclass")
  end
end

