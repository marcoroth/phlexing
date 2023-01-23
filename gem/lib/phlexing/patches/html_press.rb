# frozen_string_literal: true

require "html_press"

module HtmlPress
  class Html
    # We want to preserve HTML comments in the minification step
    # so we can output them again in the phlex template
    def process_html_comments(out)
      out
    end
  end

  class Entities
    # The minification step turned this input
    # <div data-erb-class="&lt;%= something? ? &quot;class-1&quot; : &quot;class-2&quot; %&gt;">Text</div>
    #
    # into this output:
    # <div data-erb-class="&lt;%= something? ? " class-1"  :" class-2" %& gt;">Text</div>
    #
    # which in our wasn't ideal, because nokogiri parsed it as:
    # <div data-erb-class="<%= something? ? " class-1="  :" class-2="%>">Text</div>
    #
    def minify(out)
      out
    end
  end
end
