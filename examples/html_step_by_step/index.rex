module SimpleBuilder
  def self.extended(builder)
    builder.add_behavior(/.*/, lambda{|s| {type: s}})
  end
end

module SimpleEcho
  def process(inputs)
    write_with_indent(inputs, "")
  end

  private
    def write_with_indent(arr, indent)
      arr.each do |item|
        if children = item[:children]
          puts "#{indent}<#{item[:type]}>"
          write_with_indent(children, indent + "   ")
          puts "#{indent}</#{item[:type]}>"
        else
          puts "#{indent}<#{item[:type]}/>"
        end
      end
    end
end

builder_step = PiecePipe::Step.new
builder_step.extend(Rulex::NodeBuilder)
builder_step.extend(SimpleBuilder)
pipeline_steps.push(builder_step)


echo_step = PiecePipe::Step.new
echo_step.extend(SimpleEcho)
pipeline_steps.push(echo_step)


html do
  head do
    title
  end

  body do

  end
end
