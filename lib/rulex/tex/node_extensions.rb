module Rulex
  module Tex 
    module Grammar

      class Treetop::Runtime::SyntaxNode
        def node_content
          h = {type: :node} #, log: elements.to_s}
          h.merge!(:children => elements.map{|e| e.node_content}) if elements && !elements.empty?
          h.merge! content
        end
        def content
          {}
        end
      end

      class CustomNode < Treetop::Runtime::SyntaxNode
      end

      class Document < CustomNode
        def content
          {type: :document}
        end
      end

      class Text < CustomNode
        def content
          {type: :text, text: text_value} 
        end
      end

      class Command < CustomNode
        def content
          {type: :command, name: elements[1].text_value}
        end
      end 

      class Environment < CustomNode
        def content
          {type: :environment, name: elements[1].text_value}
        end
      end
    end
  end
end
