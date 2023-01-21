# frozen_string_literal: true

require "erb_parser"

module Phlexing
  class ErbTransformer
    def self.transform(html)
      transformed = html.to_s
      transformed = transform_remove_newlines(transformed)
      transformed = transform_template_tag(transformed)

      ErbParser.transform_xml(transformed)
    rescue StandardError
      html
    end

    def self.transform_remove_newlines(html)
      html.tr("\n", "").tr("\r", "")
    end

    def self.transform_template_tag(html)
      html.gsub("<template", "<template-tag").gsub("</template", "</template-tag")
    end
  end
end
