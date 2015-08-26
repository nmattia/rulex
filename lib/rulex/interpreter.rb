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

    # accesses the builder (as the first pipeline step)
    def builder
      @pipeline_steps.first
    end

    # processes a string of contents 
    # returns the end stage
    def import(str, options={})
      @pipeline_steps = options[:pipeline] || []
      return import_contents_to_current_level(str)
    end

    def import_contents_to_current_level(str)
      unless @pipeline_steps.empty?
        instance_eval str
        pipeline = PiecePipe::Pipeline.new
        @pipeline_steps.each {|step| pipeline.step step}
        return pipeline.result
      end
    end

    def method_missing m_id, *args, &block
      if block 
        builder.begin_environment m_id
        instance_eval &block
        builder.end_environment m_id
      else
        builder.write_command(m_id, *args)
      end
    end
  end
end
