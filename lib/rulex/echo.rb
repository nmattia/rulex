module Rulex::Echo
  def self.extended(mod)
    mod.add_behavior(/.*/, lambda{ |s| {type: s}})
  end
end
