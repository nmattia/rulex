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

    def initialize
      @content_stack = [@content]
      @builder = NodeBuilder.new
      @writer = NodeWriter.new
      @stack = [{content: []}]
    end

    def content
      @stack.last[:content]
    end

    def add_node_to_content node
      @stack.last[:content] << node
    end


    def push_new_stack_level
      @stack.push(content: [])
      self
    end

    def pop_and_merge_stack_level
      current_level = @stack.pop
      latest_content = current_level[:content]
      puts @stack
      @stack.last[:content].concat latest_content
      self
    end

    def import str
      push_new_stack_level
      import_contents_in_current_level str
      pop_and_merge_stack_level
    end

    def import_contents_in_current_level str

    end
  end
end
