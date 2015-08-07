module Rulex
  class NodeBuilder

    def initialize
      @behaviors = []
    end

    def add_behavior(id, ret)
      raise ArgumentError unless Symbol === id or String === id or Regexp === id
      raise ArgumentError unless Proc === ret or Hash === ret
      @behaviors.push(id: id, ret: ret)
    end
    

    def build_command(id)
      behavior = nil

      @behaviors.each do |b|
        next unless b[:id] === id
        behavior = b
      end

      raise RuntimeError, "No behavior found" unless behavior

      ret = behavior[:ret]

      if Proc === ret
        ret.call(id)
      else
        ret
      end

    end
  end
end
