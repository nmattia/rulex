module Rulex
  module Rex
    class Reader

      def initialize
        @content = []
        @content_stack = [@content]
        @latex_reader = Rulex::Tex::Reader.new
      end

      alias_method :read, :instance_eval

      def add_to_content node
        @content_stack.last << node
      end

      def raw str
        add_to_content(type: :text, text: str)
      end

      def tex str
        add_to_content(type: :tex, children: @latex_reader.read(str))
      end

      def import filepath
        read File.open(filepath).read
      end

      def export
        @content
      end

      def tex_command(name, params)
        if params.length == 1
          add_to_content(type: :command, name: name, arguments: params)
        elsif params.length == 2
          opts = params[0]
          args = params[1]
          add_to_content(type: :command, name: name, arguments: args, options: opts)
        end
      end

      def depth
        @content_stack.length - 1
      end

      def tex_environment(name, args, block)
        new_node = {type: :environment, name: name, arguments: args}
        @content_stack.push []
        read &block
        new_node.merge!(children: @content_stack.pop)
        add_to_content new_node
      end

      def method_missing(m_id, *args, &block) 
        if block
          tex_environment(m_id, args, block)
        elsif /pure_([a-zA-Z]+)/.match(m_id)
          "\\#{$1}{1}{2}"
        else
          tex_command(m_id, args)
        end
      end
    end
  end
end
