module Phlexing
  module Helpers
    def indent(level)
      return "" if level == 1
      "  " * level
    end

    def double_quote(string)
      "\"#{string}\""
    end

    def single_quote(string)
      "'#{string}'"
    end

    def do_block_start
      " do\n"
    end

    def do_block_end(level = 0)
      indent(level) + "end\n"
    end
  end
end
