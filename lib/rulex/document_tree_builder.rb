require 'yaml'
class Object
  # Used when reading YAML
  def deep_symbolize_keys
    return self.inject({}){|memo,(k,v)| memo[k.to_sym] = v.deep_symbolize_keys; memo} if self.is_a? Hash
    return self.inject([]){|memo,v    | memo           << v.deep_symbolize_keys; memo} if self.is_a? Array
    return self
  end
end


module Rulex
  # DocumenTreeBuilder is the superclass for any Builder.
  # When a class extends [DocumentTreeBuilder] it must do
  # two things in initialize:
  #  * call super
  #  * set @writer_class with the writer class
  #
  # and it can
  #  * add delimiters to @delimiters
  class DocumentTreeBuilder
    def initialize
      @content = []
      @content_stack = [@content]
      @delimiters = {}
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
    def depth
      @content_stack.length - 1
    end
    def read_rex str
      instance_eval rex_to_ruby str
    end


    def add_node_to_content node
      @content_stack.last << node
    end

    def append_nodes_to_content arr
      @content_stack.last.concat arr
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

    def method_missing(m_id, *args, &block)
      if block
        environment(m_id, *args, &block)
      elsif /\Apure_/ =~ m_id
        @writer_class.to_str(build_command($',args))
      else
        command(m_id, args)
      end
    end
    def command(name, *params)
      h = build_command name, *params
      fail ArgumentError, 
        "build_command MUST return a hash, instead returned #{h}" unless Hash === h
      add_node_to_content h
    end

    def environment(name, *args, &block)
      new_node = {type: :environment, name: name, arguments: args}
      @content_stack.push []
      read &block
      new_node.merge!(children: @content_stack.pop)
      add_node_to_content new_node
    end
  end
end
