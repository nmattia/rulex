require 'spec_helper.rb'

describe Rulex::Interpreter do

  def new_interpreter
    Rulex::Interpreter.new
  end

  def new_interpreter_with_content content
    i = new_interpreter.import_content content
    i
  end

  it 'instantiates' do
    expect{Rulex::Interpreter.new }.not_to raise_error
  end

  it 'has a node builder' do
    expect(new_interpreter.builder).not_to be_nil
  end

  it 'has a node writer' do
    expect(new_interpreter.writer).not_to be_nil
  end

  describe '#add_node_to_content' do
    it 'adds a node to the document tree' do
      interpreter = new_interpreter
      interpreter.add_node_to_content(type: :text, text: "Hello, World!")
      expect(interpreter.content).to eq([{type: :text, text: "Hello, World!"}])
    end
  end
end
