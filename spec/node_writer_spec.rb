describe Rulex::NodeWriter do

  def new_writer
    Rulex::NodeWriter.new
  end

  it 'allows adding Symbol -> String' do
    writer = new_writer
    writer.add_type(:something, "Hello, World!")
    expect(writer.snippet_for(type: :something)).to eq("Hello, World!")
  end

  it 'allows adding String -> String' do
    writer = new_writer
    writer.add_type(:something, "Hello, World!")
    expect(writer.snippet_for(type: :something)).to eq("Hello, World!")
  end
end



