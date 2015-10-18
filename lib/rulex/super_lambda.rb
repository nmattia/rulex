# SuperLambda is a callable object. The actual behavior depends
# on the number of arguments passed.
#
# Example:
#
#   sl = Rulex::SuperLambda.new (->(x){"one"}, ->(x,y){"two"})
#   sl.call("hello")          # -> "one"
#   sl.call("hello", "world") # -> "two"
class Rulex::SuperLambda

  def initialize(*args, &block)
    @callables = []
    @callables << block if block
    @callables.concat args
  end

  def call(*args, &block)
    begin
      @callables.detect{|c| c.parameters.length == args.length}.call(*args, &block)
    rescue
      raise "no fitting callable for #{args.inspect}"
    end
  end

  # Appends a callable to the callable list.
  def << callable
    @callables << callable
  end
end
