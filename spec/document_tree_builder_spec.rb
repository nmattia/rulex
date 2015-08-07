require 'spec_helper'

describe Rulex::DocumentTreeBuilder do
  def new_builder
    Rulex::DocumentTreeBuilder.new
  end
  it 'is true' do
    expect(true).to be true
  end

  it 'allows method definitions' do
    builder = new_builder
    builder.read "def my_func\n  'result'\nend"
    expect(builder.my_func).to eq('result')
    expect(builder.instance_eval 'my_func').to eq('result')
  end

  it 'allows for empty files' do
    expect{new_builder.import_content ""}.not_to raise_error
  end
end
