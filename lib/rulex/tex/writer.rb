module Rulex
  module Tex
    class Writer

      def initialize
        @content = ''
      end

      def import arr
        arr.each do |item|
          if item[:type] == :command
            @content += "\\#{item[:name]}"
            item[:arguments].each do |arg|
              @content += "{#{arg}}"
            end
            @content += "\n"
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
