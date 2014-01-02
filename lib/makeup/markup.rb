# encoding: utf-8
# --
# The MIT License (MIT)
#
# Copyright (C) 2012 Gitorious AS
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#++
require "loofah"
require "github/markup"
require "makeup/code_block_parser"
require "makeup/syntax_highlighter"

module Makeup
  class NoopHighlighter
    def highlight(path, code, options = {})
      lexer = options[:lexer] || path.split(".").last
      CodeBlock.new(lexer, code)
    end
  end

  class Markup
    def initialize(options = {})
      @markup_class_name = options[:markup_class_name] || "prettyprint"
      @highlighter = options[:highlighter] || NoopHighlighter.new
    end

    def render(path, content)
      content = highlight_code_blocks(path, content)
      sanitize(GitHub::Markup.render(path, content))
    end

    def sanitize(html)
      Loofah.fragment(html).scrub!(:prune).to_s
    end

    def highlight_code_blocks(path, markup)
      return markup unless path =~ /\.(md|mkdn?|mdwn|mdown|markdown)$/
      CodeBlockParser.parse(markup) do |lexer, code|
        hb = @highlighter.highlight(path, code, { :lexer => lexer })
        "<pre class=\"#{hb.lexer} #{@markup_class_name}\">#{hb.code}</pre>"
      end
    end

    def self.can_render?(path)
      GitHub::Markup.can_render?(path)
    end

    def self.markups
      GitHub::Markup.markups
    end
  end
end
