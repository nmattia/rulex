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
        new_node = {type: :raw, text: str }
        @content << new_node
      end

      def tex str
        new_node = {type: :tex, children: @latex_reader.read(str)}
        @content << new_node
      end

      def import filepath
        read File.open(filepath).read
      end

      def export
        @content
      end

      def tex_command(name, args)
        new_node = {type: :command, name: name, arguments: args}
        @content << new_node
      end

      def method_missing(m_id, *args, &block) 
        tex_command(m_id, args)
      end
    end
  end
end
