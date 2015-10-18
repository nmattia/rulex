module Rulex
  module NodeBuilder

    # Adds a behavior to the builder. When `id` matches
    # the method id, `ret` is returned (or called if
    # callable)
    #
    # @param: id [String] or [Regexp] the id to match (with `===`)
    # @param: ret [Hash] or callable, what to place in the document
    #   tree. If callable, `ret` will be called with original method
    #   id, arguments and block (see #build_comment)
    def add_behavior(id, ret)
      behaviors.push(id: id, ret: ret)
    end

    # Builds a command given a method id. 
    # @param id [Symbol] the method id
    # @return [Hash] what the behavior built (see #add_behavior)
    def build_command(id, *args, &block)
      behavior = nil

      behaviors.each do |b|
        next unless b[:id] === id
        behavior = b
      end

      raise RuntimeError, "No behavior found" unless behavior

      ret = behavior[:ret]
      ret.respond_to?(:call) ? ret.call(id, *args, &block) : ret
    end

    # Write the result of a command to the document tree 
    # (see #build_command)
    def write_command(id, *args, &block)
      ret = build_command(id, *args)
      stack.last.push ret
    end

    # Begin an environment, usually because method
    # was called with a block
    def begin_environment(id, *args, &block)
      stack.last.push({type: id})
      stack.push([])
    end

    # Closes an environment (see #begin_environment)
    def end_environment(id)
      latest_content = stack.pop
      previous_content = stack.last
      environment_node = previous_content.last
      raise RuntimeError, "closing on wrong environment" unless environment_node[:type] == id
      environment_node[:children] = latest_content if latest_content
    end

    # Used by PiecePipe to produce data for the next pipeline step.
    # Simply produces the document tree built so far.
    def generate_sequence
      content = stack.pop
      raise RuntimeError, "stack not empty, found #{stack}" unless stack.empty?
      produce content
    end

    private
      def behaviors
        @behaviors = [] unless @behaviors
        @behaviors
      end

      def stack
        @stack = [[]] unless @stack
        @stack
      end
  end
end
