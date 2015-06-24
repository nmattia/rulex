module Rulex
  module Tex
    class Writer

      def initialize
        @content = ''
      end

      def import arr
        return unless arr
        arr.each do |item|

          case item[:type]
          when :command
            @content += "\\#{item[:name]}"
            if opts = item[:options]
              @content += '[' + opts.join(',') + ']'
            end
            item[:arguments].each do |arg|
              @content += "{#{arg}}"
            end
            @content += "\n"
          when :text
            @content += item[:text]
          when :environment
            @content += "\\begin{#{item[:name]}}\n"
            import item[:children]
            @content += "\\end{#{item[:name]}}\n"
          else
            import item[:children] if item[:children]
          end
        end
      end

      def to_s
        @content
      end
      alias_method :export, :to_s
    end
  end
end
