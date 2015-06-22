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
