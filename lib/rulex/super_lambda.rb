class Rulex::SuperLambda

  def initialize(*args, &block)
    @callables = []
    @callables << block if block
    @callables.concat args
  end

  def call(*args, &block)
    @callables.detect{|c| c.parameters.length == args.length}.call(*args, &block)
  end

  def << callable
    @callables << callable
  end
end
