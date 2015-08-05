require 'pandoc-ruby'

module Rulex
  module Rex
    class Reader < DocumentTreeBuilder

      writer_class Rulex::Tex::Writer

      def initialize
        super
        @latex_reader = Rulex::Tex::Reader.new
        latex_delimiters = {
          raw: { open: "<##", close: "##>"},
          tex: { open: "<(#", close: "#)>"}
        }

        @delimiters.merge! latex_delimiters
        @writer_class = Rulex::Tex::Writer

      end

      def raw str
        add_node_to_content(type: :text, text: str)
      end

      def md str
        latex_str = PandocRuby.new(str).to_latex
        arr = @latex_reader.read(latex_str).to_a
        append_nodes_to_content arr
      end

      def tex str
        append_nodes_to_content @latex_reader.read(str).to_a
      end

      def build_command(name, params)

        fail ArgumentError, "Command name must be a String or a Symbol, got #{name} of type #{name.class}" unless
        String === name or Symbol === name

        case params.length
        when 0
          {type: :command, name: name}
        when 1
          fail ArgumentError "Command arguments must all be String s or Symbol s, got #{params}" unless
          params.all?{|s| String === s or Symbol === s}
          {type: :command, name: name, arguments: params}
        when 2
          first = params[0]
          second = params[1]
          if Array === params[0] && Array === params[1]
            {type: :command, name: name, arguments: second, options: first}
          elsif String === params[0] && String === params[1]
            {type: :command, name: name, arguments: [first, second]}
          else
            raise ArgumentError, "something is not quite right with the parameters"
          end
        else
          raise ArgumentError, "wrong number of params"
        end
      end
    end
  end
end
