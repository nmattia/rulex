module Rulex
  module NodeBuilder

    def add_behavior(id, ret)
      #raise ArgumentError unless Symbol === id or String === id or Regexp === id
      #raise ArgumentError unless Proc === ret or Hash === ret
      behaviors.push(id: id, ret: ret)
    end

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

    def write_command(id, *args, &block)
      ret = build_command(id, *args)
      stack.last.push ret
    end

    def begin_environment(id, *args, &block)
      stack.last.push({type: id})
      stack.push([])
    end

    def end_environment(id)
      latest_content = stack.pop
      previous_content = stack.last
      environment_node = previous_content.last
      raise RuntimeError, "closing on wrong environment" unless environment_node[:type] == id
      environment_node[:children] = latest_content if latest_content
    end

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
