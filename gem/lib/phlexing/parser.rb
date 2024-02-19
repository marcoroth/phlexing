# frozen_string_literal: true

require "nokogiri"

module Phlexing
  class Parser
    def self.call(source)
      source = ERBTransformer.call(source)
      source = Minifier.call(source)

      # Credit:
      # https://github.com/spree/deface/blob/6bf18df76715ee3eb3d0cd1b6eda822817ace91c/lib/deface/parser.rb#L105-L111
      #

      html_tag = /<html(( .*?(?:(?!>)[\s\S])*>)|>)/i
      head_tag = /<head(( .*?(?:(?!>)[\s\S])*>)|>)/i
      body_tag = /<body(( .*?(?:(?!>)[\s\S])*>)|>)/i

      if source =~ html_tag
        Nokogiri::HTML::Document.parse(source)
      elsif source =~ head_tag && source =~ body_tag
        Nokogiri::HTML::Document.parse(source).css("html").first
      elsif source =~ head_tag
        Nokogiri::HTML::Document.parse(source).css("head").first
      elsif source =~ body_tag
        Nokogiri::HTML::Document.parse(source).css("body").first
      else
        Nokogiri::HTML5::DocumentFragment.parse(source)
      end
    end
  end
end
