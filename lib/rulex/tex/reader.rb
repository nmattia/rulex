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
        @content = []
      end

      # Exports the Reader's content
      # @return [Array] the Reader's content
      def to_a
        @content
      end
      alias_method :export, :to_a

      # Takes a string of LaTeX contents, parses it to a Rulex tree, and sets that tree as
      # the Reader's content
      # @param str [String] the LaTeX contents as a String
      # @return [Array] The new content
      def read str
        new_content = @parser.parse(str).to_a
        raise TypeError, "content should be an Array" unless new_content and Array === new_content
        @content = new_content
      end
    end
  end
end
