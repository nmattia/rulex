module Rulex
  module Tex 
    module Grammar

      class Treetop::Runtime::SyntaxNode
        def node_content
          h = {type: :node} #, log: elements.to_s}
          h.merge!(:children => elements.map{|e| e.node_content}) if elements && !elements.empty?
          h.merge!(log: text_value)
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
          h = {type: :command, name: elements[1].text_value}
          if opts_maybe = elements[2].elements
            opts = []
            opts << opts_maybe[1].text_value

            if opts_kleene_s = opts_maybe[2].elements
              opts += opts_kleene_s.map{|e| e.elements[1].text_value}
            end

            h.merge!(options: opts)
          end
          if args_kleene_s = elements[3]
            h.merge!(arguments: args_kleene_s.elements.map{|e| e.elements[1].text_value}) 
          end

          h
        end
      end 

      class Environment < CustomNode
        def content
          {type: :environment, name: elements[1].text_value, children: elements[3].elements.map{|e| e.content }}
        end
      end
    end
  end
end
