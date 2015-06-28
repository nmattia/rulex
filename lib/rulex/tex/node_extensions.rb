module Rulex
  module Tex 
    module Grammar

      class Treetop::Runtime::SyntaxNode


        # Goes through all its SyntaxNode children to build a Hash and Array based tree
        # of the parsed document. A node_content is a Hash, containing a :type, and maybe 
        # containing :children. If node_content contains :children, they must form an Array.
        # That is:
        #  * node_content MUST be a Hash that
        #    * MUST contain an entry :type of type Symbol or String
        #    * MAY contain an entry :children, which then MUST be of type Array
        #    * MAY contain any other kind of entries 
        #
        # The before it is returned, the node_content is merged with the result from #content.
        # @return the Hash object of the node's content
        def node_content
          h = {type: :node} #, log: elements.to_s}
          h.merge!(:children => elements.map{|e| e.node_content}) if elements && !elements.empty?
          h.merge!(log: text_value)
          h.merge! content
        end

        # Build an Array of its children and returns it. Each children is a Hash (description in #node_content).
        # @return [Array] the Array of children
        def to_a
          elements.map{|e| e.node_content} if elements 
        end

        def content
          {}
        end
      end

      class CustomNode < Treetop::Runtime::SyntaxNode
      end

      class LatexContent < CustomNode
        def content
          #elements.map{|e| e.node_content} if elements && !elements.empty?
          {type: :node}
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
