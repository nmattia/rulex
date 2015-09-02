require 'spec_helper.rb'

describe Rulex::Interpreter do

  def new_interpreter
    Rulex::Interpreter.new
  end

  def new_interpreter_with_content content
    new_interpreter.import_content content
  end

  it 'instantiates' do
    expect{Rulex::Interpreter.new }.not_to raise_error
  end

  describe '#import' do

    module DummyGenerator 
      def generate_sequence
        produce(type: :dummy)
      end
    end

    module Echo
      def self.extended(mod)
        mod.add_behavior(/.*/, lambda{ |s| {type: s}})
      end
    end

    class GreetingBuilder < PiecePipe::Step
      attr_reader :greetings
      include DummyGenerator

      def say_hi whom
        @greetings = "#{whom} said hi"
      end
    end

    it 'feeds pipeline' do
      step = PiecePipe::Step.new
      step.extend DummyGenerator
      interpreter = new_interpreter
      interpreter.push_pipeline_step step
      res = interpreter.import("")
      expect(res).to eq({type: :dummy})
    end

    it 'forwards builder commands to first step of pipeline' do
      step = PiecePipe::Step.new
      step.extend Rulex::NodeBuilder
      step.extend Echo
      interpreter = new_interpreter
      interpreter.push_pipeline_step step
      res = interpreter.import("hi\nthere")
      expect(res).to eq([{type: :hi}, {type: :there}])
    end

    it 'gives access to builder' do
      step = GreetingBuilder.new
      interpreter = new_interpreter
      interpreter.push_pipeline_step step
      interpreter.import("builder.say_hi 'Santa'")
      expect(step.greetings).to eq("Santa said hi")
    end

    it 'builds environment' do
      step = PiecePipe::Step.new
      step.extend Rulex::NodeBuilder
      step.extend Echo
      interpreter = new_interpreter
      interpreter.push_pipeline_step step
      res = interpreter.import("hi\nthere\nsomething do\n  different\nend")
      expect(res).to eq([{type: :hi}, 
                         {type: :there}, 
                         {type: :something, children: [
                            {type: :different}
                         ]}])

    end

    it 'allows method definitions' do
      int = new_interpreter
      int.import "def my_func\n 'result'\n end"
      expect(int.my_func).to eq('result')
    end

    it 'does not crash on empty input' do
      expect{new_interpreter.import ""}.not_to raise_error
    end
  end
end
