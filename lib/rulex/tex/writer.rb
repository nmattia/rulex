module Rulex
  module Tex
    class Writer

      def initialize
        @content = ''
      end

      def self.to_str item
        case item[:type]
        when :command
          str = "\\#{item[:name]}"
          if opts = item[:options]
            str += '[' + opts.join(',') + ']'
          end
          item[:arguments].each do |arg|
            str += "{#{arg}}"
          end
          str += "\n"
        when :text
          res = item[:text]
        when :environment
          str = "\\begin{#{item[:name]}}\n"
          if children = item[:children]
            str += item[:children].inject(""){|acc, c| acc += Rulex::Tex::Writer.to_str c} 
          end
          res = str += "\\end{#{item[:name]}}\n"
        else
          str = ""
          res = str += item[:children].inject(""){|acc, c| acc += Rulex::Tex::Writer.to_str c} if item[:children]
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
