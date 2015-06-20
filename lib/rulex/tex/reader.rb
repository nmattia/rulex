require 'treetop'
require_relative 'node_extensions'

grammar_path = File.join(File.dirname(File.expand_path(__FILE__)),
                         'latex.treetop')
Treetop.load grammar_path


module Rulex
  module Tex
    class Reader

      def initialize
        @parser = LatexParser.new
        @documentclass = :article
        @content = []
      end


      def to_a
        @content
      end
      alias_method :export, :to_a

      def parse str
        @content = @parser.parse(str).node_content
      end
    end
  end
end
