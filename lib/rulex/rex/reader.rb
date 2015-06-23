module Rulex
  module Rex
    class Reader
      def initialize
        @content = []
        @latex_reader = Rulex::Tex::Reader.new
      end

      alias_method :read, :instance_eval
      #def read str
        #instance_eval str
      #end

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
      
      def tex_environment(name, args, block)
        new_node = {type: :environment, name: name, arguments: args}
        deeper_parser = Rulex::Rex::Reader.new 
        deeper_parser.read &block
        new_node.merge!(children: deeper_parser.export)
        
        @content << new_node
      end

      def method_missing(m_id, *args, &block) 
        if block
          tex_environment(m_id, args, block)
        else
          tex_command(m_id, args)
        end
      end
    end
  end
end
