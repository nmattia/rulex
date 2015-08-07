require 'yaml'
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
    attr_accessor :content
    attr_accessor :builder
    attr_accessor :writer

    def initialize
      @content = []
      @content_stack = [@content]
      @builder = NodeBuilder.new
      @writer = NodeWriter.new
    end

    def add_node_to_content node
      @content_stack.last << node
    end
  end
end
