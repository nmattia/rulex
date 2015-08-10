require 'spec_helper.rb'

describe Rulex::Interpreter do

  def new_interpreter
    Rulex::Interpreter.new
  end

  def new_interpreter_with_stack
    Rulex::Interpreter.new.push_new_stack_level
  end

  def new_interpreter_with_content content
    new_interpreter.import_content content
  end

  it 'instantiates' do
    expect{Rulex::Interpreter.new }.not_to raise_error
  end

  describe '#add_node_to_content' do
    it 'adds a node to the document tree' do
      interpreter = new_interpreter
      interpreter.add_node_to_content(type: :text, text: "Hello, World!")
      expect(interpreter.content).to eq([{type: :text, text: "Hello, World!"}])
    end
  end

  describe '#pop_and_merge_stack_level' do
    it 'merges current stack content' do
      interpreter = new_interpreter
      interpreter.push_new_stack_level
      interpreter.add_node_to_content(type: :smth)
      interpreter.pop_and_merge_stack_level
      expect(interpreter.content).to eq([{type: :smth}])
    end
  end
end
