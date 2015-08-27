require 'yaml'
require 'piece_pipe'
class Object
  # Used when reading YAML
  def deep_symbolize_keys
    return self.inject({}){|memo,(k,v)| memo[k.to_sym] = v.deep_symbolize_keys; memo} if self.is_a? Hash
    return self.inject([]){|memo,v    | memo           << v.deep_symbolize_keys; memo} if self.is_a? Array
    return self
  end
end

module Rulex
  class Interpreter

    def push_pipeline_step step
      pipeline_steps.push step
    end

    # accesses the builder (as the first pipeline step)
    def builder
      pipeline_steps.first
    end

    # processes a string of contents 
    # returns the end stage
    def import(str)
      h = split_front_matter_and_content str
      front_matter, content = h[:front_matter], h[:content]
      instance_eval content
      unless pipeline_steps.empty?
        pipeline = PiecePipe::Pipeline.new
        pipeline_steps.each {|step| pipeline.step step}
        return pipeline.result
      end
    end

    def method_missing m_id, *args, &block
      command_with_block = args && Hash === opts = args.last && opts[:rulex][:forward_block]
      raise RuntimeError, "No block provided" if command_with_block && !block

      if command_with_block
        builder.write_command(m_id, *args, &block)
      elsif block
        builder.begin_environment m_id
        instance_eval &block
        builder.end_environment m_id
      else
        builder.write_command(m_id, *args)
      end
    end

    private
    def pipeline_steps 
      @pipeline_steps = [] unless @pipeline_steps
      @pipeline_steps
    end

    def split_front_matter_and_content str
      if str =~ /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m
        content = $'
        data = YAML.load($1).deep_symbolize_keys
      end
      content ||= str
      data ||= {}
      {content: content, front_matter: data}
    end
  end
end
