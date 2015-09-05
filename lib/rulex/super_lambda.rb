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
      raise RuntimeError, "no fitting callable for #{args.inspect}"
    end
  end

  def << callable
    @callables << callable
  end
end
