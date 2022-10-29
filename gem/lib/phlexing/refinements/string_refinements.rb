module Phlexing
  module Refinements
    module StringRefinements
      refine String do
        def squish
          dup.squish!
        end

        def squish!
          gsub!(/[[:space:]]+/, " ")
          strip!
          self
        end
      end
    end
  end
end
