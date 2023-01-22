# frozen_string_literal: true

module Phlexing
  module Refinements
    module StringRefinements
      refine String do
        # https://github.com/rails/rails/blob/46c45935123e7ae003767900e7d22a6e41995701/activesupport/lib/active_support/core_ext/string/access.rb#L46-L48
        def from(position)
          self[position, length]
        end

        # https://github.com/rails/rails/blob/46c45935123e7ae003767900e7d22a6e41995701/activesupport/lib/active_support/core_ext/string/access.rb#L63-L66        def from(position)
        def to(position)
          position += size if position < 0
          self[0, position + 1] || +""
        end

        # https://github.com/rails/rails/blob/46c45935123e7ae003767900e7d22a6e41995701/activesupport/lib/active_support/core_ext/string/filters.rb#L13-L15
        def squish
          dup.squish!
        end

        # https://github.com/rails/rails/blob/46c45935123e7ae003767900e7d22a6e41995701/activesupport/lib/active_support/core_ext/string/filters.rb#L21-L25
        def squish!
          gsub!(/[[:space:]]+/, " ")
          strip!
          self
        end

        # https://stackoverflow.com/questions/4072159/classify-a-ruby-string#comment4378937_4072202
        def camelize
          split("_").collect(&:capitalize).join
        end

        def dasherize
          tr("_", "-").tr(" ", "-")
        end

        def underscore
          tr("-", "_").tr(" ", "_")
        end
      end
    end
  end
end
