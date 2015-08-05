require 'pandoc-ruby'
require 'yaml'

#grammar_path = File.join(File.dirname(File.expand_path(__FILE__)),
#'rulex.treetop')
#Treetop.load grammar_path




# Used when reading YAML
class Object
  def deep_symbolize_keys
    return self.inject({}){|memo,(k,v)| memo[k.to_sym] = v.deep_symbolize_keys; memo} if self.is_a? Hash
    return self.inject([]){|memo,v    | memo           << v.deep_symbolize_keys; memo} if self.is_a? Array
    return self
  end
end


module Rulex
  module Rex
    class Reader
      def initialize
        @content = []
        @content_stack = [@content]
        @latex_reader = Rulex::Tex::Reader.new
        @delimiters = {
          raw: { open: "<##", close: "##>"},
          tex: { open: "<(#", close: "#)>"}
        }
      end

      # Feeds instructions, either as a [String] or Rulex instructions (parsed and then interpreted
      # with instance_eval) or as a block (it must be either or). All the functions of 
      # Rulex::Rex::Reader are available.
      # @param either a [String] or a [Block]
      # @return self (the Rulex::Rex::Reader)
      def read *args, &block
        if args.length == 1
          read_rex args.first
        elsif block
          instance_eval &block
        end
        self
      end

      def read_rex str
        instance_eval rex_to_ruby str
      end

      def rex_to_ruby str
        @delimiters.inject(str) do |str, d|
          key = d.first
          val = d[1]

          open_delimiter = Regexp.escape val[:open]
          close_delimiter = Regexp.escape val[:close]

          regexp = /#{open_delimiter}(((?!#{close_delimiter})[\s\S])+)#{close_delimiter}/

          # There are a few characters ('\\', '\[' and '\]') that even %q[] "un"-escapes,
          # hence the second gsub
          str.gsub(regexp) { |m| "#{key} %q[" + $1.gsub("\\","\\\\\\\\") + "]"}
        end
      end

      def add_node_to_content node
        @content_stack.last << node
      end

      def append_nodes_to_content arr
        @content_stack.last.concat arr
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


      # TODO
      def import str
        import_file str
      end


      # Reads a file, given a filepath
      # @filepath a [String]
      # @return self (the Rulex::Rex::Reader)
      def import_file filepath
        content = File.read(filepath)
        import_content content
      end


      # Reads some content
      # @content a [String]
      # @return self (the Rulex::Rex::Reader)
      def import_content content
        if content =~ /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m
          content = $'
          data = YAML.load($1).deep_symbolize_keys
        end
        content ||= ""
        data ||= {}
        if(delimiters = data[:delimiters])
          @delimiters.merge! delimiters
        end

        read content
      end

      def export
        @content
      end

      def build_tex_command(name, params)

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


      def depth
        @content_stack.length - 1
      end

      def tex_command(name, *params)
        add_node_to_content build_tex_command name, *params
      end

      def tex_environment(name, *args, &block)
        new_node = {type: :environment, name: name, arguments: args}
        @content_stack.push []
        read &block
        new_node.merge!(children: @content_stack.pop)
        add_node_to_content new_node
      end

      def method_missing(m_id, *args, &block) 
        if block
          tex_environment(m_id, *args, &block)
        elsif /pure_([a-zA-Z]+)/.match(m_id)
          Rulex::Tex::Writer.to_str(build_tex_command($1,args))
        else
          tex_command(m_id, args)
        end
      end

    end
  end
end
