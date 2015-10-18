# Simple module that builds a document tree.
# Each node is
#   {type: method_id}
# where `method_id` the method id passed.
module Rulex::Echo
  def self.extended(mod)
    mod.add_behavior(/.*/, lambda{ |s| {type: s}})
  end
end
