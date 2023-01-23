# frozen_string_literal: true

require "deface"

module Phlexing
  class ErbTransformer
    def self.transform(source)
      transformed = source.to_s
      transformed = transform_template_tags(transformed)
      transformed = transform_erb_tags(transformed)
      transformed = transform_remove_newlines(transformed)
      transformed = transform_whitespace(transformed)

      transformed
    rescue StandardError
      source
    end

    def self.transform_remove_newlines(source)
      source.tr("\n", "").tr("\r", "")
    end

    def self.transform_template_tags(source)
      source.gsub("<template", "<template-tag").gsub("</template", "</template-tag")
    end

    def self.transform_erb_tags(source)
      Deface::Parser.erb_markup!(source)
    end

    def self.transform_whitespace(source)
      source.strip
    end
  end
end
