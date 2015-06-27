module Rulex
  module Tex
    class Writer

      def initialize
        @content = ''
      end

      def self.to_str item
        raise TypeError, "item must be a Hash, got #{item}" unless Hash === item
        raise ArgumentError, ":type must be defined" unless item[:type]
        case item[:type]
        when :command
          raise TypeError, "command name must be a Symbol or a String" unless
                        Symbol === item[:name] or String === item[:name]

          str = "\\#{item[:name]}"
          if opts = item[:options]
            str += '[' + opts.join(',') + ']'
          end
          if args = item[:arguments] and not args.empty?
            str += '{' + args.join('}{') + '}'
          end
          str += "\n"
        when :text
          res = item[:text]
        when :environment
          str = "\\begin{#{item[:name]}}"
          if args = item[:arguments] and not args.empty?
            str += '{' + args.join('}{') + '}'
          end
          str += "\n"
          if children = item[:children]
            str += item[:children].inject(""){|acc, c| acc += Rulex::Tex::Writer.to_str c} 
          end
          res = str += "\\end{#{item[:name]}}\n"
        else
          if item[:children]
            raise TypeError, "Children must form an array" unless Array === item[:children]
            str = item[:children].inject(""){|acc, c| acc += Rulex::Tex::Writer.to_str c} if item[:children] 
          else 
            ""
          end

        end
      end

      def import arr
        arr.each {|i| @content += Rulex::Tex::Writer.to_str i} if arr
      end

      def to_s
        @content
      end
      alias_method :export, :to_s
    end
  end
end
