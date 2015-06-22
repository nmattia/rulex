module Rulex
  module Rex
    class Reader
      
      def initialize
        @content = []
        @latex_reader = Rulex::Tex::Reader.new
      end

      def read str
        eval str
      end

      def raw str
        @content = @latex_reader.read str
      end

      def export
        @content
      end
    end
  end
end
